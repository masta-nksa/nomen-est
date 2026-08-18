enum QuizMode { photoToName, nameToPhoto }

enum DistractorStrategy { random, sameInitial, confusion }

enum NameStyle { firstName, lastName, full }

/// The three independent difficulty dials plus the name-display switch.
class QuizSettings {
  const QuizSettings({
    this.mode = QuizMode.photoToName,
    this.optionCount = 5,
    this.distractors = DistractorStrategy.random,
    this.timeLimit,
    this.nameStyle = NameStyle.full,
    this.roundLength = 15,
    this.chunkSize,
    this.chunkStep = 0,
  });

  final QuizMode mode;
  final int optionCount;
  final DistractorStrategy distractors;
  final Duration? timeLimit;
  final NameStyle nameStyle;
  final int roundLength;

  /// Learn the class a handful at a time instead of all at once. Null is off.
  ///
  /// What it buys is repetition: a round of 15 cards over 24 students shows
  /// each face about half a time, over a chunk of five it shows each one three
  /// times. The distractors come from the chunk as well, since the engine only
  /// ever sees the chunk — which is what makes the first pass feel possible.
  final int? chunkSize;

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

  QuizSettings copyWith({
    QuizMode? mode,
    int? optionCount,
    DistractorStrategy? distractors,
    Duration? timeLimit,
    bool clearTimeLimit = false,
    NameStyle? nameStyle,
    int? roundLength,
    int? chunkSize,
    bool clearChunkSize = false,
    int? chunkStep,
  }) =>
      QuizSettings(
        mode: mode ?? this.mode,
        optionCount: optionCount ?? this.optionCount,
        distractors: distractors ?? this.distractors,
        timeLimit: clearTimeLimit ? null : (timeLimit ?? this.timeLimit),
        nameStyle: nameStyle ?? this.nameStyle,
        roundLength: roundLength ?? this.roundLength,
        chunkSize: clearChunkSize ? null : (chunkSize ?? this.chunkSize),
        chunkStep: chunkStep ?? this.chunkStep,
      );
}
