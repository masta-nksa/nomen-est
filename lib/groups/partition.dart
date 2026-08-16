/// How the teacher stated the split.
sealed class GroupSpec {
  const GroupSpec();
}

/// "Six groups", however big they turn out.
final class ByGroupCount extends GroupSpec {
  const ByGroupCount(this.groups);
  final int groups;
}

/// "Groups of four", however many that makes.
final class BySize extends GroupSpec {
  const BySize(this.size);
  final int size;
}

/// "Groups of two to three" — the most forgiving of the three, because it
/// leaves the algorithm room to come out even.
final class BySizeRange extends GroupSpec {
  const BySizeRange(this.min, this.max);
  final int min;
  final int max;
}

sealed class PartitionResult {
  const PartitionResult();
}

final class Partition extends PartitionResult {
  const Partition(this.sizes);

  /// Group sizes, largest first.
  final List<int> sizes;

  int get groups => sizes.length;
  int get students => sizes.fold(0, (a, b) => a + b);

  /// "6 Gruppen à 4" or "5×3 + 4×2" — the consequence of a choice, in the form
  /// the slider needs to show it.
  String describe() {
    if (sizes.isEmpty) return 'Keine Gruppen';

    final counts = <int, int>{};
    for (final size in sizes) {
      counts.update(size, (value) => value + 1, ifAbsent: () => 1);
    }
    if (counts.length == 1) {
      final size = sizes.first;
      return '${sizes.length} ${sizes.length == 1 ? 'Gruppe' : 'Gruppen'} à $size';
    }
    final parts = counts.entries.toList()..sort((a, b) => b.key.compareTo(a.key));
    return [for (final part in parts) '${part.value}×${part.key}'].join(' + ');
  }
}

/// Not possible as asked — with the way out named, because "geht nicht" alone
/// leaves the teacher guessing at what would.
final class PartitionImpossible extends PartitionResult {
  const PartitionImpossible(this.message, this.suggestion);

  final String message;
  final String suggestion;

  @override
  String toString() => '$message $suggestion';
}

/// Splits [students] according to [spec].
///
/// With [even] the sizes differ by at most one; without it, groups are filled
/// to the stated size and whatever is left forms a smaller one. That difference
/// is the whole point of the switch: sometimes you want six clean groups of
/// four and one person who joins another, not seven ragged ones.
///
/// [even] has no meaning for [ByGroupCount] — a fixed number of groups always
/// splits as evenly as the count allows, since the alternative would be an
/// empty group.
PartitionResult partition({
  required int students,
  required GroupSpec spec,
  bool even = true,
}) {
  if (students < 0) return const PartitionImpossible('Negative Anzahl.', '');
  if (students == 0) return const Partition([]);

  return switch (spec) {
    ByGroupCount(:final groups) => _byGroupCount(students, groups),
    BySize(:final size) => _bySize(students, size, even),
    BySizeRange(:final min, :final max) => _byRange(students, min, max, even),
  };
}

/// Valid group counts for a size range: ⌈n/max⌉ … ⌊n/min⌋.
///
/// Empty when the range cannot be satisfied at all — 7 students into groups of
/// four to five has no answer.
List<int> validGroupCounts(int students, int min, int max) {
  if (students <= 0 || min <= 0 || max < min) return const [];
  final lowest = (students + max - 1) ~/ max;
  final highest = students ~/ min;
  if (lowest > highest) return const [];
  return [for (var g = lowest; g <= highest; g++) g];
}

/// The group count closest to the middle of the range, as the default the
/// slider starts on.
int? defaultGroupCount(int students, int min, int max) {
  final valid = validGroupCounts(students, min, max);
  if (valid.isEmpty) return null;
  final middle = (min + max) / 2;
  final wanted = (students / middle).round();
  return wanted.clamp(valid.first, valid.last);
}

PartitionResult _byGroupCount(int students, int groups) {
  if (groups <= 0) {
    return const PartitionImpossible('Mindestens eine Gruppe.', '');
  }
  if (groups > students) {
    return PartitionImpossible(
      '$students SuS lassen sich nicht in $groups Gruppen teilen — '
      'eine Gruppe bliebe leer.',
      'Möglich sind höchstens $students Gruppen.',
    );
  }
  return Partition(_evenSizes(students, groups));
}

PartitionResult _bySize(int students, int size, bool even) {
  if (size <= 0) return const PartitionImpossible('Gruppengrösse muss positiv sein.', '');
  if (size > students) {
    return PartitionImpossible(
      'Gruppen von $size lassen sich aus $students SuS nicht bilden.',
      'Möglich ist eine Gruppe von $students.',
    );
  }

  final groups = students ~/ size;
  if (!even) {
    // Fill to the stated size and let the remainder stand on its own. Six clean
    // groups of four plus one person is sometimes exactly what is wanted.
    final rest = students % size;
    return Partition([for (var i = 0; i < groups; i++) size, if (rest > 0) rest]);
  }
  return Partition(_evenSizes(students, groups));
}

PartitionResult _byRange(int students, int min, int max, bool even) {
  if (min <= 0) return const PartitionImpossible('Gruppengrösse muss positiv sein.', '');
  if (max < min) {
    return const PartitionImpossible('Die Obergrenze liegt unter der Untergrenze.', '');
  }

  final groups = defaultGroupCount(students, min, max);
  if (groups == null) {
    return PartitionImpossible(
      '$students SuS lassen sich nicht in Gruppen von $min–$max teilen.',
      _rangeSuggestion(students, min, max),
    );
  }

  if (!even) {
    final sizes = <int>[];
    var left = students;
    while (left > max) {
      sizes.add(max);
      left -= max;
    }
    if (left > 0) sizes.add(left);
    return Partition(sizes);
  }
  return Partition(_evenSizes(students, groups));
}

/// basis = n div g, rest = n mod g → `rest` groups one larger.
/// The difference between the largest and smallest group is then always ≤ 1.
List<int> _evenSizes(int students, int groups) {
  final base = students ~/ groups;
  final larger = students % groups;
  return [
    for (var i = 0; i < larger; i++) base + 1,
    for (var i = 0; i < groups - larger; i++) base,
  ];
}

/// Names a way out of an impossible range: the nearest range that works, and
/// what it would produce.
String _rangeSuggestion(int students, int min, int max) {
  for (var widening = 1; widening <= students; widening++) {
    for (final candidate in [
      (min - widening, max),
      (min, max + widening),
      (min - widening, max + widening),
    ]) {
      final (low, high) = candidate;
      if (low < 1) continue;
      final groups = defaultGroupCount(students, low, high);
      if (groups == null) continue;
      final sizes = _evenSizes(students, groups);
      return 'Möglich wäre $low–$high: ${Partition(sizes).describe()}. '
          'Oder „gleichmässig" ausschalten und eine Restgruppe zulassen.';
    }
  }
  return 'Oder „gleichmässig" ausschalten und eine Restgruppe zulassen.';
}
