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
  static const _sizeKey = 'quiz.chunkSize';
  static const _indexKey = 'quiz.chunkIndex';

  QuizSettings _settings = const QuizSettings();

  @override
  void initState() {
    super.initState();
    _restoreChunk();
  }

  /// Only the chunk survives a restart, not the difficulty dials: which handful
  /// you are working through is a place you left off, while the dials are a
  /// decision you make for the round you are about to start.
  Future<void> _restoreChunk() async {
    final store = ref.read(settingsProvider);
    final classId = widget.schoolClass.id;
    final size = int.tryParse(await store.read(_sizeKey, classId: classId) ?? '');
    final index = int.tryParse(await store.read(_indexKey, classId: classId) ?? '') ?? 0;
    if (!mounted) return;
    setState(() => _settings = _settings.copyWith(chunkSize: size, chunkIndex: index));
  }

  Future<void> _setChunkSize(int size) async {
    setState(() => _settings = size == 0
        ? _settings.copyWith(clearChunkSize: true, chunkIndex: 0)
        : _settings.copyWith(chunkSize: size, chunkIndex: 0));
    final store = ref.read(settingsProvider);
    await store.write(_sizeKey, '$size', classId: widget.schoolClass.id);
    await store.write(_indexKey, '0', classId: widget.schoolClass.id);
  }

  Future<void> _setChunkIndex(int index) async {
    setState(() => _settings = _settings.copyWith(chunkIndex: index));
    await ref.read(settingsProvider).write(_indexKey, '$index', classId: widget.schoolClass.id);
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
          _section('Häppchen'),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Aus')),
              ButtonSegment(value: 4, label: Text('4')),
              ButtonSegment(value: 5, label: Text('5')),
              ButtonSegment(value: 6, label: Text('6')),
              ButtonSegment(value: 8, label: Text('8')),
            ],
            selected: {_settings.chunkSize ?? 0},
            onSelectionChanged: (v) => _setChunkSize(v.first),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _settings.chunkSize == null
                  ? 'Die ganze Klasse auf einmal. Bei grossen Klassen kommt jede '
                      'Person pro Runde nur selten dran.'
                  : 'Nur diese Handvoll üben. Die Gesichter kehren dadurch viel '
                      'schneller wieder, und die Auswahlmöglichkeiten kommen '
                      'ebenfalls aus dem Häppchen.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (_settings.chunkSize != null)
            _ChunkPicker(
              classId: widget.schoolClass.id,
              size: _settings.chunkSize!,
              index: _settings.chunkIndex,
              onSelected: _setChunkIndex,
            ),
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

/// Which handful to work through, and how far along each one is.
///
/// The "sicher" count per chunk is the thing that decides where to go next, so
/// it sits on the chip rather than a level down. The names below make the chunk
/// concrete — you are about to look at these five faces, not at "chunk 3".
class _ChunkPicker extends ConsumerWidget {
  const _ChunkPicker({
    required this.classId,
    required this.size,
    required this.index,
    required this.onSelected,
  });

  final int classId;
  final int size;
  final int index;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentsProvider(classId)).valueOrNull ?? const <Student>[];
    final boxes = ref.watch(studentBoxesProvider(classId)).valueOrNull ?? const <int, int>{};
    if (students.isEmpty) return const SizedBox.shrink();

    final chunks = chunksOf(students, size);
    final chosen = index.clamp(0, chunks.length - 1);

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
                  label: Text(
                    '${i + 1}  ·  ${chunks[i].where((s) => (boxes[s.id] ?? 1) >= 4).length}'
                    '/${chunks[i].length}',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            chunks[chosen].map((s) => s.firstName.isEmpty ? s.lastName : s.firstName).join(', '),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Die Zahl auf dem Chip zeigt, wie viele daraus schon sitzen.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
