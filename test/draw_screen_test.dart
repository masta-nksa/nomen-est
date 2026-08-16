import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nomen_est/data/database.dart';
import 'package:nomen_est/data/providers.dart';
import 'package:nomen_est/screens/draw_screen.dart';

void main() {
  late AppDatabase db;
  late SchoolClass schoolClass;
  late List<Student> students;

  // A real JPEG, because Image.memory turns undecodable bytes into a test
  // failure rather than an empty box.
  final photo = Uint8List.fromList(img.encodeJpg(img.Image(width: 2, height: 2)));

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final classId = await db.createClass(
      label: '2c Mathe',
      sourceFile: 'test.pdf',
      students: [
        for (var i = 0; i < 3; i++)
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

  Future<void> pumpDraw(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(home: DrawScreen(schoolClass: schoolClass)),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('opens with a full pool and nobody drawn', (tester) async {
    await pumpDraw(tester);

    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('Noch niemand gezogen.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Würfeln'), findsOneWidget);
  });

  testWidgets('drawing shows a name and takes them out of the pool', (tester) async {
    await pumpDraw(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Würfeln'));
    await tester.pumpAndSettle();

    expect(find.text('2/3'), findsOneWidget);
    final names = students.map((s) => s.displayName);
    expect(names.where((name) => find.text(name).evaluate().isNotEmpty), hasLength(1));
    expect(find.widgetWithText(FilledButton, 'Nochmal'), findsOneWidget);
  });

  testWidgets('undo puts them back', (tester) async {
    await pumpDraw(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Würfeln'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Zurück'));
    await tester.pumpAndSettle();

    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('Noch niemand gezogen.'), findsOneWidget);
  });

  /// The pool must not silently start over — seeing where a round ended is the
  /// point of recording the reset.
  testWidgets('an exhausted pool asks before starting a new round', (tester) async {
    await pumpDraw(tester);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.widgetWithText(FilledButton, i == 0 ? 'Würfeln' : 'Nochmal'));
      await tester.pumpAndSettle();
    }
    expect(find.text('0/3'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Nochmal'));
    await tester.pumpAndSettle();
    expect(find.text('Alle waren dran'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Neue Runde'));
    await tester.pumpAndSettle();
    expect(find.text('3/3'), findsOneWidget);
  });

  /// A status chip shows a detail rather than switching something. Resetting on
  /// a mistyped tap would throw away the running round.
  testWidgets('the pool chip opens the pool instead of resetting it', (tester) async {
    await pumpDraw(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Würfeln'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('2/3'));
    await tester.pumpAndSettle();

    expect(find.text('Noch im Topf: 2 von 3'), findsOneWidget);
    expect(find.text('Schon dran'), findsOneWidget);

    // Closing without touching the button leaves the round alone.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('2/3'), findsOneWidget);
  });

  testWidgets('the repetition chip survives leaving the screen', (tester) async {
    await pumpDraw(tester);

    await tester.tap(find.text('Wiederholung'));
    await tester.pumpAndSettle();

    // A second screen on the same database stands in for coming back later.
    await pumpDraw(tester);
    final stored = await db.select(db.settings).get();
    expect(
      stored.singleWhere((row) => row.key.startsWith('random.replacement')).value,
      'true',
    );
  });
}
