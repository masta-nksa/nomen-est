import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/providers.dart';
import '../quiz/chunks.dart';
import '../quiz/quiz_settings.dart';
import 'gallery_screen.dart';
import 'quiz_screen.dart';

class QuizSetupScreen extends ConsumerStatefulWidget {
  const QuizSetupScreen({super.key, required this.schoolClass});

  final SchoolClass schoolClass;

  @override
  ConsumerState<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends ConsumerState<QuizSetupScreen> {
  static const _scopeKey = 'quiz.scope';
  static const _sizeKey = 'quiz.chunkSize';
  static const _stepKey = 'quiz.chunkStep';

  QuizSettings _settings = const QuizSettings();

  @override
  void initState() {
    super.initState();
    _restoreScope();
  }

  /// Only the scope survives a restart, not the difficulty dials: how far
  /// through the class you are is a place you left off, while the dials are a
  /// decision about the round you are starting now.
  Future<void> _restoreScope() async {
    final store = ref.read(settingsProvider);
    final classId = widget.schoolClass.id;
    final stored = await store.read(_scopeKey, classId: classId);
    final size = int.tryParse(await store.read(_sizeKey, classId: classId) ?? '');
    final step = int.tryParse(await store.read(_stepKey, classId: classId) ?? '') ?? 0;
    if (!mounted) return;

    setState(() => _settings = _settings.copyWith(
          // Nothing stored yet: whoever had set a portion size was working
          // through it by hand, everyone else gets the automatic path.
          scope: QuizScope.values.where((s) => s.name == stored).firstOrNull ??
              (size == null ? QuizScope.automatic : QuizScope.manual),
          chunkSize: size,
          chunkStep: step,
        ));
  }

  Future<void> _setScope(QuizScope scope) async {
    setState(() => _settings = _settings.copyWith(scope: scope));
    await ref.read(settingsProvider).write(_scopeKey, scope.name, classId: widget.schoolClass.id);
  }

  Future<void> _setChunkSize(int size) async {
    setState(() => _settings = _settings.copyWith(chunkSize: size, chunkStep: 0));
    final store = ref.read(settingsProvider);
    await store.write(_sizeKey, '$size', classId: widget.schoolClass.id);
    await store.write(_stepKey, '0', classId: widget.schoolClass.id);
  }

  Future<void> _setChunkStep(int step) async {
    setState(() => _settings = _settings.copyWith(chunkStep: step));
    await ref.read(settingsProvider).write(_stepKey, '$step', classId: widget.schoolClass.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.schoolClass.label),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: 'Galerie',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => GalleryScreen(schoolClass: widget.schoolClass)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Progress(classId: widget.schoolClass.id),
          _section('Modus'),
          SegmentedButton<QuizMode>(
            segments: const [
              ButtonSegment(value: QuizMode.photoToName, label: Text('Foto → Name')),
              ButtonSegment(value: QuizMode.nameToPhoto, label: Text('Name → Foto')),
            ],
            selected: {_settings.mode},
            onSelectionChanged: (v) => setState(() => _settings = _settings.copyWith(mode: v.first)),
          ),
          _section('Umfang'),
          RadioGroup<QuizScope>(
            groupValue: _settings.scope,
            onChanged: (value) => _setScope(value!),
            child: Column(
              children: [
                for (final option in QuizScope.values)
                  RadioListTile<QuizScope>(
                    value: option,
                    contentPadding: EdgeInsets.zero,
                    title: Text(switch (option) {
                      QuizScope.automatic => 'Automatisch',
                      QuizScope.manual => 'Selbst einteilen',
                      QuizScope.whole => 'Ganze Klasse',
                    }),
                    subtitle: Text(switch (option) {
                      QuizScope.automatic =>
                        'Beginnt mit einer Handvoll und nimmt die nächste Person '
                            'dazu, sobald eine sitzt.',
                      QuizScope.manual => 'Portionsgrösse und Umfang selbst wählen.',
                      QuizScope.whole => 'Alle auf einmal — bei grossen Klassen '
                          'kommt jede Person pro Runde nur selten dran.',
                    }),
                  ),
              ],
            ),
          ),
          if (_settings.scope == QuizScope.automatic)
            _AutomaticScope(classId: widget.schoolClass.id),
          if (_settings.scope == QuizScope.manual) ...[
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 4, label: Text('4')),
                ButtonSegment(value: 5, label: Text('5')),
                ButtonSegment(value: 6, label: Text('6')),
                ButtonSegment(value: 8, label: Text('8')),
              ],
              selected: {_settings.chunkSize},
              onSelectionChanged: (v) => _setChunkSize(v.first),
            ),
            _ChunkPicker(
              classId: widget.schoolClass.id,
              size: _settings.chunkSize,
              step: _settings.chunkStep,
              onSelected: _setChunkStep,
            ),
          ],
          _section('Voreinstellung'),
          Wrap(
            spacing: 8,
            children: [
              _presetChip('Leicht', QuizSettings.easy),
              _presetChip('Mittel', QuizSettings.medium),
              _presetChip('Schwer', QuizSettings.hard),
            ],
          ),
          _section('Anzahl Optionen'),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 3, label: Text('3')),
              ButtonSegment(value: 5, label: Text('5')),
              ButtonSegment(value: 8, label: Text('8')),
            ],
            selected: {_settings.optionCount},
            onSelectionChanged: (v) => setState(() => _settings = _settings.copyWith(optionCount: v.first)),
          ),
          _section('Ablenker'),
          SegmentedButton<DistractorStrategy>(
            segments: const [
              ButtonSegment(value: DistractorStrategy.random, label: Text('Zufällig')),
              ButtonSegment(value: DistractorStrategy.sameInitial, label: Text('Gleicher Buchstabe')),
              ButtonSegment(value: DistractorStrategy.confusion, label: Text('Verwechslungen')),
            ],
            selected: {_settings.distractors},
            onSelectionChanged: (v) => setState(() => _settings = _settings.copyWith(distractors: v.first)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Verwechslungen: Es werden bevorzugt die Personen angeboten, die du bei dieser '
              'Person schon einmal fälschlich gewählt hast.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          _section('Zeitlimit'),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Keins')),
              ButtonSegment(value: 8, label: Text('8 s')),
              ButtonSegment(value: 4, label: Text('4 s')),
            ],
            selected: {_settings.timeLimit?.inSeconds ?? 0},
            onSelectionChanged: (v) => setState(() {
              final seconds = v.first;
              _settings = seconds == 0
                  ? _settings.copyWith(clearTimeLimit: true)
                  : _settings.copyWith(timeLimit: Duration(seconds: seconds));
            }),
          ),
          _section('Angezeigter Name'),
          SegmentedButton<NameStyle>(
            segments: const [
              ButtonSegment(value: NameStyle.firstName, label: Text('Vorname')),
              ButtonSegment(value: NameStyle.lastName, label: Text('Nachname')),
              ButtonSegment(value: NameStyle.full, label: Text('Beides')),
            ],
            selected: {_settings.nameStyle},
            onSelectionChanged: (v) => setState(() => _settings = _settings.copyWith(nameStyle: v.first)),
          ),
          _section('Runde'),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _settings.roundLength.toDouble(),
                  min: 5,
                  max: 40,
                  divisions: 7,
                  label: '${_settings.roundLength} Karten',
                  onChanged: (v) => setState(() => _settings = _settings.copyWith(roundLength: v.round())),
                ),
              ),
              Text('${_settings.roundLength} Karten'),
            ],
          ),
          _RoundHint(classId: widget.schoolClass.id, settings: _settings),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => QuizScreen(schoolClass: widget.schoolClass, settings: _settings),
              ),
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Runde starten'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(title, style: Theme.of(context).textTheme.titleSmall),
      );

  Widget _presetChip(String label, QuizSettings preset) => ActionChip(
        label: Text(label),
        onPressed: () => setState(() => _settings = preset.copyWith(
              mode: _settings.mode,
              nameStyle: _settings.nameStyle,
              roundLength: _settings.roundLength,
            )),
      );
}

/// How much of the class is already sitting securely.
///
/// This belongs here rather than next to the class name: on the start screen it
/// was a number without a use, while on the way into a round it is the thing
/// that decides whether to practise at all and how hard.
class _Progress extends ConsumerWidget {
  const _Progress({required this.classId});

  final int classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(classStatsProvider(classId));

    return stats.when(
      loading: () => const SizedBox(height: 48),
      error: (e, _) => const SizedBox(height: 48),
      data: (s) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.total == 0 ? 'Keine Personen in dieser Klasse' : '${s.secure} von ${s.total} sicher',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: s.ratio,
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// How far through the class to practise, cumulative.
///
/// The label carries the whole meaning — `1`, `1–2`, `1–3`, `alle` — so there
/// is no second switch saying whether earlier chunks come along. A toggle like
/// that would make the chips ambiguous: does "3" mean the third handful or the
/// first three?
class _ChunkPicker extends ConsumerWidget {
  const _ChunkPicker({
    required this.classId,
    required this.size,
    required this.step,
    required this.onSelected,
  });

  final int classId;
  final int size;
  final int step;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentsProvider(classId)).valueOrNull ?? const <Student>[];
    final boxes = ref.watch(studentBoxesProvider(classId)).valueOrNull ?? const <int, int>{};
    if (students.isEmpty) return const SizedBox.shrink();

    final chunks = chunksOf(students, size);
    final chosen = step.clamp(0, chunks.length - 1);
    final inPlay = upToChunk(chunks, chosen);
    final secure = inPlay.where((s) => (boxes[s.id] ?? 1) >= 4).length;

    String labelFor(int i) {
      if (i == chunks.length - 1 && chunks.length > 1) return 'alle';
      return i == 0 ? '1' : '1–${i + 1}';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < chunks.length; i++)
                ChoiceChip(
                  selected: i == chosen,
                  onSelected: (_) => onSelected(i),
                  label: Text(labelFor(i)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${inPlay.length} Personen im Spiel, davon $secure sicher.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          // Who is new at this step is the useful half: the earlier ones you
          // have met, these you have not.
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Neu ab hier: ${chunks[chosen].map((s) => s.firstName.isEmpty ? s.lastName : s.firstName).join(', ')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// What the automatic scope currently amounts to.
///
/// The mode has no controls, so this is the only way to see what it is doing —
/// and seeing it is what makes it trustworthy rather than mysterious.
class _AutomaticScope extends ConsumerWidget {
  const _AutomaticScope({required this.classId});

  final int classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentsProvider(classId)).valueOrNull ?? const <Student>[];
    final boxes = ref.watch(studentBoxesProvider(classId)).valueOrNull ?? const <int, int>{};
    if (students.isEmpty) return const SizedBox.shrink();

    int boxOf(Student student) => boxes[student.id] ?? 1;
    final inPlay = automaticScope(students, boxOf: boxOf);
    final learned = inPlay.where((s) => boxOf(s) >= learnedFromBox).length;
    final fresh = inPlay.where((s) => boxOf(s) < learnedFromBox).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${inPlay.length} von ${students.length} im Spiel — $learned sitzen, '
            '${fresh.length} werden gerade gelernt.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (fresh.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Dran: ${fresh.map((s) => s.firstName.isEmpty ? s.lastName : s.firstName).join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

/// What the round length amounts to for the chosen scope.
///
/// "15 Karten" says nothing on its own: over the whole class it is half a turn
/// each, over a handful it is three. The number that matters is the one this
/// line spells out.
class _RoundHint extends ConsumerWidget {
  const _RoundHint({required this.classId, required this.settings});

  final int classId;
  final QuizSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentsProvider(classId)).valueOrNull ?? const <Student>[];
    final boxes = ref.watch(studentBoxesProvider(classId)).valueOrNull ?? const <int, int>{};
    if (students.isEmpty) return const SizedBox.shrink();

    final inPlay = scopeFor(students, settings, boxOf: (s) => boxes[s.id] ?? 1);
    if (inPlay.isEmpty) return const SizedBox.shrink();

    final each = settings.roundLength / inPlay.length;
    final people = '${inPlay.length} ${inPlay.length == 1 ? 'Person' : 'Personen'}';

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        each >= 1
            ? '${settings.roundLength} Karten über $people — jede etwa ${each.round()}×.'
            : '${settings.roundLength} Karten über $people — nicht alle kommen dran.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
