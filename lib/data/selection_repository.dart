import 'dart:math';

import 'package:drift/drift.dart';

import '../draw/draw_settings.dart';
import '../draw/selection_engine.dart';
import 'database.dart';

/// Who is still up, and why the others are not.
class PoolState {
  const PoolState({
    required this.available,
    required this.total,
    required this.drawn,
    required this.absent,
  });

  /// Still to be drawn this round, in class order.
  final List<Student> available;

  /// Active students in the class — the denominator of "17 von 24".
  final int total;

  /// Already drawn since the last reset.
  final Set<int> drawn;

  /// Marked absent today. They produce no draw event and are up again next
  /// lesson, which is why attendance has to be set before drawing rather than
  /// corrected afterwards.
  final Set<int> absent;

  bool get isEmpty => available.isEmpty;
}

/// The database side of drawing: the pool is derived, never stored.
///
/// "Without replacement" is the draw log plus the reset markers, not a flag on
/// the student. That is what makes it survive a restart, an undo a delete, and
/// a new round a single insert instead of a mass update.
class SelectionRepository {
  SelectionRepository(this._db);

  final AppDatabase _db;

  /// Pool = active students − drawn since the last reset − absent today.
  Future<PoolState> pool(
    int classId, {
    String poolKey = defaultPoolKey,
    DateTime? today,
  }) async {
    final students = await _db.studentsInClass(classId);
    final drawn = await drawnSinceReset(classId, poolKey: poolKey);
    final absent = await absencesOn(classId, today ?? DateTime.now());

    return PoolState(
      available: [
        for (final student in students)
          if (!drawn.contains(student.id) && !absent.contains(student.id)) student,
      ],
      total: students.length,
      drawn: drawn,
      absent: absent,
    );
  }

  /// When the current round began. The epoch if it never has.
  Future<DateTime> lastReset(int classId, {String poolKey = defaultPoolKey}) async {
    final row = await (_db.select(_db.poolResets)
          ..where((r) => r.classId.equals(classId) & r.poolKey.equals(poolKey))
          ..orderBy([(r) => OrderingTerm.desc(r.resetAt)])
          ..limit(1))
        .getSingleOrNull();
    return row?.resetAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<Set<int>> drawnSinceReset(int classId, {String poolKey = defaultPoolKey}) async {
    final since = await lastReset(classId, poolKey: poolKey);
    final rows = await (_db.select(_db.drawEvents)
          ..where((d) =>
              d.classId.equals(classId) & d.poolKey.equals(poolKey) & d.drawnAt.isBiggerThanValue(since)))
        .get();
    return {for (final row in rows) row.studentId};
  }

  Future<Set<int>> absencesOn(int classId, DateTime day) async {
    final rows = await (_db.select(_db.absences)
          ..where((a) => a.classId.equals(classId) & a.day.equals(dayNumber(day))))
        .get();
    return {for (final row in rows) row.studentId};
  }

  /// Absence is stored, presence is the default — so marking someone present
  /// again is a delete.
  Future<void> setAbsent({
    required int classId,
    required int studentId,
    required DateTime day,
    required bool absent,
  }) async {
    if (absent) {
      await _db.into(_db.absences).insertOnConflictUpdate(AbsencesCompanion.insert(
            classId: classId,
            studentId: studentId,
            day: dayNumber(day),
          ));
    } else {
      await (_db.delete(_db.absences)
            ..where((a) =>
                a.classId.equals(classId) & a.studentId.equals(studentId) & a.day.equals(dayNumber(day))))
          .go();
    }
  }

  /// How often each student has been drawn in this pool, over its whole
  /// history. Counted per pool, so being the one who always does the board duty
  /// does not make someone rarer in lessons.
  Future<Map<int, int>> drawCounts(int classId, {String poolKey = defaultPoolKey}) async {
    final count = _db.drawEvents.id.count();
    final query = _db.selectOnly(_db.drawEvents)
      ..addColumns([_db.drawEvents.studentId, count])
      ..where(_db.drawEvents.classId.equals(classId) & _db.drawEvents.poolKey.equals(poolKey))
      ..groupBy([_db.drawEvents.studentId]);

    final rows = await query.get();
    return {for (final row in rows) row.read(_db.drawEvents.studentId)!: row.read(count)!};
  }

  /// The most recently drawn students, newest first, across rounds.
  Future<List<int>> recentlyDrawn(
    int classId, {
    String poolKey = defaultPoolKey,
    int limit = 3,
  }) async {
    if (limit <= 0) return const [];
    final rows = await (_db.select(_db.drawEvents)
          ..where((d) => d.classId.equals(classId) & d.poolKey.equals(poolKey))
          ..orderBy([(d) => OrderingTerm.desc(d.drawnAt), (d) => OrderingTerm.desc(d.id)])
          ..limit(limit))
        .get();
    return [for (final row in rows) row.studentId];
  }

  /// Draws and records it. Returns an empty list when there is nobody left —
  /// starting a new round is the caller's decision, not this one's.
  Future<List<Student>> draw({
    required int classId,
    String poolKey = defaultPoolKey,
    DrawSettings settings = const DrawSettings(),
    DateTime? now,
    Random? random,
  }) async {
    final at = await _stampAfterReset(classId, poolKey, now ?? DateTime.now());
    final state = await pool(classId, poolKey: poolKey, today: at);

    // Repetition only stops the log from filtering the pool. Absences still
    // filter it, and the events are written either way.
    final candidates = settings.replacement
        ? [
            for (final student in await _db.studentsInClass(classId))
              if (!state.absent.contains(student.id)) student,
          ]
        : state.available;
    if (candidates.isEmpty) return const [];

    final counts = await drawCounts(classId, poolKey: poolKey);
    final picked = SelectionEngine.pick(
      pool: [
        for (final student in candidates)
          DrawCandidate(studentId: student.id, drawCount: counts[student.id] ?? 0),
      ],
      recent: await recentlyDrawn(classId, poolKey: poolKey, limit: settings.cooldown),
      settings: settings,
      random: random,
    );

    await _db.batch((batch) => batch.insertAll(_db.drawEvents, [
          for (final studentId in picked)
            DrawEventsCompanion.insert(
              classId: classId,
              studentId: studentId,
              poolKey: Value(poolKey),
              drawnAt: at,
            ),
        ]));

    final byId = {for (final student in candidates) student.id: student};
    return [for (final studentId in picked) byId[studentId]!];
  }

  /// Starts a new round. One insert, so the log before it stays readable for
  /// the fairness weighting and the statistics can still see where a round
  /// ended.
  Future<void> startNewRound(
    int classId, {
    String poolKey = defaultPoolKey,
    bool auto = false,
    DateTime? at,
  }) async {
    await _db.into(_db.poolResets).insert(PoolResetsCompanion.insert(
          classId: classId,
          poolKey: Value(poolKey),
          resetAt: at ?? DateTime.now(),
          auto: Value(auto),
        ));
  }

  /// Takes back the last draw, all of it if several were drawn at once.
  /// Returns false when there was nothing to take back.
  ///
  /// Deleting rather than marking: the log should show what happened in the
  /// lesson, not every mistyped tap. Two separate draws within the same second
  /// are indistinguishable here, because drift stores timestamps to the second
  /// — an undo would then take back both.
  Future<bool> undoLastDraw(int classId, {String poolKey = defaultPoolKey}) async {
    final last = await (_db.select(_db.drawEvents)
          ..where((d) => d.classId.equals(classId) & d.poolKey.equals(poolKey))
          ..orderBy([(d) => OrderingTerm.desc(d.drawnAt), (d) => OrderingTerm.desc(d.id)])
          ..limit(1))
        .getSingleOrNull();
    if (last == null) return false;

    await (_db.delete(_db.drawEvents)
          ..where((d) =>
              d.classId.equals(classId) & d.poolKey.equals(poolKey) & d.drawnAt.equals(last.drawnAt)))
        .go();
    return true;
  }

  /// Keeps a draw strictly newer than the reset that precedes it.
  ///
  /// The pool asks for events *after* the last reset, and drift stores
  /// timestamps to the second. Without this, resetting and drawing within the
  /// same second would leave the drawn student in the pool — and the very
  /// sequence that triggers it, "pool empty, start a new round, draw", is the
  /// common one.
  Future<DateTime> _stampAfterReset(int classId, String poolKey, DateTime now) async {
    final reset = await lastReset(classId, poolKey: poolKey);
    return now.isAfter(reset) ? now : reset.add(const Duration(seconds: 1));
  }
}
