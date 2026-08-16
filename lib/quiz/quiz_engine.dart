import 'dart:math';

import 'quiz_settings.dart';

/// The learner's state for one student, as far as question selection cares.
class CandidateStats {
  const CandidateStats({
    required this.studentId,
    required this.box,
    required this.wrong,
    this.initial = '',
    this.confusedWith = const {},
  });

  final int studentId;
  final int box;
  final int wrong;

  /// First letter of the displayed name, for [DistractorStrategy.sameInitial].
  final String initial;

  /// How often each other student was wrongly picked when this one was shown.
  final Map<int, int> confusedWith;

  CandidateStats copyWith({int? box, int? wrong, Map<int, int>? confusedWith}) => CandidateStats(
        studentId: studentId,
        box: box ?? this.box,
        wrong: wrong ?? this.wrong,
        initial: initial,
        confusedWith: confusedWith ?? this.confusedWith,
      );
}

/// One quiz question: who to ask about, and which options to offer.
class Question {
  const Question({required this.studentId, required this.optionIds});

  final int studentId;
  final List<int> optionIds;
}

/// Picks questions and distractors.
///
/// Two things make this more than a shuffle: low Leitner boxes and recent
/// mistakes pull a student to the front, and distractors are drawn from the
/// students this learner actually confuses with the target — training the
/// distinction that is hard rather than one that is already obvious.
class QuizEngine {
  QuizEngine({
    required List<CandidateStats> candidates,
    required this.settings,
    Random? random,
  })  : _candidates = {for (final c in candidates) c.studentId: c},
        _random = random ?? Random();

  final Map<int, CandidateStats> _candidates;
  final QuizSettings settings;
  final Random _random;

  final _unseenThisSession = <int>{};
  int? _lastAskedId;
  bool _sessionStarted = false;

  int get candidateCount => _candidates.length;

  /// Current Leitner box, reflecting answers given during this session.
  int? boxOf(int studentId) => _candidates[studentId]?.box;

  /// Returns the next question, or null if there is nothing to ask.
  Question? next() {
    if (_candidates.length < 2) return null;
    if (!_sessionStarted) {
      _unseenThisSession.addAll(_candidates.keys);
      _sessionStarted = true;
    }

    final studentId = _pickStudent();
    _unseenThisSession.remove(studentId);
    _lastAskedId = studentId;
    return Question(studentId: studentId, optionIds: _buildOptions(studentId));
  }

  int _pickStudent() {
    // Everyone gets shown once before anyone repeats; after that opening pass
    // the weights govern, so struggling people genuinely come up more often
    // instead of merely earlier within a fixed rotation.
    final pool = _unseenThisSession.isNotEmpty ? _unseenThisSession.toList() : _candidates.keys.toList();
    if (pool.length > 1) {
      pool.remove(_lastAskedId);
    }

    final weights = [for (final id in pool) _weightFor(_candidates[id]!)];
    return pool[_weightedIndex(weights)];
  }

  double _weightFor(CandidateStats stats) {
    final boxPenalty = pow(6 - stats.box, 2).toDouble();
    return boxPenalty + 2 * stats.wrong + _random.nextDouble();
  }

  int _weightedIndex(List<double> weights) {
    final total = weights.fold(0.0, (a, b) => a + b);
    var roll = _random.nextDouble() * total;
    for (var i = 0; i < weights.length; i++) {
      roll -= weights[i];
      if (roll <= 0) return i;
    }
    return weights.length - 1;
  }

  List<int> _buildOptions(int studentId) {
    final wanted = min(settings.optionCount, _candidates.length);
    final options = <int>{studentId};

    if (settings.distractors == DistractorStrategy.confusion) {
      final confused = _candidates[studentId]!.confusedWith.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in confused) {
        if (options.length >= wanted) break;
        if (_candidates.containsKey(entry.key)) options.add(entry.key);
      }
    }

    if (settings.distractors == DistractorStrategy.sameInitial) {
      final initial = _candidates[studentId]!.initial;
      if (initial.isNotEmpty) {
        final matching = _candidates.values
            .where((c) => c.studentId != studentId && c.initial == initial)
            .map((c) => c.studentId)
            .toList()
          ..shuffle(_random);
        for (final id in matching) {
          if (options.length >= wanted) break;
          options.add(id);
        }
      }
    }

    final rest = _candidates.keys.where((id) => !options.contains(id)).toList()..shuffle(_random);
    for (final id in rest) {
      if (options.length >= wanted) break;
      options.add(id);
    }

    return options.toList()..shuffle(_random);
  }

  /// Applies the Leitner move so the next pick sees the updated state.
  void applyAnswer({required int studentId, required bool correct}) {
    final current = _candidates[studentId];
    if (current == null) return;
    _candidates[studentId] = current.copyWith(
      box: correct ? (current.box + 1).clamp(1, 5) : (current.box - 2).clamp(1, 5),
      wrong: current.wrong + (correct ? 0 : 1),
    );
  }

  void recordConfusion({required int studentId, required int pickedId}) {
    final current = _candidates[studentId];
    if (current == null) return;
    _candidates[studentId] = current.copyWith(confusedWith: {
      ...current.confusedWith,
      pickedId: (current.confusedWith[pickedId] ?? 0) + 1,
    });
  }
}
