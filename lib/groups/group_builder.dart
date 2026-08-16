import 'dart:math';

/// Builds the actual groups once [partition] has decided how big they are.
///
/// Split from the sizing on purpose: how many groups of what size is a question
/// with one right answer, who goes where is a question with many. The pairing
/// history and the together/apart rules will be a cost function on top of this
/// (F5.2, F5.3) — the shape here already anticipates that by keeping pinned
/// students frozen and only moving the free ones.
class GroupBuilder {
  const GroupBuilder._();

  /// Fills groups of the given [sizes] with [studentIds].
  ///
  /// [pinned] maps a student to the group they must end up in; those places are
  /// taken before anyone else is placed. Pinning is the most recent and most
  /// deliberate decision the teacher made, so it wins over everything else.
  ///
  /// Throws [ArgumentError] when the sizes cannot hold the students or a pin
  /// points at a group that does not exist — the caller checks feasibility
  /// first, see [pinProblem].
  static List<List<int>> assign({
    required List<int> studentIds,
    required List<int> sizes,
    Map<int, int> pinned = const {},
    Random? random,
  }) {
    final problem = pinProblem(studentIds: studentIds, sizes: sizes, pinned: pinned);
    if (problem != null) throw ArgumentError(problem);

    final rng = random ?? Random();
    final groups = [for (var i = 0; i < sizes.length; i++) <int>[]];

    for (final entry in pinned.entries) {
      if (studentIds.contains(entry.key)) groups[entry.value].add(entry.key);
    }

    final free = [
      for (final id in studentIds)
        if (!pinned.containsKey(id)) id,
    ]..shuffle(rng);

    for (var index = 0; index < groups.length; index++) {
      while (groups[index].length < sizes[index] && free.isNotEmpty) {
        groups[index].add(free.removeLast());
      }
    }
    return groups;
  }

  /// Why the pinning cannot work, or null when it can.
  ///
  /// Pinned places are lower bounds on their group: putting five students in
  /// group 1 while asking for six groups out of 24 is not a rounding problem
  /// but a contradiction, and the message has to say which.
  static String? pinProblem({
    required List<int> studentIds,
    required List<int> sizes,
    Map<int, int> pinned = const {},
  }) {
    final total = sizes.fold(0, (a, b) => a + b);
    if (total != studentIds.length) {
      return 'Die Gruppengrössen fassen $total SuS, anwesend sind ${studentIds.length}.';
    }

    final perGroup = <int, int>{};
    for (final entry in pinned.entries) {
      if (!studentIds.contains(entry.key)) continue;
      if (entry.value < 0 || entry.value >= sizes.length) {
        return 'Eine Vorbelegung zeigt auf Gruppe ${entry.value + 1}, '
            'es gibt aber nur ${sizes.length}.';
      }
      perGroup.update(entry.value, (value) => value + 1, ifAbsent: () => 1);
    }

    for (final entry in perGroup.entries) {
      if (entry.value > sizes[entry.key]) {
        return '${entry.value} SuS sind fest in Gruppe ${entry.key + 1}, '
            'dort ist aber nur Platz für ${sizes[entry.key]}.';
      }
    }
    return null;
  }

  /// Sizes that respect the pinned places, so that a group with more pins than
  /// its share becomes one of the larger ones instead of failing.
  ///
  /// Without this, splits that are perfectly solvable are rejected: 25 students
  /// into 6 groups with 5 pinned in group 1 works precisely because group 1 is
  /// allowed to be the one of size 5.
  static List<int>? sizesForPins({
    required int students,
    required int groups,
    required Map<int, int> pinned,
  }) {
    if (groups <= 0 || students < groups) return null;

    final counts = List.filled(groups, 0);
    for (final group in pinned.values) {
      if (group < 0 || group >= groups) return null;
      counts[group]++;
    }
    if (counts.fold(0, (a, b) => a + b) > students) return null;

    final base = students ~/ groups;
    final larger = students % groups;
    if (counts.any((count) => count > base + (larger > 0 ? 1 : 0))) return null;
    if (counts.where((count) => count > base).length > larger) return null;

    // The groups with the most pins take the larger sizes — that is what makes
    // the solvable cases actually solve.
    final order = [for (var i = 0; i < groups; i++) i]
      ..sort((a, b) => counts[b].compareTo(counts[a]));
    final sizes = List.filled(groups, base);
    for (var i = 0; i < larger; i++) {
      sizes[order[i]] = base + 1;
    }
    return sizes;
  }
}
