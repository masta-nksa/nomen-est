import 'dart:math';

import 'draw_settings.dart';

/// One student, as far as the draw cares.
class DrawCandidate {
  const DrawCandidate({required this.studentId, this.drawCount = 0});

  final int studentId;

  /// How often this student has been drawn in this pool, over its whole
  /// history — not just the current round. Fairness that forgets at every
  /// reset is not fairness.
  final int drawCount;
}

/// Picks who is up next.
///
/// Deliberately free of the database: the pool, the counts and the recent
/// draws come in as plain data, so every rule here can be tested without a
/// schema. The repository owns the queries, this owns the decision.
class SelectionEngine {
  const SelectionEngine._();

  /// Returns up to [DrawSettings.count] student ids, never repeating within one
  /// call, or an empty list if [pool] is empty.
  ///
  /// [recent] holds the most recently drawn students, newest first.
  static List<int> pick({
    required List<DrawCandidate> pool,
    required List<int> recent,
    DrawSettings settings = const DrawSettings(),
    Random? random,
  }) {
    if (pool.isEmpty) return const [];
    final rng = random ?? Random();

    // The cooldown is soft on purpose: holding back the last few is worth less
    // than always having someone to call on.
    final blocked = recent.take(settings.cooldown).toSet();
    var candidates = [
      for (final candidate in pool)
        if (!blocked.contains(candidate.studentId)) candidate,
    ];
    if (candidates.isEmpty) candidates = [...pool];

    // maxCount is taken once, over the starting field. Recomputing it after
    // every pick would let the weights drift within a single multi-draw.
    final maxCount = candidates.map((c) => c.drawCount).reduce(max);
    final weights = <int, double>{
      for (final c in candidates) c.studentId: pow(1 + maxCount - c.drawCount, settings.alpha).toDouble(),
    };

    final wanted = min(settings.count, candidates.length);
    final picked = <int>[];
    for (var i = 0; i < wanted; i++) {
      final index = _weightedIndex([for (final c in candidates) weights[c.studentId]!], rng);
      picked.add(candidates.removeAt(index).studentId);
    }
    return picked;
  }

  static int _weightedIndex(List<double> weights, Random rng) {
    final total = weights.fold(0.0, (a, b) => a + b);
    var roll = rng.nextDouble() * total;
    for (var i = 0; i < weights.length; i++) {
      roll -= weights[i];
      if (roll <= 0) return i;
    }
    return weights.length - 1;
  }
}
