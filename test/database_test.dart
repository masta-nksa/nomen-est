import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/data/database.dart';

import 'index_names.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> seedClass({String label = 'Testklasse', int count = 3}) => db.createClass(
        label: label,
        sourceFile: 'test.pdf',
        students: [
          for (var i = 0; i < count; i++)
            (
              displayName: 'Nachname$i Vorname$i',
              firstName: 'Vorname$i',
              lastName: 'Nachname$i',
              jpegBytes: Uint8List.fromList([i, i, i]),
            ),
        ],
      );

  Future<void> draw(int classId, int studentId) => db.into(db.drawEvents).insert(
        DrawEventsCompanion.insert(
          classId: classId,
          studentId: studentId,
          drawnAt: DateTime(2026, 8, 16, 10),
        ),
      );

  test('creating a class gives every student a progress row in box 1', () async {
    final classId = await seedClass();
    final students = await db.studentsInClass(classId);
    final progress = await db.progressForClass(classId);

    expect(students, hasLength(3));
    expect(progress, hasLength(3));
    expect(progress.every((p) => p.box == 1), isTrue);
    expect(students.map((s) => s.orderIndex), [0, 1, 2]);
    expect(students.every((s) => s.active), isTrue);
  });

  test('deleting a class removes its students and their progress', () async {
    final classId = await seedClass();
    await db.deleteClass(classId);

    expect(await db.studentsInClass(classId), isEmpty);
    expect(await db.progressForClass(classId), isEmpty);
  });

  test('deleting one class leaves the others untouched', () async {
    final keep = await seedClass(label: 'Bleibt');
    final remove = await seedClass(label: 'Weg');
    await db.deleteClass(remove);

    expect(await db.studentsInClass(keep), hasLength(3));
    expect(await db.studentsInClass(remove), isEmpty);
  });

  /// Foreign keys are on, so anything referencing a class has to cascade —
  /// otherwise "Klasse löschen" starts failing as soon as one draw exists.
  test('deleting a class takes its lesson history with it', () async {
    final classId = await seedClass();
    final students = await db.studentsInClass(classId);
    await draw(classId, students[0].id);
    await db.into(db.absences).insert(AbsencesCompanion.insert(
          classId: classId,
          studentId: students[1].id,
          day: dayNumber(DateTime(2026, 8, 16)),
        ));
    await db.into(db.poolResets).insert(
          PoolResetsCompanion.insert(classId: classId, resetAt: DateTime(2026, 8, 16)),
        );
    final groupSetId = await db.into(db.groupSets).insert(GroupSetsCompanion.insert(
          classId: classId,
          label: 'Projekt',
          createdAt: DateTime(2026, 8, 16),
        ));
    await db.into(db.groupMembers).insert(GroupMembersCompanion.insert(
          groupSetId: groupSetId,
          groupIndex: 0,
          studentId: students[0].id,
        ));
    await db.into(db.pairCounts).insert(PairCountsCompanion.insert(
          classId: classId,
          studentA: students[0].id,
          studentB: students[1].id,
          count: const Value(1),
        ));
    await db.into(db.groupConstraints).insert(GroupConstraintsCompanion.insert(
          classId: classId,
          studentA: students[0].id,
          studentB: students[2].id,
          kind: ConstraintKind.apart,
        ));

    await db.deleteClass(classId);

    expect(await db.select(db.drawEvents).get(), isEmpty);
    expect(await db.select(db.absences).get(), isEmpty);
    expect(await db.select(db.poolResets).get(), isEmpty);
    expect(await db.select(db.groupSets).get(), isEmpty);
    expect(await db.select(db.groupMembers).get(), isEmpty, reason: 'cascades through the group set');
    expect(await db.select(db.pairCounts).get(), isEmpty);
    expect(await db.select(db.groupConstraints).get(), isEmpty);
  });

  test('an inactive student leaves the pool but keeps their history', () async {
    final classId = await seedClass();
    final students = await db.studentsInClass(classId);
    await draw(classId, students[0].id);

    await (db.update(db.students)..where((s) => s.id.equals(students[0].id)))
        .write(const StudentsCompanion(active: Value(false)));

    expect(await db.studentsInClass(classId), hasLength(2));
    expect(await db.studentsInClass(classId, includeInactive: true), hasLength(3));
    expect(await db.select(db.drawEvents).get(), hasLength(1),
        reason: 'the draw happened, so the log must still say so');
  });

  group('recordAnswer', () {
    test('a correct answer moves up a box and counts the streak', () async {
      final classId = await seedClass();
      final student = (await db.studentsInClass(classId)).first;

      await db.recordAnswer(studentId: student.id, correct: true, elapsedMs: 1000);
      var progress = (await db.progressForClass(classId)).firstWhere((p) => p.studentId == student.id);
      expect(progress.box, 2);
      expect(progress.correct, 1);
      expect(progress.streak, 1);
      expect(progress.avgMs, 1000);

      await db.recordAnswer(studentId: student.id, correct: true, elapsedMs: 3000);
      progress = (await db.progressForClass(classId)).firstWhere((p) => p.studentId == student.id);
      expect(progress.box, 3);
      expect(progress.streak, 2);
      expect(progress.avgMs, 2000, reason: 'running average over both answers');
    });

    test('a wrong answer drops two boxes and resets the streak', () async {
      final classId = await seedClass();
      final student = (await db.studentsInClass(classId)).first;

      for (var i = 0; i < 4; i++) {
        await db.recordAnswer(studentId: student.id, correct: true, elapsedMs: 500);
      }
      expect((await db.progressForClass(classId)).firstWhere((p) => p.studentId == student.id).box, 5);

      await db.recordAnswer(studentId: student.id, correct: false, elapsedMs: 500);
      final progress = (await db.progressForClass(classId)).firstWhere((p) => p.studentId == student.id);
      expect(progress.box, 3);
      expect(progress.streak, 0);
      expect(progress.wrong, 1);
    });

    test('boxes stay within 1..5', () async {
      final classId = await seedClass();
      final student = (await db.studentsInClass(classId)).first;

      for (var i = 0; i < 10; i++) {
        await db.recordAnswer(studentId: student.id, correct: true, elapsedMs: 500);
      }
      expect((await db.progressForClass(classId)).firstWhere((p) => p.studentId == student.id).box, 5);

      for (var i = 0; i < 10; i++) {
        await db.recordAnswer(studentId: student.id, correct: false, elapsedMs: 500);
      }
      expect((await db.progressForClass(classId)).firstWhere((p) => p.studentId == student.id).box, 1);
    });
  });

  group('recordConfusion', () {
    test('counts up on repeat confusions of the same pair', () async {
      final classId = await seedClass();
      final students = await db.studentsInClass(classId);

      await db.recordConfusion(studentId: students[0].id, confusedWithId: students[1].id);
      await db.recordConfusion(studentId: students[0].id, confusedWithId: students[1].id);
      await db.recordConfusion(studentId: students[0].id, confusedWithId: students[2].id);

      final confusions = await db.confusionsFor(students[0].id);
      expect(confusions, hasLength(2));
      expect(confusions.first.confusedWithId, students[1].id, reason: 'sorted by count');
      expect(confusions.first.count, 2);
    });

    test('confusions are directional', () async {
      final classId = await seedClass();
      final students = await db.studentsInClass(classId);

      await db.recordConfusion(studentId: students[0].id, confusedWithId: students[1].id);

      expect(await db.confusionsFor(students[0].id), hasLength(1));
      expect(await db.confusionsFor(students[1].id), isEmpty);
    });
  });

  group('resets', () {
    /// The point of keeping four of these: forgetting the quiz results must not
    /// also forget who has already been called on this term.
    test('resetProgress clears boxes and confusions but keeps everything else', () async {
      final classId = await seedClass();
      final students = await db.studentsInClass(classId);
      await db.recordAnswer(studentId: students[0].id, correct: true, elapsedMs: 500);
      await db.recordConfusion(studentId: students[0].id, confusedWithId: students[1].id);
      await draw(classId, students[0].id);

      await db.resetProgress(classId);

      expect(await db.studentsInClass(classId), hasLength(3));
      expect((await db.progressForClass(classId)).every((p) => p.box == 1 && p.correct == 0), isTrue);
      expect(await db.confusionsFor(students[0].id), isEmpty);
      expect(await db.select(db.drawEvents).get(), hasLength(1), reason: 'draws are not learning progress');
    });

    test('resetDrawHistory empties the pool log and its round markers', () async {
      final classId = await seedClass();
      final students = await db.studentsInClass(classId);
      await draw(classId, students[0].id);
      await db.into(db.poolResets).insert(
            PoolResetsCompanion.insert(classId: classId, resetAt: DateTime(2026, 8, 16)),
          );
      await db.recordAnswer(studentId: students[0].id, correct: true, elapsedMs: 500);

      await db.resetDrawHistory(classId);

      expect(await db.select(db.drawEvents).get(), isEmpty);
      expect(await db.select(db.poolResets).get(), isEmpty);
      expect((await db.progressForClass(classId)).firstWhere((p) => p.studentId == students[0].id).box, 2,
          reason: 'the learning progress is a different history');
    });

    test('resetAbsences makes everyone present again', () async {
      final classId = await seedClass();
      final students = await db.studentsInClass(classId);
      await db.into(db.absences).insert(AbsencesCompanion.insert(
            classId: classId,
            studentId: students[0].id,
            day: dayNumber(DateTime(2026, 8, 16)),
          ));

      await db.resetAbsences(classId);

      expect(await db.select(db.absences).get(), isEmpty);
    });

    test('resetGroupHistory drops groupings and pairings but keeps the rules', () async {
      final classId = await seedClass();
      final students = await db.studentsInClass(classId);
      final groupSetId = await db.into(db.groupSets).insert(GroupSetsCompanion.insert(
            classId: classId,
            label: 'Projekt',
            createdAt: DateTime(2026, 8, 16),
          ));
      await db.into(db.groupMembers).insert(GroupMembersCompanion.insert(
            groupSetId: groupSetId,
            groupIndex: 0,
            studentId: students[0].id,
          ));
      await db.into(db.pairCounts).insert(PairCountsCompanion.insert(
            classId: classId,
            studentA: students[0].id,
            studentB: students[1].id,
            count: const Value(3),
          ));
      await db.into(db.groupConstraints).insert(GroupConstraintsCompanion.insert(
            classId: classId,
            studentA: students[0].id,
            studentB: students[2].id,
            kind: ConstraintKind.apart,
          ));

      await db.resetGroupHistory(classId);

      expect(await db.select(db.groupSets).get(), isEmpty);
      expect(await db.select(db.groupMembers).get(), isEmpty);
      expect(await db.select(db.pairCounts).get(), isEmpty);
      expect(await db.select(db.groupConstraints).get(), hasLength(1),
          reason: '"A and B not together" is a decision, not history');
    });
  });

  test('renaming a class keeps its students', () async {
    final classId = await seedClass(label: 'Alt');
    await db.renameClass(classId, 'Neu');

    final classes = await db.watchClasses().first;
    expect(classes.single.label, 'Neu');
    expect(await db.studentsInClass(classId), hasLength(3));
  });

  test('settings are a plain key-value store', () async {
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'random.replacement', value: 'false'));
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: 'random.replacement', value: 'true'),
        );

    final rows = await db.select(db.settings).get();
    expect(rows.single.value, 'true');
  });

  test('a fresh database has the indices the pool queries rely on', () async {
    expect(await indexNames(db), [
      'idx_absence_day',
      'idx_draw_class_pool_time',
      'idx_draw_student',
    ]);
  });

  test('dayNumber is a plain calendar day', () {
    expect(dayNumber(DateTime(2026, 8, 16, 23, 30)), 20260816);
    expect(dayNumber(DateTime(2026, 1, 1)), 20260101);
  });
}
