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

  testWidgets('chunks are off until asked for', (tester) async {
    await pump(tester);

    expect(find.text('Häppchen'), findsOneWidget);
    expect(find.textContaining('ganze Klasse auf einmal'), findsOneWidget);
  });

  /// 21 students in fives, so the sizes come out 6+5+5+5 rather than leaving
  /// somebody alone in a chunk of one.
  testWidgets('the steps say what is in play', (tester) async {
    await pump(tester);

    await tester.tap(find.widgetWithText(SegmentedButton<int>, '5').first);
    await tester.pumpAndSettle();

    // The label carries the meaning, so no second switch has to explain it.
    expect(find.widgetWithText(ChoiceChip, '1'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '1–2'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '1–3'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'alle'), findsOneWidget);
    expect(find.textContaining('6 Personen im Spiel'), findsOneWidget);
  });

  testWidgets('a later step keeps the earlier ones', (tester) async {
    await pump(tester);
    await tester.tap(find.widgetWithText(SegmentedButton<int>, '5').first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, '1–2'));
    await tester.pumpAndSettle();

    expect(find.textContaining('11 Personen im Spiel'), findsOneWidget);
    expect(find.textContaining('Neu ab hier: Vorname6'), findsOneWidget);
  });

  /// Where you left off is a place, not a dial — it has to survive a restart.
  testWidgets('the step is remembered', (tester) async {
    await pump(tester);
    await tester.tap(find.widgetWithText(SegmentedButton<int>, '5').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '1–3'));
    await tester.pumpAndSettle();

    final stored = await tester.runAsync(() => db.select(db.settings).get());
    expect(stored!.singleWhere((r) => r.key.startsWith('quiz.chunkSize')).value, '5');
    expect(stored.singleWhere((r) => r.key.startsWith('quiz.chunkStep')).value, '2');
  });
}
