import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/groups/partition.dart';

void main() {
  List<int> sizesOf(PartitionResult result) => (result as Partition).sizes;

  /// The table from KONZEPT-zufall-und-gruppen.md, section 9 — the edges where
  /// this kind of algorithm typically falls over.
  group('the cases from the concept', () {
    test('24 into groups of exactly 4 gives 6×4', () {
      expect(sizesOf(partition(students: 24, spec: const BySize(4))), [4, 4, 4, 4, 4, 4]);
    });

    test('25 into groups of 4, evenly, spreads the leftover instead of isolating it', () {
      final sizes = sizesOf(partition(students: 25, spec: const BySize(4)));
      expect(sizes, [5, 4, 4, 4, 4, 4]);
      expect(sizes.reduce((a, b) => a + b), 25);
      expect(sizes.reduce((a, b) => a > b ? a : b) - sizes.reduce((a, b) => a < b ? a : b), 1);
    });

    test('25 into groups of 4, unevenly, leaves the single person standing', () {
      expect(
        sizesOf(partition(students: 25, spec: const BySize(4), even: false)),
        [4, 4, 4, 4, 4, 4, 1],
      );
    });

    test('23 into groups of 2–3 evenly gives 5×3 + 4×2', () {
      final sizes = sizesOf(partition(students: 23, spec: const BySizeRange(2, 3)));
      expect(sizes.where((s) => s == 3).length, 5);
      expect(sizes.where((s) => s == 2).length, 4);
      expect(defaultGroupCount(23, 2, 3), 9);
    });

    test('7 into groups of 4–5 is impossible and says what would work', () {
      final result = partition(students: 7, spec: const BySizeRange(4, 5));
      expect(result, isA<PartitionImpossible>());

      final problem = result as PartitionImpossible;
      expect(problem.message, contains('7 SuS'));
      expect(problem.suggestion, isNotEmpty, reason: 'never "not possible" on its own');
      expect(problem.suggestion, contains('3–5'));
    });

    test('1 into groups of 2–3 fails with something readable', () {
      final result = partition(students: 1, spec: const BySizeRange(2, 3));
      expect(result, isA<PartitionImpossible>());
      expect((result as PartitionImpossible).message, contains('1 SuS'));
    });

    test('0 students is an empty split, not a crash', () {
      for (final spec in [const ByGroupCount(6), const BySize(4), const BySizeRange(2, 3)]) {
        expect(sizesOf(partition(students: 0, spec: spec)), isEmpty);
      }
    });

    test('30 into 6 groups gives 6×5', () {
      expect(sizesOf(partition(students: 30, spec: const ByGroupCount(6))), [5, 5, 5, 5, 5, 5]);
    });

    test('24 into 5 groups gives 4×5 + 1×4', () {
      expect(sizesOf(partition(students: 24, spec: const ByGroupCount(5))), [5, 5, 5, 5, 4]);
    });
  });

  group('valid group counts', () {
    test('are ⌈n/max⌉ to ⌊n/min⌋', () {
      expect(validGroupCounts(23, 2, 3), [8, 9, 10, 11]);
    });

    test('are empty when the range cannot be met', () {
      expect(validGroupCounts(7, 4, 5), isEmpty);
      expect(validGroupCounts(1, 2, 3), isEmpty);
    });

    test('the default lands nearest the middle of the range', () {
      expect(defaultGroupCount(23, 2, 3), 9, reason: '23 / 2.5 = 9.2');
      expect(defaultGroupCount(24, 4, 4), 6);
    });

    test('the default stays inside the valid set even when the middle points outside', () {
      final valid = validGroupCounts(10, 3, 10);
      final chosen = defaultGroupCount(10, 3, 10)!;
      expect(valid, contains(chosen));
    });
  });

  group('every split accounts for everyone', () {
    test('across a wide range of class sizes and group counts', () {
      for (var n = 1; n <= 40; n++) {
        for (var g = 1; g <= n; g++) {
          final result = partition(students: n, spec: ByGroupCount(g));
          final sizes = sizesOf(result);

          expect(sizes.reduce((a, b) => a + b), n, reason: 'n=$n g=$g loses someone');
          expect(sizes.length, g, reason: 'n=$n g=$g has the wrong number of groups');
          expect(sizes.every((s) => s > 0), isTrue, reason: 'n=$n g=$g has an empty group');
          expect(sizes.first - sizes.last, lessThanOrEqualTo(1), reason: 'n=$n g=$g is lopsided');
        }
      }
    });

    test('for size ranges too, evenly or not', () {
      for (var n = 1; n <= 40; n++) {
        for (final even in [true, false]) {
          final result = partition(students: n, spec: const BySizeRange(2, 4), even: even);
          if (result is! Partition) continue;
          expect(result.students, n, reason: 'n=$n even=$even loses someone');
          expect(result.sizes.every((s) => s > 0), isTrue);
        }
      }
    });
  });

  group('impossible splits name a way out', () {
    test('more groups than students', () {
      final result = partition(students: 4, spec: const ByGroupCount(6));
      expect(result, isA<PartitionImpossible>());
      expect((result as PartitionImpossible).suggestion, contains('4 Gruppen'));
    });

    test('a group larger than the class', () {
      final result = partition(students: 3, spec: const BySize(5));
      expect(result, isA<PartitionImpossible>());
      expect((result as PartitionImpossible).suggestion, contains('3'));
    });

    test('an upside-down range', () {
      expect(partition(students: 10, spec: const BySizeRange(5, 3)), isA<PartitionImpossible>());
    });
  });

  group('describe', () {
    test('reads as a count when the groups are equal', () {
      expect(const Partition([4, 4, 4]).describe(), '3 Gruppen à 4');
      expect(const Partition([4]).describe(), '1 Gruppe à 4');
    });

    test('spells out the mix when they are not', () {
      expect(const Partition([3, 3, 3, 3, 3, 2, 2, 2, 2]).describe(), '5×3 + 4×2');
    });

    test('says so when there is nothing to split', () {
      expect(const Partition([]).describe(), 'Keine Gruppen');
    });
  });
}
