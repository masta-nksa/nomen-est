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

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final _answers = <AnswerRecord>[];
  Map<int, Person> _people = {};
  QuizEngine? _engine;
  Question? _question;
  int? _pickedId;
  bool _revealed = false;
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
      _pickedId = null;
      _revealed = false;
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

  Future<void> _answer(int? pickedId) async {
    if (_revealed) return;
    _timer?.cancel();

    final question = _question!;
    final correct = pickedId == question.personId;
    final elapsedMs = DateTime.now().difference(_shownAt).inMilliseconds;

    setState(() {
      _pickedId = pickedId;
      _revealed = true;
    });

    _answers.add(AnswerRecord(personId: question.personId, correct: correct, pickedId: pickedId));
    _engine!.applyAnswer(personId: question.personId, correct: correct);

    final db = ref.read(databaseProvider);
    await db.recordAnswer(personId: question.personId, correct: correct, elapsedMs: elapsedMs);
    if (!correct && pickedId != null) {
      _engine!.recordConfusion(personId: question.personId, pickedId: pickedId);
      await db.recordConfusion(personId: question.personId, confusedWithId: pickedId);
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
                if (widget.settings.timeLimit != null && !_revealed)
                  LinearProgressIndicator(
                    value: _remaining.inMilliseconds / widget.settings.timeLimit!.inMilliseconds,
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: widget.settings.mode == QuizMode.photoToName
                      ? _buildPhotoToName(question)
                      : _buildNameToPhoto(question),
                ),
                if (_revealed) ...[
                  const SizedBox(height: 12),
                  _FeedbackBar(
                    correct: _pickedId == question.personId,
                    timedOut: _pickedId == null,
                    answer: _nameOf(_people[question.personId]!),
                    onNext: _nextQuestion,
                  ),
                ],
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
        Expanded(
          child: ZoomablePhoto(
            jpegBytes: target.jpegBytes,
            caption: _revealed ? _nameOf(target) : null,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final id in question.optionIds)
              _OptionButton(
                label: _nameOf(_people[id]!),
                state: _stateFor(id, question.personId),
                onPressed: _revealed ? null : () => _answer(id),
              ),
          ],
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
                onTap: _revealed ? null : () => _answer(id),
              );
            },
          ),
        ),
      ],
    );
  }

  _OptionState _stateFor(int id, int answerId) {
    if (!_revealed) return _OptionState.idle;
    if (id == answerId) return _OptionState.correct;
    if (id == _pickedId) return _OptionState.wrong;
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
        child: Image.memory(person.jpegBytes, fit: BoxFit.cover, gaplessPlayback: true),
      ),
    );
  }
}

class _FeedbackBar extends StatelessWidget {
  const _FeedbackBar({
    required this.correct,
    required this.timedOut,
    required this.answer,
    required this.onNext,
  });

  final bool correct;
  final bool timedOut;
  final String answer;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          correct ? Icons.check_circle : Icons.cancel,
          color: correct ? scheme.tertiary : scheme.error,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            correct
                ? 'Richtig'
                : timedOut
                    ? 'Zeit abgelaufen — $answer'
                    : 'Falsch — $answer',
          ),
        ),
        FilledButton(onPressed: onNext, child: const Text('Weiter')),
      ],
    );
  }
}
