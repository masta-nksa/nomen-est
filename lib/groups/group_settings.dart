import 'partition.dart';

/// Which of the three ways the teacher is stating the split.
enum GroupMode { count, size, range }

/// The dials of the grouping, remembered per class — "always groups of four"
/// is a habit, not a decision to be made again every lesson.
class GroupSettings {
  const GroupSettings({
    this.mode = GroupMode.size,
    this.groups = 4,
    this.size = 4,
    this.min = 3,
    this.max = 4,
    this.even = true,
  });

  final GroupMode mode;

  /// Used by [GroupMode.count].
  final int groups;

  /// Used by [GroupMode.size].
  final int size;

  /// Used by [GroupMode.range].
  final int min;
  final int max;

  /// Sizes differ by at most one. Off, groups are filled to the stated size and
  /// the remainder forms a smaller one — sometimes six clean groups of four and
  /// one person who joins another is exactly what is wanted.
  final bool even;

  GroupSpec get spec => switch (mode) {
        GroupMode.count => ByGroupCount(groups),
        GroupMode.size => BySize(size),
        GroupMode.range => BySizeRange(min, max),
      };

  GroupSettings copyWith({
    GroupMode? mode,
    int? groups,
    int? size,
    int? min,
    int? max,
    bool? even,
  }) =>
      GroupSettings(
        mode: mode ?? this.mode,
        groups: groups ?? this.groups,
        size: size ?? this.size,
        min: min ?? this.min,
        max: max ?? this.max,
        even: even ?? this.even,
      );
}
