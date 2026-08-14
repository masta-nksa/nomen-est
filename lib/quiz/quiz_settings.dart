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
  });

  final QuizMode mode;
  final int optionCount;
  final DistractorStrategy distractors;
  final Duration? timeLimit;
  final NameStyle nameStyle;
  final int roundLength;

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
  }) =>
      QuizSettings(
        mode: mode ?? this.mode,
        optionCount: optionCount ?? this.optionCount,
        distractors: distractors ?? this.distractors,
        timeLimit: clearTimeLimit ? null : (timeLimit ?? this.timeLimit),
        nameStyle: nameStyle ?? this.nameStyle,
        roundLength: roundLength ?? this.roundLength,
      );
}
