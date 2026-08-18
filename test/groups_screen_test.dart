import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nomen_est/data/database.dart';
import 'package:nomen_est/data/providers.dart';
import 'package:nomen_est/screens/groups_screen.dart';

void main() {
  late AppDatabase db;
  late SchoolClass schoolClass;
  late List<Student> students;

  final photo = Uint8List.fromList(img.encodeJpg(img.Image(width: 2, height: 2)));

  /// Must run through [WidgetTester.runAsync]: a widget test body lives in a
  /// fake-async zone where a real database transaction never completes, and the
  /// test then hangs rather than fails. The other screen tests get away with
  /// seeding in `setUp`, which is outside that zone; here the class size
  /// differs per test, so it has to happen inside one.
  Future<void> seed(int count) async {
    await db.createClass(
      label: '2c Mathe',
      sourceFile: 'test.pdf',
      students: [
        for (var i = 0; i < count; i++)
          (
            displayName: 'Vorname$i Nachname$i',
            firstName: 'Vorname$i',
            lastName: 'Nachname$i',
            jpegBytes: photo,
          ),
      ],
    );
    schoolClass = (await db.watchClasses().first).single;
    students = await db.studentsInClass(schoolClass.id);
  }

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// The student list is handed in as a finished stream instead of drift's live
  /// query. A `watch()` query schedules timers, fake time fires them, and firing
  /// them schedules more — `pumpAndSettle` then never returns. It is a quirk of
  /// the test clock, not of the app: on a device there is no fake time. The
  /// absences and settings below still come from the real database, which is
  /// what these tests are about.
  Future<void> pump(WidgetTester tester) async {
    // A portrait window, for two reasons. Widget tests report Android as the
    // platform and default to 800x600 — landscape with a 600 short side, which
    // the beamer mode's own rule reads as a tablet and switches itself on.
    // These tests are about the button, not the automatic guess. Portrait also
    // leaves room for every group card, since the grid only builds what fits.
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        studentsProvider.overrideWith((ref, classId) => Stream.value(students)),
      ],
      child: MaterialApp(home: GroupsScreen(schoolClass: schoolClass)),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> tapPlus(WidgetTester tester, int times) async {
    for (var i = 0; i < times; i++) {
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();
    }
  }

  testWidgets('shows what the chosen split would produce', (tester) async {
    await tester.runAsync(() => seed(24));
    await pump(tester);

    expect(find.text('ergibt 6 Gruppen à 4'), findsOneWidget);
  });

  testWidgets('rolling turns the plan into cards', (tester) async {
    await tester.runAsync(() => seed(24));
    await pump(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Würfeln'));
    await tester.pumpAndSettle();

    // No member count in the title: "Gruppe 4 · 5" reads like a range.
    expect(find.text('Gruppe 1'), findsOneWidget);
    expect(find.text('Gruppe 6'), findsOneWidget);
    expect(find.textContaining('Gruppe 1 ·'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Neu würfeln'), findsOneWidget);
  });

  testWidgets('everyone lands in exactly one group', (tester) async {
    await tester.runAsync(() => seed(23));
    await pump(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Würfeln'));
    await tester.pumpAndSettle();

    for (var i = 0; i < 23; i++) {
      expect(find.text('Vorname$i'), findsOneWidget, reason: 'Vorname$i is missing or doubled');
    }
  });

  /// The whole reason the sizing is its own step: an impossible split has to
  /// say what would work, and the roll button has to be out of reach until it
  /// does.
  testWidgets('an impossible split names a way out and blocks the roll', (tester) async {
    await tester.runAsync(() => seed(7));
    await pump(tester);

    await tester.tap(find.text('Bereich'));
    await tester.pumpAndSettle();
    await tapPlus(tester, 1); // minimum 3 → 4

    expect(find.textContaining('lassen sich nicht in Gruppen von 4'), findsOneWidget);
    final roll = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Würfeln'));
    expect(roll.onPressed, isNull);
  });

  testWidgets('an absent student is left out of the grouping', (tester) async {
    await tester.runAsync(() async {
      await seed(4);
      final students = await db.studentsInClass(schoolClass.id);
      await db.into(db.absences).insert(AbsencesCompanion.insert(
            classId: schoolClass.id,
            studentId: students.first.id,
            day: dayNumber(DateTime.now()),
          ));
    });

    await pump(tester);
    expect(find.text('3/4 da'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Würfeln'));
    await tester.pumpAndSettle();
    expect(find.text('Vorname0'), findsNothing);
  });

  /// The setup steppers are for the teacher alone — there is nothing to show a
  /// room until the groups exist.
  testWidgets('the beamer button appears only once there is a result', (tester) async {
    await tester.runAsync(() => seed(24));
    await pump(tester);

    expect(find.byIcon(Icons.fullscreen), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Würfeln'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.fullscreen), findsOneWidget);
  });

  testWidgets('the beamer mode drops the app bar and keeps the groups', (tester) async {
    await tester.runAsync(() => seed(24));
    await pump(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Würfeln'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.fullscreen));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Gruppe 1'), findsOneWidget);
    expect(find.byIcon(Icons.fullscreen_exit), findsOneWidget);
  });

  testWidgets('leaving the beamer mode brings the app bar back', (tester) async {
    await tester.runAsync(() => seed(24));
    await pump(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Würfeln'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.fullscreen));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.fullscreen_exit));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('2c Mathe'), findsOneWidget);
  });

  testWidgets('the chosen size is remembered for next time', (tester) async {
    await tester.runAsync(() => seed(24));
    await pump(tester);
    await tapPlus(tester, 1); // groups of 4 → 5

    final stored = await tester.runAsync(() => db.select(db.settings).get());
    expect(stored!.singleWhere((row) => row.key.startsWith('groups.size')).value, '5');
  });
}
