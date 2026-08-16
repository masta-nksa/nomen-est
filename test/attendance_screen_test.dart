import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nomen_est/data/database.dart';
import 'package:nomen_est/data/providers.dart';
import 'package:nomen_est/screens/attendance_screen.dart';
import 'package:nomen_est/screens/draw_screen.dart';

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
        for (final name in ['Ada', 'Bo', 'Cem'])
          (displayName: '$name Muster', firstName: name, lastName: 'Muster', jpegBytes: photo),
      ],
    );
    schoolClass = (await db.watchClasses().first).single;
    students = await db.studentsInClass(classId);
  });
  tearDown(() => db.close());

  /// The student list is handed in ready-made so the screen never shows its
  /// loading spinner: `pumpAndSettle` waits for the frames to stop, and an
  /// indeterminate `CircularProgressIndicator` schedules them forever. The
  /// absences — what these tests are actually about — come from the real
  /// database.
  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        studentsProvider.overrideWith((ref, classId) => Stream.value(students)),
      ],
      child: MaterialApp(home: screen),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('everyone counts as present until someone is tapped', (tester) async {
    await pump(tester, AttendanceScreen(schoolClass: schoolClass));

    expect(find.textContaining('3 von 3 anwesend'), findsOneWidget);
  });

  testWidgets('tapping marks someone absent, tapping again brings them back', (tester) async {
    await pump(tester, AttendanceScreen(schoolClass: schoolClass));

    await tester.tap(find.text('Ada'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2 von 3 anwesend'), findsOneWidget);

    await tester.tap(find.text('Ada'));
    await tester.pumpAndSettle();
    expect(find.textContaining('3 von 3 anwesend'), findsOneWidget);
  });

  testWidgets('"Alle da" clears the day', (tester) async {
    await pump(tester, AttendanceScreen(schoolClass: schoolClass));

    await tester.tap(find.text('Ada'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 von 3 anwesend'), findsOneWidget);

    await tester.tap(find.text('Alle da'));
    await tester.pumpAndSettle();
    expect(find.textContaining('3 von 3 anwesend'), findsOneWidget);
  });

  /// The reason attendance exists at all: drawing someone who is not there is
  /// immediately awkward, and it would waste their turn as well.
  testWidgets('an absence shrinks the pool on the draw screen', (tester) async {
    await pump(tester, AttendanceScreen(schoolClass: schoolClass));
    await tester.tap(find.text('Ada'));
    await tester.pumpAndSettle();

    await pump(tester, DrawScreen(schoolClass: schoolClass));

    expect(find.text('2/3'), findsOneWidget, reason: 'the pool skips the absent');
    expect(find.text('2/3 da'), findsOneWidget);
  });
}
