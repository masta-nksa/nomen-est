enum QuizMode { photoToName, nameToPhoto }

enum DistractorStrategy { random, sameInitial, confusion }

enum NameStyle { firstName, lastName, full }

/// How much of the class a round covers.
enum QuizScope {
  /// The app picks: everyone already learned, plus the next few who are not.
  automatic,

  /// A chosen size and step, growing by hand.
  manual,

  /// Everybody at once.
  whole,
}

/// The three independent difficulty dials plus the name-display switch.
///
/// The defaults are the easy preset: three options, plain distractors, no
/// clock. Somebody opening a fresh class does not yet know a single face, and
/// the dials exist for later.
class QuizSettings {
  const QuizSettings({
    this.mode = QuizMode.photoToName,
    this.optionCount = 3,
    this.distractors = DistractorStrategy.random,
    this.timeLimit,
    this.nameStyle = NameStyle.full,
    this.roundLength = 15,
    this.scope = QuizScope.automatic,
    this.chunkSize = 5,
    this.chunkStep = 0,
  });

  final QuizMode mode;
  final int optionCount;
  final DistractorStrategy distractors;
  final Duration? timeLimit;
  final NameStyle nameStyle;
  final int roundLength;

  /// Who is in the round at all.
  ///
  /// What any of it buys is repetition: a round of 15 cards over 24 students
  /// shows each face about half a time, over a handful it shows each one three
  /// times. The distractors follow, since the engine only ever sees the chosen
  /// set — which is what makes a first pass feel possible.
  final QuizScope scope;

  /// Size of one portion in [QuizScope.manual].
  final int chunkSize;

  /// How far through the class, 0-based and inclusive: step 0 is the first
  /// chunk, step 2 is the first three chunks together.
  ///
  /// Cumulative rather than one chunk at a time, because learning five faces
  /// five times over teaches five names and not a class — the point where it
  /// gets hard, and where it counts, is telling the earlier ones from the new
  /// ones. That also keeps it to a single dial: the label says what is in play.
  final int chunkStep;

  static const easy = QuizSettings(
    optionCount: 3,
    distractors: DistractorStrategy.random,
  );

  static const medium = QuizSettings(
    optionCount: 5,
    distractors: DistractorStrategy.sameInitial,
    timeLimit: Duration(seconds: 8),
  );

  static const hard = QuizSettings(
    optionCount: 8,
    distractors: DistractorStrategy.confusion,
    timeLimit: Duration(seconds: 4),
  );

  /// Whether the three difficulty dials match [other].
  ///
  /// Which preset is in force cannot be stored, because the dials underneath
  /// can be turned by hand — so it is read back off them. After adjusting one,
  /// no preset is highlighted, which is the truth.
  bool sameDifficultyAs(QuizSettings other) =>
      optionCount == other.optionCount &&
      distractors == other.distractors &&
      timeLimit == other.timeLimit;

  QuizSettings copyWith({
    QuizMode? mode,
    int? optionCount,
    DistractorStrategy? distractors,
    Duration? timeLimit,
    bool clearTimeLimit = false,
    NameStyle? nameStyle,
    int? roundLength,
    QuizScope? scope,
    int? chunkSize,
    int? chunkStep,
  }) =>
      QuizSettings(
        mode: mode ?? this.mode,
        optionCount: optionCount ?? this.optionCount,
        distractors: distractors ?? this.distractors,
        timeLimit: clearTimeLimit ? null : (timeLimit ?? this.timeLimit),
        nameStyle: nameStyle ?? this.nameStyle,
        roundLength: roundLength ?? this.roundLength,
        scope: scope ?? this.scope,
        chunkSize: chunkSize ?? this.chunkSize,
        chunkStep: chunkStep ?? this.chunkStep,
      );
}
