import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/groups/group_builder.dart';

void main() {
  List<int> classOf(int n) => [for (var i = 1; i <= n; i++) i];

  group('assignment', () {
    test('places everyone exactly once', () {
      final groups = GroupBuilder.assign(
        studentIds: classOf(24),
        sizes: const [4, 4, 4, 4, 4, 4],
        random: Random(1),
      );

      expect(groups, hasLength(6));
      expect(groups.every((g) => g.length == 4), isTrue);
      expect(groups.expand((g) => g).toSet(), classOf(24).toSet());
      expect(groups.expand((g) => g).length, 24, reason: 'nobody in two groups at once');
    });

    test('honours uneven sizes', () {
      final groups = GroupBuilder.assign(
        studentIds: classOf(24),
        sizes: const [5, 5, 5, 5, 4],
        random: Random(2),
      );
      expect(groups.map((g) => g.length), [5, 5, 5, 5, 4]);
    });

    test('a different seed gives a different split', () {
      final a = GroupBuilder.assign(studentIds: classOf(20), sizes: const [5, 5, 5, 5], random: Random(1));
      final b = GroupBuilder.assign(studentIds: classOf(20), sizes: const [5, 5, 5, 5], random: Random(2));
      expect(a, isNot(b));
    });

    test('the same seed gives the same split', () {
      final a = GroupBuilder.assign(studentIds: classOf(20), sizes: const [5, 5, 5, 5], random: Random(7));
      final b = GroupBuilder.assign(studentIds: classOf(20), sizes: const [5, 5, 5, 5], random: Random(7));
      expect(a, b);
    });

    test('an empty class gives empty groups rather than an error', () {
      expect(GroupBuilder.assign(studentIds: const [], sizes: const []), isEmpty);
    });
  });

  group('pinning', () {
    test('a pinned student ends up in their group', () {
      for (var seed = 0; seed < 20; seed++) {
        final groups = GroupBuilder.assign(
          studentIds: classOf(24),
          sizes: const [4, 4, 4, 4, 4, 4],
          pinned: const {7: 2},
          random: Random(seed),
        );
        expect(groups[2], contains(7));
      }
    });

    /// Section 9: 24 students, 6 groups, 2 pinned into group 1 — they stay put
    /// and two more join them.
    test('pinned places are filled up around, not moved', () {
      final groups = GroupBuilder.assign(
        studentIds: classOf(24),
        sizes: const [4, 4, 4, 4, 4, 4],
        pinned: const {1: 0, 2: 0},
        random: Random(3),
      );

      expect(groups[0], containsAll([1, 2]));
      expect(groups[0], hasLength(4));
      expect(groups.expand((g) => g).toSet(), classOf(24).toSet());
    });

    /// Section 9: everyone pinned means the result is the input, untouched.
    test('a fully pinned split leaves no room for chance', () {
      final pinned = {for (var i = 1; i <= 24; i++) i: (i - 1) ~/ 4};
      final groups = GroupBuilder.assign(
        studentIds: classOf(24),
        sizes: const [4, 4, 4, 4, 4, 4],
        pinned: pinned,
        random: Random(9),
      );

      for (var i = 1; i <= 24; i++) {
        expect(groups[(i - 1) ~/ 4], contains(i));
      }
    });

    test('a pin into a group that does not exist is refused', () {
      expect(
        GroupBuilder.pinProblem(studentIds: classOf(8), sizes: const [4, 4], pinned: const {1: 5}),
        contains('Gruppe 6'),
      );
    });

    test('more pins than places is refused with the numbers named', () {
      final problem = GroupBuilder.pinProblem(
        studentIds: classOf(24),
        sizes: const [4, 4, 4, 4, 4, 4],
        pinned: const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      );
      expect(problem, contains('5 SuS'));
      expect(problem, contains('Gruppe 1'));
      expect(problem, contains('Platz für 4'));
    });

    test('sizes that do not add up to the class are refused', () {
      expect(
        GroupBuilder.pinProblem(studentIds: classOf(23), sizes: const [4, 4, 4, 4, 4, 4]),
        contains('anwesend sind 23'),
      );
    });
  });

  /// The table for F2.4 in section 9 — the point being that a group with more
  /// pins than its share becomes one of the larger groups instead of failing.
  group('sizes that make room for the pins', () {
    test('24 into 6 with 2 pinned in group 1 stays 6×4', () {
      final sizes = GroupBuilder.sizesForPins(students: 24, groups: 6, pinned: const {1: 0, 2: 0});
      expect(sizes, [4, 4, 4, 4, 4, 4]);
    });

    test('25 into 6 with 5 pinned in group 1 makes group 1 the big one', () {
      final sizes = GroupBuilder.sizesForPins(
        students: 25,
        groups: 6,
        pinned: const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      );
      expect(sizes, isNotNull);
      expect(sizes![0], 5, reason: 'the group with the most pins takes the larger size');
      expect(sizes.fold(0, (a, b) => a + b), 25);
    });

    test('25 into 6 with 5 pinned in two different groups is impossible', () {
      final sizes = GroupBuilder.sizesForPins(
        students: 25,
        groups: 6,
        pinned: const {
          1: 0, 2: 0, 3: 0, 4: 0, 5: 0, //
          6: 1, 7: 1, 8: 1, 9: 1, 10: 1,
        },
      );
      expect(sizes, isNull, reason: 'only one group may be the larger one');
    });

    test('24 into 6 with 5 pinned in one group is impossible', () {
      final sizes = GroupBuilder.sizesForPins(
        students: 24,
        groups: 6,
        pinned: const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      );
      expect(sizes, isNull, reason: 'at 6 groups of 24 nobody can hold more than 4');
    });

    test('the sizes it returns are always usable', () {
      for (var students = 6; students <= 30; students++) {
        for (var groups = 2; groups <= 6; groups++) {
          final sizes = GroupBuilder.sizesForPins(students: students, groups: groups, pinned: const {});
          expect(sizes, isNotNull);
          expect(sizes!.fold(0, (a, b) => a + b), students);
          expect(sizes.reduce(max) - sizes.reduce(min), lessThanOrEqualTo(1));
        }
      }
    });
  });
}
