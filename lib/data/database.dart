import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint;

part 'database.g.dart';

/// The pool used for calling on people during a lesson.
///
/// Every draw belongs to a pool, so a class can keep independent pots later
/// (`praesentation`, `tafeldienst`) without the lesson pool being consumed by
/// them. Only this one is reachable from the UI for now.
const defaultPoolKey = 'default';

/// A calendar day as `20260816`.
///
/// Absences are keyed by this rather than by a `DateTime`, because drift stores
/// those as UTC instants — "today" would then shift across a timezone change or
/// a DST boundary, and an absence entered in the morning could stop matching in
/// the afternoon.
int dayNumber(DateTime day) => day.year * 10000 + day.month * 100 + day.day;

@DataClassName('SchoolClass')
class Classes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text()();
  TextColumn get sourceFile => text()();
  DateTimeColumn get importedAt => dateTime()();
}

class Students extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get classId => integer().references(Classes, #id, onDelete: KeyAction.cascade)();
  TextColumn get displayName => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  BlobColumn get jpegBytes => blob()();
  IntColumn get orderIndex => integer()();

  /// Someone who leaves the class mid-year is deactivated, not deleted.
  ///
  /// A delete would cascade through the draw log and the saved groups and
  /// quietly rewrite a history that did happen. Inactive students drop out of
  /// the pool and out of the quiz; their past stays readable.
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

class Progress extends Table {
  IntColumn get studentId => integer().references(Students, #id, onDelete: KeyAction.cascade)();
  IntColumn get box => integer().withDefault(const Constant(1))();
  IntColumn get correct => integer().withDefault(const Constant(0))();
  IntColumn get wrong => integer().withDefault(const Constant(0))();
  IntColumn get streak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  IntColumn get avgMs => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {studentId};
}

class Confusions extends Table {
  @ReferenceName('confusionsShown')
  IntColumn get studentId => integer().references(Students, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('confusionsPicked')
  IntColumn get confusedWithId => integer().references(Students, #id, onDelete: KeyAction.cascade)();
  IntColumn get count => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {studentId, confusedWithId};
}

/// One draw. Appended, never updated; only an undo removes a row again.
///
/// Drawing "without replacement" is this log plus [PoolResets], not a flag on
/// the student: the pool is derived, so it survives a restart, an undo is a
/// delete, and the statistics fall out for free.
@TableIndex.sql('CREATE INDEX IF NOT EXISTS idx_draw_class_pool_time '
    'ON draw_events (class_id, pool_key, drawn_at DESC)')
@TableIndex.sql('CREATE INDEX IF NOT EXISTS idx_draw_student ON draw_events (class_id, student_id)')
class DrawEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get classId => integer().references(Classes, #id, onDelete: KeyAction.cascade)();
  IntColumn get studentId => integer().references(Students, #id, onDelete: KeyAction.cascade)();
  TextColumn get poolKey => text().withDefault(const Constant(defaultPoolKey))();
  DateTimeColumn get drawnAt => dateTime()();
}

/// Marks where a round of "without replacement" started over.
///
/// A reset is one insert instead of a mass update, and the log before it stays
/// intact for the fairness weighting.
class PoolResets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get classId => integer().references(Classes, #id, onDelete: KeyAction.cascade)();
  TextColumn get poolKey => text().withDefault(const Constant(defaultPoolKey))();
  DateTimeColumn get resetAt => dateTime()();

  /// Whether the app started the round by itself instead of asking.
  BoolColumn get auto => boolean().withDefault(const Constant(false))();
}

/// Only absences are stored — the default is present.
///
/// An absent student produces no [DrawEvents] row, so they do not consume the
/// pool and are up again next lesson.
@TableIndex.sql('CREATE INDEX IF NOT EXISTS idx_absence_day ON absences (class_id, day)')
class Absences extends Table {
  IntColumn get classId => integer().references(Classes, #id, onDelete: KeyAction.cascade)();
  IntColumn get studentId => integer().references(Students, #id, onDelete: KeyAction.cascade)();

  /// Calendar day as `20260816`, see [dayNumber].
  IntColumn get day => integer()();

  @override
  Set<Column> get primaryKey => {classId, studentId, day};
}

/// One saved grouping.
class GroupSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get classId => integer().references(Classes, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class GroupMembers extends Table {
  IntColumn get groupSetId => integer().references(GroupSets, #id, onDelete: KeyAction.cascade)();

  /// 0-based index of the group within its set.
  IntColumn get groupIndex => integer()();
  IntColumn get studentId => integer().references(Students, #id, onDelete: KeyAction.cascade)();

  /// "Protokoll", "Zeit", "Präsentation" — assigned per grouping.
  TextColumn get role => text().nullable()();

  @override
  Set<Column> get primaryKey => {groupSetId, studentId};
}

/// Denormalised cache: how often were a and b in the same group?
///
/// Rebuildable from [GroupMembers], so a migration may recompute it rather than
/// trust it. Invariant: [studentA] < [studentB].
class PairCounts extends Table {
  IntColumn get classId => integer().references(Classes, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('pairCountsAsA')
  IntColumn get studentA => integer().references(Students, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('pairCountsAsB')
  IntColumn get studentB => integer().references(Students, #id, onDelete: KeyAction.cascade)();
  IntColumn get count => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {classId, studentA, studentB};
}

enum ConstraintKind { together, apart }

/// A teacher's hard rule about two students, kept per class.
///
/// Unlike [PairCounts] these are decisions, not history — a reset of the
/// grouping history leaves them alone.
class GroupConstraints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get classId => integer().references(Classes, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('constraintsAsA')
  IntColumn get studentA => integer().references(Students, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('constraintsAsB')
  IntColumn get studentB => integer().references(Students, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => textEnum<ConstraintKind>()();
  TextColumn get note => text().nullable()();
}

/// Chip states and quiz dials.
///
/// Keys carry their own scope: `random.replacement` is the global default,
/// `random.replacement.class.3` overrides it for one class. Teachers treat
/// classes differently, and a per-class column would have to be added to every
/// future setting individually.
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Classes,
    Students,
    Progress,
    Confusions,
    DrawEvents,
    PoolResets,
    Absences,
    GroupSets,
    GroupMembers,
    PairCounts,
    GroupConstraints,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  /// Which storage drift settled on, once the web database has been opened.
  ///
  /// Only some of the web implementations survive a reload, so this is worth
  /// being able to see rather than guess at.
  static WasmDatabaseResult? webStorage;

  /// On web these point at the files `tool/fetch_web_assets.sh` puts in `web/`;
  /// the options are ignored on native platforms.
  static QueryExecutor _open() => driftDatabase(
        name: 'nomen_est',
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
          onResult: (result) {
            webStorage = result;
            debugPrint('drift web storage: ${result.chosenImplementation}, '
                'missing: ${result.missingFeatures}');
          },
        ),
      );

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) => _upgradeToV2(m),
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// v1 → v2: the tables were named after the PDF import they came from
  /// ("photo set", "person"), but attendance, draws and groups belong to a
  /// class, not to an import. Renaming keeps the existing photos and learning
  /// progress; recreating would have thrown them away.
  ///
  /// **Every step is conditional on what the database actually contains, not on
  /// the version number it claims.** Drift runs migrations outside a
  /// transaction and writes the new version only once they finish, so a step
  /// that fails leaves the earlier ones applied while the version stays behind
  /// — and the next open starts over. A migration that assumes v1 is intact can
  /// therefore run exactly once; on the second attempt it dies on a rename it
  /// already did, and the database can never be opened again.
  ///
  /// On the web the schema can also disagree with the version outright: a
  /// storage fallback that persisted the version but not the tables leaves a
  /// database that says "v1" and holds nothing. That is not hypothetical — it
  /// is what the first deployed build hit. Both cases end here as a plain
  /// "create what is missing".
  Future<void> _upgradeToV2(Migrator m) async {
    final before = await _tableNames();
    if (before.contains('photo_sets')) await m.renameTable(classes, 'photo_sets');
    if (before.contains('persons')) await m.renameTable(students, 'persons');

    if (await _hasColumn('students', 'set_id')) {
      await m.renameColumn(students, 'set_id', students.classId);
    }
    if ((await _tableNames()).contains('students') && !await _hasColumn('students', 'active')) {
      await m.addColumn(students, students.active);
    }
    if (await _hasColumn('progress', 'person_id')) {
      await m.renameColumn(progress, 'person_id', progress.studentId);
    }
    if (await _hasColumn('confusions', 'person_id')) {
      await m.renameColumn(confusions, 'person_id', confusions.studentId);
    }

    // Adds the eight new tables and the indices — and on a database whose
    // tables never reached the disk, all of them. Safe to repeat: drift writes
    // `CREATE TABLE IF NOT EXISTS`, and the indices carry their own
    // `IF NOT EXISTS` because drift does not add one.
    await m.createAll();
  }

  Future<Set<String>> _tableNames() async {
    final rows = await customSelect("SELECT name FROM sqlite_master WHERE type = 'table'").get();
    return {for (final row in rows) row.read<String>('name')};
  }

  /// False for a column of a table that does not exist, which is what makes the
  /// callers above readable. The names are constants from this file, never user
  /// input, so interpolating them is safe.
  Future<bool> _hasColumn(String table, String column) async {
    final rows = await customSelect("SELECT name FROM pragma_table_info('$table')").get();
    return rows.any((row) => row.read<String>('name') == column);
  }

  Stream<List<SchoolClass>> watchClasses() =>
      (select(classes)..orderBy([(c) => OrderingTerm.desc(c.importedAt)])).watch();

  SimpleSelectStatement<$StudentsTable, Student> _studentsQuery(int classId, bool includeInactive) =>
      select(students)
        ..where((s) => includeInactive ? s.classId.equals(classId) : s.classId.equals(classId) & s.active)
        ..orderBy([(s) => OrderingTerm.asc(s.orderIndex)]);

  Future<List<Student>> studentsInClass(int classId, {bool includeInactive = false}) =>
      _studentsQuery(classId, includeInactive).get();

  Stream<List<Student>> watchStudentsInClass(int classId, {bool includeInactive = false}) =>
      _studentsQuery(classId, includeInactive).watch();

  /// Stores a freshly imported (and reviewed) class.
  Future<int> createClass({
    required String label,
    required String sourceFile,
    required List<({String displayName, String firstName, String lastName, Uint8List jpegBytes})> students,
  }) async {
    return transaction(() async {
      final classId = await into(classes).insert(ClassesCompanion.insert(
        label: label,
        sourceFile: sourceFile,
        importedAt: DateTime.now(),
      ));
      for (var i = 0; i < students.length; i++) {
        final student = students[i];
        final studentId = await into(this.students).insert(StudentsCompanion.insert(
          classId: classId,
          displayName: student.displayName,
          firstName: student.firstName,
          lastName: student.lastName,
          jpegBytes: student.jpegBytes,
          orderIndex: i,
        ));
        await into(progress).insert(ProgressCompanion.insert(studentId: Value(studentId)));
      }
      return classId;
    });
  }

  Future<void> renameClass(int classId, String label) =>
      (update(classes)..where((c) => c.id.equals(classId))).write(ClassesCompanion(label: Value(label)));

  Future<void> deleteClass(int classId) => (delete(classes)..where((c) => c.id.equals(classId))).go();

  /// Clears the learning progress, keeping photos, names and everything the
  /// class did in lessons.
  Future<void> resetProgress(int classId) async {
    final ids = (await studentsInClass(classId, includeInactive: true)).map((s) => s.id).toList();
    if (ids.isEmpty) return;
    await transaction(() async {
      await (update(progress)..where((p) => p.studentId.isIn(ids))).write(const ProgressCompanion(
        box: Value(1),
        correct: Value(0),
        wrong: Value(0),
        streak: Value(0),
        avgMs: Value(0),
        lastSeenAt: Value(null),
      ));
      await (delete(confusions)..where((c) => c.studentId.isIn(ids))).go();
    });
  }

  /// Forgets who was drawn, in every pool. The pool starts full again.
  Future<void> resetDrawHistory(int classId) async {
    await transaction(() async {
      await (delete(drawEvents)..where((d) => d.classId.equals(classId))).go();
      await (delete(poolResets)..where((r) => r.classId.equals(classId))).go();
    });
  }

  /// Forgets every recorded absence — everyone counts as present again.
  Future<void> resetAbsences(int classId) =>
      (delete(absences)..where((a) => a.classId.equals(classId))).go();

  /// Drops saved groupings and the pairing history derived from them.
  ///
  /// Constraints survive: "A and B not together" is a decision about the class,
  /// not a record of what happened.
  Future<void> resetGroupHistory(int classId) async {
    await transaction(() async {
      await (delete(groupSets)..where((g) => g.classId.equals(classId))).go();
      await (delete(pairCounts)..where((p) => p.classId.equals(classId))).go();
    });
  }

  JoinedSelectStatement<HasResultSet, dynamic> _progressQuery(int classId) =>
      select(progress).join([
        innerJoin(students, students.id.equalsExp(progress.studentId)),
      ])
        ..where(students.classId.equals(classId));

  Future<List<ProgressData>> progressForClass(int classId) =>
      _progressQuery(classId).map((row) => row.readTable(progress)).get();

  Stream<List<ProgressData>> watchProgressForClass(int classId) =>
      _progressQuery(classId).map((row) => row.readTable(progress)).watch();

  /// Applies one quiz answer: Leitner box movement plus response-time average.
  Future<void> recordAnswer({
    required int studentId,
    required bool correct,
    required int elapsedMs,
  }) async {
    final current = await (select(progress)..where((p) => p.studentId.equals(studentId))).getSingleOrNull();
    final box = current?.box ?? 1;
    final answered = (current?.correct ?? 0) + (current?.wrong ?? 0);
    final avgMs = current == null || answered == 0
        ? elapsedMs
        : ((current.avgMs * answered) + elapsedMs) ~/ (answered + 1);

    final companion = ProgressCompanion(
      studentId: Value(studentId),
      box: Value(correct ? (box + 1).clamp(1, 5) : (box - 2).clamp(1, 5)),
      correct: Value((current?.correct ?? 0) + (correct ? 1 : 0)),
      wrong: Value((current?.wrong ?? 0) + (correct ? 0 : 1)),
      streak: Value(correct ? (current?.streak ?? 0) + 1 : 0),
      lastSeenAt: Value(DateTime.now()),
      avgMs: Value(avgMs),
    );
    await into(progress).insertOnConflictUpdate(companion);
  }

  /// Records that [confusedWithId] was picked when [studentId] was shown.
  Future<void> recordConfusion({required int studentId, required int confusedWithId}) async {
    await customStatement(
      'INSERT INTO confusions (student_id, confused_with_id, count) VALUES (?, ?, 1) '
      'ON CONFLICT(student_id, confused_with_id) DO UPDATE SET count = count + 1',
      [studentId, confusedWithId],
    );
  }

  Future<List<Confusion>> confusionsFor(int studentId) =>
      (select(confusions)..where((c) => c.studentId.equals(studentId))..orderBy([(c) => OrderingTerm.desc(c.count)]))
          .get();

  Future<List<Confusion>> confusionsForClass(int classId) {
    final query = select(confusions).join([
      innerJoin(students, students.id.equalsExp(confusions.studentId)),
    ])
      ..where(students.classId.equals(classId))
      ..orderBy([OrderingTerm.desc(confusions.count)]);
    return query.map((row) => row.readTable(confusions)).get();
  }
}
