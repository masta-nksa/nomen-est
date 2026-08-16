/// The dials of the random draw.
///
/// Defaults follow the open decisions in KONZEPT-zufall-und-gruppen.md: no
/// repetition, one student at a time, a cooldown of three, and soft fairness.
class DrawSettings {
  const DrawSettings({
    this.replacement = false,
    this.count = 1,
    this.cooldown = 3,
    this.alpha = 1,
  });

  /// With repetition on, being drawn no longer takes a student out of the pool.
  ///
  /// It does **not** stop the draw from being recorded — the log has to stay
  /// complete or the statistics get holes and the fairness weighting goes
  /// blind. The switch only decides whether the log filters the pool.
  final bool replacement;

  /// How many students one draw picks at once.
  ///
  /// Not reachable from the UI: without repetition, tapping again gives the
  /// same three distinct names, so the chip only ever bought seeing them side
  /// by side — too little for a control that has to be explained. Real teams
  /// are the grouping's job. The engine keeps it because F3.3 may want it back.
  final int count;

  /// How many of the most recent draws are held back, across rounds.
  ///
  /// Soft: if holding them back would leave nobody, they come back in.
  /// Repeating someone beats drawing nobody.
  final int cooldown;

  /// How hard rare students are favoured: 0 is a uniform draw, 1 is a gentle
  /// pull, 2 is pronounced.
  ///
  /// Irrelevant without [replacement], where the pool enforces fairness on its
  /// own.
  final double alpha;

  DrawSettings copyWith({bool? replacement, int? count, int? cooldown, double? alpha}) => DrawSettings(
        replacement: replacement ?? this.replacement,
        count: count ?? this.count,
        cooldown: cooldown ?? this.cooldown,
        alpha: alpha ?? this.alpha,
      );
}
