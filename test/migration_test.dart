import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/data/database.dart';

import 'index_names.dart';

/// The schema as it shipped in version 1, when a class was still a "photo set"
/// and a student a "person".
///
/// Written out by hand rather than generated, because the point of the test is
/// exactly that a database created by the *old* code still opens.
const _v1Tables = [
  '''
  CREATE TABLE photo_sets (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    label TEXT NOT NULL,
    source_file TEXT NOT NULL,
    imported_at INTEGER NOT NULL
  )''',
  '''
  CREATE TABLE persons (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    set_id INTEGER NOT NULL REFERENCES photo_sets (id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    jpeg_bytes BLOB NOT NULL,
    order_index INTEGER NOT NULL
  )''',
  '''
  CREATE TABLE progress (
    person_id INTEGER NOT NULL REFERENCES persons (id) ON DELETE CASCADE,
    box INTEGER NOT NULL DEFAULT 1,
    correct INTEGER NOT NULL DEFAULT 0,
    wrong INTEGER NOT NULL DEFAULT 0,
    streak INTEGER NOT NULL DEFAULT 0,
    last_seen_at INTEGER,
    avg_ms INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (person_id)
  )''',
  '''
  CREATE TABLE confusions (
    person_id INTEGER NOT NULL REFERENCES persons (id) ON DELETE CASCADE,
    confused_with_id INTEGER NOT NULL REFERENCES persons (id) ON DELETE CASCADE,
    count INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (person_id, confused_with_id)
  )''',
];

const _v1Data = [
  "INSERT INTO photo_sets (id, label, source_file, imported_at) "
      "VALUES (1, '2c Mathe', 'klasse.pdf', 1755300000)",
  "INSERT INTO persons (id, set_id, display_name, first_name, last_name, jpeg_bytes, order_index) "
      "VALUES (1, 1, 'Brändli Lyan', 'Lyan', 'Brändli', X'0102', 0)",
  "INSERT INTO persons (id, set_id, display_name, first_name, last_name, jpeg_bytes, order_index) "
      "VALUES (2, 1, 'Huber Diana', 'Diana', 'Huber', X'0304', 1)",
  "INSERT INTO progress (person_id, box, correct, wrong, streak, avg_ms) VALUES (1, 4, 7, 1, 3, 900)",
  "INSERT INTO progress (person_id) VALUES (2)",
  "INSERT INTO confusions (person_id, confused_with_id, count) VALUES (1, 2, 5)",
];

/// What the first half of the upgrade leaves behind: renamed tables, no new
/// ones, and — because drift writes the version only after a migration finishes
/// — a database that still calls itself v1 and will run the upgrade again.
const _halfMigrated = [
  'ALTER TABLE photo_sets RENAME TO classes',
  'ALTER TABLE persons RENAME TO students',
  'ALTER TABLE students RENAME COLUMN set_id TO class_id',
  'ALTER TABLE students ADD COLUMN active INTEGER NOT NULL DEFAULT 1',
  'ALTER TABLE progress RENAME COLUMN person_id TO student_id',
  'ALTER TABLE confusions RENAME COLUMN person_id TO student_id',
];

AppDatabase openV1({List<String> extra = const []}) {
  return AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
    for (final statement in [..._v1Tables, ..._v1Data, ...extra]) {
      raw.execute(statement);
    }
    raw.execute('PRAGMA user_version = 1');
  }));
}

void main() {
  late AppDatabase db;

  setUp(() => db = openV1());
  tearDown(() => db.close());

  test('a v1 database keeps its classes and photos', () async {
    final classes = await db.watchClasses().first;
    expect(classes.single.label, '2c Mathe');
    expect(classes.single.sourceFile, 'klasse.pdf');

    final students = await db.studentsInClass(classes.single.id);
    expect(students.map((s) => s.displayName), ['Brändli Lyan', 'Huber Diana']);
    expect(students.first.jpegBytes, [1, 2]);
  });

  test('students imported before the rename count as active', () async {
    final students = await db.studentsInClass(1);
    expect(students.every((s) => s.active), isTrue);
  });

  test('learning progress and confusions survive the rename', () async {
    final progress = await db.progressForClass(1);
    final lyan = progress.firstWhere((p) => p.studentId == 1);
    expect(lyan.box, 4);
    expect(lyan.correct, 7);
    expect(lyan.avgMs, 900);

    final confusions = await db.confusionsFor(1);
    expect(confusions.single.confusedWithId, 2);
    expect(confusions.single.count, 5);
  });

  test('the new tables exist and their foreign keys point at the renamed ones', () async {
    await db.into(db.drawEvents).insert(DrawEventsCompanion.insert(
          classId: 1,
          studentId: 2,
          drawnAt: DateTime(2026, 8, 16, 10),
        ));

    final events = await db.select(db.drawEvents).get();
    expect(events.single.studentId, 2);
    expect(events.single.poolKey, defaultPoolKey);

    // The rename has to have carried over to the child tables, or this would
    // insert happily against a table that no longer exists.
    await db.deleteClass(1);
    expect(await db.select(db.drawEvents).get(), isEmpty);
  });

  test('the upgrade creates the indices too', () async {
    expect(await indexNames(db), [
      'idx_absence_day',
      'idx_draw_class_pool_time',
      'idx_draw_student',
    ]);
  });

  /// Drift runs migrations outside a transaction and only writes the new
  /// version once they succeed. A half-finished upgrade therefore comes back
  /// on the next open, and the first deployed build died there — it retried a
  /// rename it had already done and locked the user out of their own database.
  group('a repeated upgrade', () {
    late AppDatabase retried;
    tearDown(() => retried.close());

    test('finishes a half-migrated database instead of dying on it', () async {
      retried = openV1(extra: _halfMigrated);

      final classes = await retried.watchClasses().first;
      expect(classes.single.label, '2c Mathe');

      final students = await retried.studentsInClass(classes.single.id);
      expect(students.map((s) => s.displayName), ['Brändli Lyan', 'Huber Diana']);
      expect(students.first.jpegBytes, [1, 2], reason: 'the photos must not be lost on the retry');
      expect((await retried.progressForClass(1)).firstWhere((p) => p.studentId == 1).box, 4);

      await retried.into(retried.drawEvents).insert(DrawEventsCompanion.insert(
            classId: 1,
            studentId: 1,
            drawnAt: DateTime(2026, 8, 16, 10),
          ));
      expect(await retried.select(retried.drawEvents).get(), hasLength(1));
      expect(await indexNames(retried), hasLength(3));
    });

    /// A web storage fallback can persist the version but not the tables — the
    /// database then claims v1 and holds nothing. Seen on the first deployed
    /// preview build.
    test('rebuilds a database that has a version but no tables', () async {
      retried = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
        raw.execute('PRAGMA user_version = 1');
      }));

      expect(await retried.watchClasses().first, isEmpty);

      final classId = await retried.createClass(
        label: 'Neu',
        sourceFile: 'x.pdf',
        students: [
          (displayName: 'A B', firstName: 'B', lastName: 'A', jpegBytes: Uint8List.fromList([1])),
        ],
      );
      expect(await retried.studentsInClass(classId), hasLength(1));
      expect(await indexNames(retried), hasLength(3));
    });
  });
}
