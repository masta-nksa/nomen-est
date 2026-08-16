import 'dart:math';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/data/database.dart';
import 'package:nomen_est/data/selection_repository.dart';
import 'package:nomen_est/draw/draw_settings.dart';

void main() {
  late AppDatabase db;
  late SelectionRepository repo;
  late int classId;
  late List<Student> students;

  final monday = DateTime(2026, 8, 17, 9);
  final tuesday = DateTime(2026, 8, 18, 9);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SelectionRepository(db);
    classId = await db.createClass(
      label: '2c Mathe',
      sourceFile: 'test.pdf',
      students: [
        for (var i = 0; i < 6; i++)
          (
            displayName: 'Nachname$i Vorname$i',
            firstName: 'Vorname$i',
            lastName: 'Nachname$i',
            jpegBytes: Uint8List.fromList([i]),
          ),
      ],
    );
    students = await db.studentsInClass(classId);
  });
  tearDown(() => db.close());

  /// Draws one, a fixed second apart so the order in the log is unambiguous.
  Future<Student?> drawOne({DrawSettings settings = const DrawSettings(), int minute = 0}) async {
    final drawn = await repo.draw(
      classId: classId,
      settings: settings,
      now: monday.add(Duration(minutes: minute)),
      random: Random(minute + 1),
    );
    return drawn.singleOrNull;
  }

  group('pool', () {
    test('starts as the whole class', () async {
      final state = await repo.pool(classId, today: monday);
      expect(state.available, hasLength(6));
      expect(state.total, 6);
      expect(state.drawn, isEmpty);
    });

    test('shrinks with every draw', () async {
      await drawOne(minute: 1);
      await drawOne(minute: 2);

      final state = await repo.pool(classId, today: monday);
      expect(state.available, hasLength(4));
      expect(state.drawn, hasLength(2));
    });

    test('is derived, so it survives a restart', () async {
      final first = await drawOne(minute: 1);

      // A second repository on the same database stands in for a fresh app
      // start: nothing is cached, the pool is recomputed from the log.
      final afterRestart = await SelectionRepository(db).pool(classId, today: monday);
      expect(afterRestart.available.map((s) => s.id), isNot(contains(first!.id)));
      expect(afterRestart.available, hasLength(5));
    });

    test('empties once everyone has had a turn', () async {
      for (var i = 1; i <= 6; i++) {
        expect(await drawOne(minute: i), isNotNull);
      }
      expect((await repo.pool(classId, today: monday)).isEmpty, isTrue);
      expect(await drawOne(minute: 7), isNull, reason: 'an empty pool draws nobody rather than repeating');
    });

    test('leaves out students who are no longer in the class', () async {
      await db.customStatement('UPDATE students SET active = 0 WHERE id = ?', [students.first.id]);

      final state = await repo.pool(classId, today: monday);
      expect(state.total, 5);
      expect(state.available.map((s) => s.id), isNot(contains(students.first.id)));
    });
  });

  group('absences', () {
    setUp(() => repo.setAbsent(
          classId: classId,
          studentId: students.first.id,
          day: monday,
          absent: true,
        ));

    test('take someone out of the pool for that day only', () async {
      expect((await repo.pool(classId, today: monday)).available, hasLength(5));
      expect((await repo.pool(classId, today: tuesday)).available, hasLength(6));
    });

    test('the absent are never drawn', () async {
      for (var i = 1; i <= 5; i++) {
        final drawn = await drawOne(minute: i);
        expect(drawn!.id, isNot(students.first.id));
      }
    });

    /// The reason attendance belongs before the draw and not after it: an
    /// absence must not use up a turn.
    test('do not consume the pool — they are up again next lesson', () async {
      for (var i = 1; i <= 5; i++) {
        await drawOne(minute: i);
      }
      expect((await repo.pool(classId, today: monday)).isEmpty, isTrue);

      final nextDay = await repo.pool(classId, today: tuesday);
      expect(nextDay.available.map((s) => s.id), [students.first.id]);
    });

    test('marking someone present again is a delete', () async {
      await repo.setAbsent(classId: classId, studentId: students.first.id, day: monday, absent: false);
      expect((await repo.pool(classId, today: monday)).available, hasLength(6));
    });
  });

  group('repetition', () {
    const withReplacement = DrawSettings(replacement: true, cooldown: 0);

    test('lets the same student come up again', () async {
      // Everyone but one is away, so a draw that filtered by the log would run
      // dry after the first one.
      for (final student in students.skip(1)) {
        await repo.setAbsent(classId: classId, studentId: student.id, day: monday, absent: true);
      }

      final first = await drawOne(settings: withReplacement, minute: 1);
      final second = await drawOne(settings: withReplacement, minute: 2);

      expect(first!.id, students.first.id);
      expect(second!.id, students.first.id);
    });

    /// Without this the statistics get holes and the fairness weighting goes
    /// blind — the mode may not skip the log, only ignore it.
    test('still records every draw', () async {
      await drawOne(settings: withReplacement, minute: 1);
      await drawOne(settings: withReplacement, minute: 2);

      final counts = await repo.drawCounts(classId);
      expect(counts.values.fold(0, (a, b) => a + b), 2);
    });

    /// Worth knowing, and a candidate to revisit: a draw made with repetition
    /// on is still a draw, so switching repetition off afterwards finds those
    /// students used up. The mode decides whether the log filters *this* draw,
    /// not whether the draw is recorded.
    test('a draw made with repetition on still counts once it is off', () async {
      await drawOne(minute: 1);
      await drawOne(settings: withReplacement, minute: 2);

      final state = await repo.pool(classId, today: monday);
      expect(state.drawn, hasLength(2), reason: 'both draws are in the log either way');
    });
  });

  group('new round', () {
    test('refills the pool', () async {
      for (var i = 1; i <= 6; i++) {
        await drawOne(minute: i);
      }
      await repo.startNewRound(classId, at: monday.add(const Duration(minutes: 10)));

      expect((await repo.pool(classId, today: monday)).available, hasLength(6));
    });

    test('keeps the history for the weighting', () async {
      for (var i = 1; i <= 6; i++) {
        await drawOne(minute: i);
      }
      await repo.startNewRound(classId, at: monday.add(const Duration(minutes: 10)));

      final counts = await repo.drawCounts(classId);
      expect(counts.values.fold(0, (a, b) => a + b), 6, reason: 'a reset marks a boundary, it does not erase');
    });

    /// "Pool empty, start a new round, draw" is the common sequence, and drift
    /// stores timestamps to the second — so it has to work even when all three
    /// land in the same one.
    test('a draw in the same second as the reset still counts', () async {
      final at = monday.add(const Duration(minutes: 10));
      await repo.startNewRound(classId, at: at);

      final drawn = await repo.draw(classId: classId, now: at, random: Random(1));
      expect(drawn, hasLength(1));

      final state = await repo.pool(classId, today: monday);
      expect(state.drawn, contains(drawn.single.id));
      expect(state.available, hasLength(5), reason: 'the draw must not fall through the reset boundary');
    });
  });

  group('undo', () {
    test('puts the last student back in the pool', () async {
      final drawn = await drawOne(minute: 1);

      expect(await repo.undoLastDraw(classId), isTrue);
      final state = await repo.pool(classId, today: monday);
      expect(state.available, hasLength(6));
      expect(state.available.map((s) => s.id), contains(drawn!.id));
    });

    test('also removes it from the counts', () async {
      await drawOne(minute: 1);
      await repo.undoLastDraw(classId);

      expect(await repo.drawCounts(classId), isEmpty);
    });

    test('takes back the whole batch of a multiple draw', () async {
      final drawn = await repo.draw(
        classId: classId,
        settings: const DrawSettings(count: 3),
        now: monday,
        random: Random(3),
      );
      expect(drawn, hasLength(3));

      await repo.undoLastDraw(classId);
      expect((await repo.pool(classId, today: monday)).available, hasLength(6));
    });

    test('leaves earlier draws alone', () async {
      await drawOne(minute: 1);
      await drawOne(minute: 2);

      await repo.undoLastDraw(classId);
      expect((await repo.pool(classId, today: monday)).drawn, hasLength(1));
    });

    test('reports when there is nothing to undo', () async {
      expect(await repo.undoLastDraw(classId), isFalse);
    });
  });

  group('pools are independent', () {
    test('a draw in one does not consume the other', () async {
      await repo.draw(classId: classId, poolKey: 'tafeldienst', now: monday, random: Random(1));

      expect((await repo.pool(classId, today: monday)).available, hasLength(6));
      expect((await repo.pool(classId, poolKey: 'tafeldienst', today: monday)).available, hasLength(5));
    });

    test('the counts are kept apart', () async {
      await repo.draw(classId: classId, poolKey: 'tafeldienst', now: monday, random: Random(1));

      expect(await repo.drawCounts(classId), isEmpty);
      expect(await repo.drawCounts(classId, poolKey: 'tafeldienst'), hasLength(1));
    });
  });
}
