import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class PhotoSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text()();
  TextColumn get sourceFile => text()();
  DateTimeColumn get importedAt => dateTime()();
}

class Persons extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get setId => integer().references(PhotoSets, #id, onDelete: KeyAction.cascade)();
  TextColumn get displayName => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  BlobColumn get jpegBytes => blob()();
  IntColumn get orderIndex => integer()();
}

class Progress extends Table {
  IntColumn get personId => integer().references(Persons, #id, onDelete: KeyAction.cascade)();
  IntColumn get box => integer().withDefault(const Constant(1))();
  IntColumn get correct => integer().withDefault(const Constant(0))();
  IntColumn get wrong => integer().withDefault(const Constant(0))();
  IntColumn get streak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  IntColumn get avgMs => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {personId};
}

class Confusions extends Table {
  @ReferenceName('confusionsShown')
  IntColumn get personId => integer().references(Persons, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('confusionsPicked')
  IntColumn get confusedWithId => integer().references(Persons, #id, onDelete: KeyAction.cascade)();
  IntColumn get count => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {personId, confusedWithId};
}

@DriftDatabase(tables: [PhotoSets, Persons, Progress, Confusions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  /// On web these point at the files `tool/fetch_web_assets.sh` puts in `web/`;
  /// the options are ignored on native platforms.
  static QueryExecutor _open() => driftDatabase(
        name: 'nomen_est',
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      );

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Stream<List<PhotoSet>> watchPhotoSets() =>
      (select(photoSets)..orderBy([(s) => OrderingTerm.desc(s.importedAt)])).watch();

  Future<List<Person>> personsInSet(int setId) =>
      (select(persons)..where((p) => p.setId.equals(setId))..orderBy([(p) => OrderingTerm.asc(p.orderIndex)])).get();

  Stream<List<Person>> watchPersonsInSet(int setId) =>
      (select(persons)..where((p) => p.setId.equals(setId))..orderBy([(p) => OrderingTerm.asc(p.orderIndex)])).watch();

  /// Stores a freshly imported (and reviewed) class set.
  Future<int> createPhotoSet({
    required String label,
    required String sourceFile,
    required List<({String displayName, String firstName, String lastName, Uint8List jpegBytes})> people,
  }) async {
    return transaction(() async {
      final setId = await into(photoSets).insert(PhotoSetsCompanion.insert(
        label: label,
        sourceFile: sourceFile,
        importedAt: DateTime.now(),
      ));
      for (var i = 0; i < people.length; i++) {
        final person = people[i];
        final personId = await into(persons).insert(PersonsCompanion.insert(
          setId: setId,
          displayName: person.displayName,
          firstName: person.firstName,
          lastName: person.lastName,
          jpegBytes: person.jpegBytes,
          orderIndex: i,
        ));
        await into(progress).insert(ProgressCompanion.insert(personId: Value(personId)));
      }
      return setId;
    });
  }

  Future<void> renamePhotoSet(int setId, String label) =>
      (update(photoSets)..where((s) => s.id.equals(setId))).write(PhotoSetsCompanion(label: Value(label)));

  Future<void> deletePhotoSet(int setId) =>
      (delete(photoSets)..where((s) => s.id.equals(setId))).go();

  Future<void> resetProgress(int setId) async {
    final ids = (await personsInSet(setId)).map((p) => p.id).toList();
    if (ids.isEmpty) return;
    await transaction(() async {
      await (update(progress)..where((p) => p.personId.isIn(ids))).write(const ProgressCompanion(
        box: Value(1),
        correct: Value(0),
        wrong: Value(0),
        streak: Value(0),
        avgMs: Value(0),
        lastSeenAt: Value(null),
      ));
      await (delete(confusions)..where((c) => c.personId.isIn(ids))).go();
    });
  }

  JoinedSelectStatement<HasResultSet, dynamic> _progressQuery(int setId) =>
      select(progress).join([
        innerJoin(persons, persons.id.equalsExp(progress.personId)),
      ])
        ..where(persons.setId.equals(setId));

  Future<List<ProgressData>> progressForSet(int setId) =>
      _progressQuery(setId).map((row) => row.readTable(progress)).get();

  Stream<List<ProgressData>> watchProgressForSet(int setId) =>
      _progressQuery(setId).map((row) => row.readTable(progress)).watch();

  /// Applies one quiz answer: Leitner box movement plus response-time average.
  Future<void> recordAnswer({
    required int personId,
    required bool correct,
    required int elapsedMs,
  }) async {
    final current = await (select(progress)..where((p) => p.personId.equals(personId))).getSingleOrNull();
    final box = current?.box ?? 1;
    final answered = (current?.correct ?? 0) + (current?.wrong ?? 0);
    final avgMs = current == null || answered == 0
        ? elapsedMs
        : ((current.avgMs * answered) + elapsedMs) ~/ (answered + 1);

    final companion = ProgressCompanion(
      personId: Value(personId),
      box: Value(correct ? (box + 1).clamp(1, 5) : (box - 2).clamp(1, 5)),
      correct: Value((current?.correct ?? 0) + (correct ? 1 : 0)),
      wrong: Value((current?.wrong ?? 0) + (correct ? 0 : 1)),
      streak: Value(correct ? (current?.streak ?? 0) + 1 : 0),
      lastSeenAt: Value(DateTime.now()),
      avgMs: Value(avgMs),
    );
    await into(progress).insertOnConflictUpdate(companion);
  }

  /// Records that [confusedWithId] was picked when [personId] was shown.
  Future<void> recordConfusion({required int personId, required int confusedWithId}) async {
    await customStatement(
      'INSERT INTO confusions (person_id, confused_with_id, count) VALUES (?, ?, 1) '
      'ON CONFLICT(person_id, confused_with_id) DO UPDATE SET count = count + 1',
      [personId, confusedWithId],
    );
  }

  Future<List<Confusion>> confusionsFor(int personId) =>
      (select(confusions)..where((c) => c.personId.equals(personId))..orderBy([(c) => OrderingTerm.desc(c.count)]))
          .get();

  Future<List<Confusion>> confusionsForSet(int setId) {
    final query = select(confusions).join([
      innerJoin(persons, persons.id.equalsExp(confusions.personId)),
    ])
      ..where(persons.setId.equals(setId))
      ..orderBy([OrderingTerm.desc(confusions.count)]);
    return query.map((row) => row.readTable(confusions)).get();
  }
}
