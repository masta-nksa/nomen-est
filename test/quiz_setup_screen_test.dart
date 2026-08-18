import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nomen_est/data/database.dart';
import 'package:nomen_est/data/providers.dart';
import 'package:nomen_est/screens/quiz_setup_screen.dart';

void main() {
  late AppDatabase db;
  late SchoolClass schoolClass;
  late List<Student> students;

  final photo = Uint8List.fromList(img.encodeJpg(img.Image(width: 2, height: 2)));

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final classId = await db.createClass(
      label: '2c Mathe',
      sourceFile: 'test.pdf',
      students: [
        for (var i = 0; i < 21; i++)
          (
            displayName: 'Vorname$i Nachname$i',
            firstName: 'Vorname$i',
            lastName: 'Nachname$i',
            jpegBytes: photo,
          ),
      ],
    );
    schoolClass = (await db.watchClasses().first).single;
    students = await db.studentsInClass(classId);
  });
  tearDown(() => db.close());

  /// Live drift queries schedule timers that fake time keeps re-firing, so
  /// `pumpAndSettle` never returns — the streams are handed in finished. The
  /// settings the chunk choice is written to are the real database.
  Future<void> pump(WidgetTester tester) async {
    // Tall enough for the whole setup: a ListView only builds what fits, and
    // the round length sits far below the scope options.
    tester.view.physicalSize = const Size(1000, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        studentsProvider.overrideWith((ref, id) => Stream.value(students)),
        studentBoxesProvider.overrideWith((ref, id) => Stream.value(const <int, int>{})),
        classStatsProvider.overrideWith(
          (ref, id) => Stream.value(const ClassStats(total: 21, secure: 0)),
        ),
      ],
      child: MaterialApp(home: QuizSetupScreen(schoolClass: schoolClass)),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('the automatic scope needs no controls and says what it does', (tester) async {
    await pump(tester);

    expect(find.text('Automatisch'), findsOneWidget);
    expect(find.textContaining('5 von 21 im Spiel'), findsOneWidget);
    expect(find.textContaining('0 sitzen, 5 werden gerade gelernt'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNothing, reason: 'no dials in this mode');
  });

  /// 21 students in fives, so the sizes come out 6+5+5+5 rather than leaving
  /// somebody alone in a portion of one.
  testWidgets('choosing to divide it yourself brings out the steps', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Selbst einteilen'));
    await tester.pumpAndSettle();

    // The label carries the meaning, so no second switch has to explain it.
    expect(find.widgetWithText(ChoiceChip, '1'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '1–2'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'alle'), findsOneWidget);
    expect(find.textContaining('6 Personen im Spiel'), findsOneWidget);
  });

  testWidgets('a later step keeps the earlier ones', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Selbst einteilen'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, '1–2'));
    await tester.pumpAndSettle();

    expect(find.textContaining('11 Personen im Spiel'), findsOneWidget);
    expect(find.textContaining('Neu ab hier: Vorname6'), findsOneWidget);
  });

  /// Where you left off is a place, not a dial — it has to survive a restart.
  testWidgets('the scope and the step are remembered', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Selbst einteilen'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '1–3'));
    await tester.pumpAndSettle();

    final stored = await tester.runAsync(() => db.select(db.settings).get());
    expect(stored!.singleWhere((r) => r.key.startsWith('quiz.scope')).value, 'manual');
    expect(stored.singleWhere((r) => r.key.startsWith('quiz.chunkStep')).value, '2');
  });

  /// "15 Karten" says nothing on its own — over the whole class that is half a
  /// turn each, over a handful it is three.
  group('the round length is spelled out for the scope', () {
    testWidgets('a handful means several turns each', (tester) async {
      await pump(tester);
      expect(find.textContaining('15 Karten über 5 Personen — jede etwa 3×'), findsOneWidget);
    });

    testWidgets('the whole class means not everyone gets a turn', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Ganze Klasse'));
      await tester.pumpAndSettle();

      expect(find.textContaining('nicht alle kommen dran'), findsOneWidget);
    });

    testWidgets('it follows the manual steps', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Selbst einteilen'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, '1–2'));
      await tester.pumpAndSettle();

      expect(find.textContaining('15 Karten über 11 Personen'), findsOneWidget);
    });
  });

  /// Four dials the presets already set. Showing them all at once turns a
  /// screen you pass through into a form you have to read.
  group('the detail dials stay folded away', () {
    testWidgets('hidden until asked for', (tester) async {
      await pump(tester);

      expect(find.text('Selbst einstellen'), findsOneWidget);
      expect(find.text('Anzahl Optionen'), findsNothing);
      expect(find.text('Zeitlimit'), findsNothing);
    });

    testWidgets('and all there once opened', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Selbst einstellen'));
      await tester.pumpAndSettle();

      for (final dial in ['Anzahl Optionen', 'Ablenker', 'Zeitlimit', 'Angezeigter Name']) {
        expect(find.text(dial), findsOneWidget, reason: '$dial is missing');
      }
    });
  });

  /// A preset is a difficulty, not a reset. Throwing away how far through the
  /// class you are would be a surprising price for tapping "Mittel".
  testWidgets('a preset leaves the scope alone', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Selbst einteilen'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '1–2'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mittel'));
    await tester.pumpAndSettle();

    expect(find.textContaining('11 Personen im Spiel'), findsOneWidget);
  });

  testWidgets('the whole class is one tap away', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Ganze Klasse'));
    await tester.pumpAndSettle();

    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.textContaining('im Spiel'), findsNothing);
  });
}
