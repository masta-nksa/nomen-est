import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/providers.dart';
import '../quiz/quiz_engine.dart';
import '../quiz/quiz_settings.dart';
import '../widgets/photo_zoom.dart';
import 'result_screen.dart';

/// One answered question, kept for the round summary.
class AnswerRecord {
  const AnswerRecord({required this.personId, required this.correct, this.pickedId});

  final int personId;
  final bool correct;
  final int? pickedId;
}

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.set, required this.settings});

  final PhotoSet set;
  final QuizSettings settings;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

/// How long the green confirmation stays up before the next photo appears.
const _correctFlashDuration = Duration(milliseconds: 550);

enum _Phase {
  /// Taking input. Wrong picks so far are marked, the answer is not.
  asking,

  /// Answered correctly — briefly confirming, then moving on by itself.
  correct,

  /// Out of tries: the answer is shown and the learner moves on when ready.
  revealed,
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final _answers = <AnswerRecord>[];
  Map<int, Person> _people = {};
  QuizEngine? _engine;
  Question? _question;

  /// Options already picked and rejected for the current question.
  final _wrongPicks = <int>{};
  int _attempts = 0;
  _Phase _phase = _Phase.asking;
  bool _timedOut = false;

  int _asked = 0;
  DateTime _shownAt = DateTime.now();
  Timer? _timer;
  Duration _remaining = Duration.zero;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final people = await db.personsInSet(widget.set.id);
    if (people.length < 2) {
      if (mounted) setState(() => _error = 'Diese Klasse hat zu wenige Personen zum Üben.');
      return;
    }

    final progressRows = {for (final p in await db.progressForSet(widget.set.id)) p.personId: p};
    final confusions = <int, Map<int, int>>{};
    for (final c in await db.confusionsForSet(widget.set.id)) {
      (confusions[c.personId] ??= {})[c.confusedWithId] = c.count;
    }

    final engine = QuizEngine(
      settings: widget.settings,
      candidates: [
        for (final person in people)
          CandidateStats(
            personId: person.id,
            box: progressRows[person.id]?.box ?? 1,
            wrong: progressRows[person.id]?.wrong ?? 0,
            initial: _initialOf(person),
            confusedWith: confusions[person.id] ?? const {},
          ),
      ],
    );

    if (!mounted) return;
    setState(() {
      _people = {for (final p in people) p.id: p};
      _engine = engine;
    });
    _nextQuestion();
  }

  String _initialOf(Person person) {
    final name = _nameOf(person);
    return name.isEmpty ? '' : name.substring(0, 1).toUpperCase();
  }

  String _nameOf(Person person) => switch (widget.settings.nameStyle) {
        NameStyle.firstName => person.firstName.isEmpty ? person.lastName : person.firstName,
        NameStyle.lastName => person.lastName,
        NameStyle.full => person.displayName,
      };

  void _nextQuestion() {
    _timer?.cancel();
    if (_asked >= widget.settings.roundLength) {
      _finish();
      return;
    }
    final question = _engine!.next();
    if (question == null) {
      _finish();
      return;
    }
    setState(() {
      _question = question;
      _wrongPicks.clear();
      _attempts = 0;
      _phase = _Phase.asking;
      _timedOut = false;
      _asked++;
      _shownAt = DateTime.now();
    });
    _startTimer();
  }

  void _startTimer() {
    final limit = widget.settings.timeLimit;
    if (limit == null) return;
    setState(() => _remaining = limit);
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final left = limit - DateTime.now().difference(_shownAt);
      if (left <= Duration.zero) {
        timer.cancel();
        _answer(null);
      } else if (mounted) {
        setState(() => _remaining = left);
      }
    });
  }

  /// Handles one pick, or a timeout when [pickedId] is null.
  ///
  /// A first wrong pick costs the point but not the question: the answer stays
  /// hidden and there is one more try, so the learner has to actually recall
  /// rather than read off the solution. Only the first attempt is scored —
  /// getting it on the retry must not look like knowing it.
  Future<void> _answer(int? pickedId) async {
    if (_phase != _Phase.asking) return;
    if (pickedId != null && _wrongPicks.contains(pickedId)) return;

    final question = _question!;
    final correct = pickedId == question.personId;
    final isFirstAttempt = _attempts == 0;
    _attempts++;

    // A timeout ends the question outright — the whole limit was the one try.
    final hasRetryLeft = isFirstAttempt && pickedId != null;
    if (correct || !hasRetryLeft) {
      _timer?.cancel();
    }
    setState(() {
      if (pickedId != null && !correct) _wrongPicks.add(pickedId);
      if (correct) {
        _phase = _Phase.correct;
      } else if (!hasRetryLeft) {
        _timedOut = pickedId == null;
        _phase = _Phase.revealed;
      }
    });

    final db = ref.read(databaseProvider);
    if (isFirstAttempt) {
      final elapsedMs = DateTime.now().difference(_shownAt).inMilliseconds;
      _answers.add(AnswerRecord(personId: question.personId, correct: correct, pickedId: pickedId));
      _engine!.applyAnswer(personId: question.personId, correct: correct);
      await db.recordAnswer(personId: question.personId, correct: correct, elapsedMs: elapsedMs);
    }
    if (!correct && pickedId != null) {
      _engine!.recordConfusion(personId: question.personId, pickedId: pickedId);
      await db.recordConfusion(personId: question.personId, confusedWithId: pickedId);
    }

    if (correct) {
      await Future<void>.delayed(_correctFlashDuration);
      if (mounted && _phase == _Phase.correct) _nextQuestion();
    }
  }

  void _finish() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => ResultScreen(set: widget.set, answers: _answers, people: _people),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.set.label)),
        body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!))),
      );
    }
    final question = _question;
    if (question == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.set.label)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$_asked / ${widget.settings.roundLength}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: _asked / widget.settings.roundLength),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (widget.settings.timeLimit != null && _phase == _Phase.asking)
                  LinearProgressIndicator(
                    value: _remaining.inMilliseconds / widget.settings.timeLimit!.inMilliseconds,
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: widget.settings.mode == QuizMode.photoToName
                      ? _buildPhotoToName(question)
                      : _buildNameToPhoto(question),
                ),
                const SizedBox(height: 12),
                _FeedbackBar(
                  phase: _phase,
                  retrying: _wrongPicks.isNotEmpty,
                  timedOut: _timedOut,
                  answer: _nameOf(_people[question.personId]!),
                  onNext: _nextQuestion,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoToName(Question question) {
    final target = _people[question.personId]!;
    return Column(
      children: [
        // The photo keeps the larger share of the height so it never gets
        // squeezed away by a long option list; the options scroll instead.
        Flexible(
          flex: 3,
          child: Center(
            // The source photos are only ~200 px square, so blowing them up to
            // fill a desktop window just makes them soft. Cap the size and let
            // it shrink freely on smaller screens.
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxPhotoSize, maxHeight: maxPhotoSize),
              child: AspectRatio(
                aspectRatio: 1,
                child: ZoomablePhoto(
                  jpegBytes: target.jpegBytes,
                  caption: _phase == _Phase.asking ? null : _nameOf(target),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Flexible(
          flex: 2,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final id in question.optionIds)
                  _OptionButton(
                    label: _nameOf(_people[id]!),
                    state: _stateFor(id, question.personId),
                    onPressed:
                        _phase != _Phase.asking || _wrongPicks.contains(id) ? null : () => _answer(id),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameToPhoto(Question question) {
    final target = _people[question.personId]!;
    return Column(
      children: [
        Text(
          _nameOf(target),
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 160,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: question.optionIds.length,
            itemBuilder: (context, index) {
              final id = question.optionIds[index];
              return _PhotoOption(
                person: _people[id]!,
                state: _stateFor(id, question.personId),
                onTap: _phase != _Phase.asking || _wrongPicks.contains(id) ? null : () => _answer(id),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Rejected picks turn red immediately; the answer only lights up once the
  /// question is over, so the retry is not given away.
  _OptionState _stateFor(int id, int answerId) {
    if (_wrongPicks.contains(id)) return _OptionState.wrong;
    if (_phase != _Phase.asking && id == answerId) return _OptionState.correct;
    return _OptionState.idle;
  }
}

enum _OptionState { idle, correct, wrong }

class _OptionButton extends StatelessWidget {
  const _OptionButton({required this.label, required this.state, this.onPressed});

  final String label;
  final _OptionState state;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (state) {
      _OptionState.correct => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      _OptionState.wrong => (scheme.errorContainer, scheme.onErrorContainer),
      _OptionState.idle => (scheme.surfaceContainerHighest, scheme.onSurface),
    };
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: bg,
        disabledForegroundColor: fg,
      ),
      child: Text(label),
    );
  }
}

class _PhotoOption extends StatelessWidget {
  const _PhotoOption({required this.person, required this.state, this.onTap});

  final Person person;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = switch (state) {
      _OptionState.correct => scheme.tertiary,
      _OptionState.wrong => scheme.error,
      _OptionState.idle => Colors.transparent,
    };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: border, width: 4),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.memory(
          person.jpegBytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

/// Occupies a fixed height in every phase so the photo above does not jump
/// around as the feedback appears and disappears.
class _FeedbackBar extends StatelessWidget {
  const _FeedbackBar({
    required this.phase,
    required this.retrying,
    required this.timedOut,
    required this.answer,
    required this.onNext,
  });

  final _Phase phase;
  final bool retrying;
  final bool timedOut;
  final String answer;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (icon, color, message) = switch (phase) {
      _Phase.correct => (Icons.check_circle, scheme.tertiary, 'Richtig'),
      _Phase.revealed when timedOut => (Icons.timer_off, scheme.error, 'Zeit abgelaufen — $answer'),
      _Phase.revealed => (Icons.cancel, scheme.error, 'Falsch — $answer'),
      _Phase.asking when retrying => (Icons.refresh, scheme.error, 'Nicht ganz — du hast noch einen Versuch.'),
      _Phase.asking => (null, null, null),
    };

    return SizedBox(
      height: 48,
      child: message == null
          ? null
          : Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
                if (phase == _Phase.revealed)
                  FilledButton(onPressed: onNext, child: const Text('Weiter')),
              ],
            ),
    );
  }
}
