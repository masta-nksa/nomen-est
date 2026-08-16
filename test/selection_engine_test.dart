import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/draw/draw_settings.dart';
import 'package:nomen_est/draw/selection_engine.dart';

void main() {
  List<DrawCandidate> plainPool(int count) => [
        for (var i = 1; i <= count; i++) DrawCandidate(studentId: i),
      ];

  List<int> pick(
    List<DrawCandidate> pool, {
    List<int> recent = const [],
    DrawSettings settings = const DrawSettings(),
    int seed = 42,
  }) =>
      SelectionEngine.pick(
        pool: pool,
        recent: recent,
        settings: settings,
        random: Random(seed),
      );

  group('edge cases', () {
    test('an empty pool draws nobody instead of throwing', () {
      expect(pick([]), isEmpty);
    });

    test('a pool of one draws that one', () {
      expect(pick(plainPool(1)), [1]);
    });

    test('drawing more than the pool holds returns the whole pool', () {
      final drawn = pick(plainPool(3), settings: const DrawSettings(count: 5));
      expect(drawn.toSet(), {1, 2, 3});
    });

    test('one draw never returns the same student twice', () {
      for (var seed = 0; seed < 20; seed++) {
        final drawn = pick(plainPool(6), settings: const DrawSettings(count: 4), seed: seed);
        expect(drawn.toSet(), hasLength(4));
      }
    });
  });

  group('cooldown', () {
    test('holds back the last k', () {
      for (var seed = 0; seed < 20; seed++) {
        final drawn = pick(plainPool(8), recent: [1, 2, 3], seed: seed);
        expect(drawn.single, isNot(anyOf(1, 2, 3)));
      }
    });

    test('only looks at the last k, not the whole history', () {
      for (var seed = 0; seed < 20; seed++) {
        final drawn = pick(
          plainPool(5),
          recent: [1, 2, 3, 4],
          settings: const DrawSettings(cooldown: 2),
          seed: seed,
        );
        expect(drawn.single, isNot(anyOf(1, 2)));
      }
    });

    /// Repeating someone beats drawing nobody — the whole point of the cooldown
    /// being soft.
    test('gives way when it would leave nobody', () {
      final drawn = pick(plainPool(2), recent: [1, 2]);
      expect(drawn, hasLength(1));
      expect(drawn.single, anyOf(1, 2));
    });

    test('a cooldown of zero blocks nobody', () {
      final drawn = pick(
        [const DrawCandidate(studentId: 1)],
        recent: [1],
        settings: const DrawSettings(cooldown: 0),
      );
      expect(drawn, [1]);
    });
  });

  group('fairness weighting', () {
    List<DrawCandidate> lopsided() => [
          const DrawCandidate(studentId: 1, drawCount: 0),
          for (var i = 2; i <= 6; i++) DrawCandidate(studentId: i, drawCount: 10),
        ];

    int countPicks(double alpha, {int rounds = 400}) {
      var rare = 0;
      for (var seed = 0; seed < rounds; seed++) {
        if (pick(lopsided(), settings: DrawSettings(alpha: alpha), seed: seed).single == 1) rare++;
      }
      return rare;
    }

    test('alpha 0 draws uniformly, ignoring the counts', () {
      expect(countPicks(0), closeTo(400 / 6, 30));
    });

    test('alpha 1 favours the student who has come up least', () {
      expect(countPicks(1), greaterThan(400 / 6 * 2));
    });

    test('alpha 2 favours them more sharply than alpha 1', () {
      expect(countPicks(2), greaterThan(countPicks(1)));
    });

    test('equal counts stay uniform whatever alpha says', () {
      var first = 0;
      for (var seed = 0; seed < 300; seed++) {
        if (pick(plainPool(4), settings: const DrawSettings(alpha: 2), seed: seed).single == 1) first++;
      }
      expect(first, closeTo(300 / 4, 25));
    });

    /// Nobody is ever excluded outright — a student drawn far more than the
    /// rest still has a chance, or the draw would stop feeling like one.
    test('even the most-drawn student keeps a chance', () {
      var seen = false;
      for (var seed = 0; seed < 300 && !seen; seed++) {
        if (pick(lopsided(), settings: const DrawSettings(alpha: 2), seed: seed).single != 1) seen = true;
      }
      expect(seen, isTrue);
    });
  });

  test('the same seed draws the same student', () {
    expect(pick(plainPool(20), seed: 7), pick(plainPool(20), seed: 7));
  });
}
