import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/providers.dart';
import '../data/selection_repository.dart';
import '../draw/draw_settings.dart';
import '../widgets/mode_chip_bar.dart';
import '../widgets/photo_zoom.dart';
import 'attendance_screen.dart';

/// Draws a student, or several.
///
/// The pool is not held here — it is recomputed from the draw log after every
/// action, so what the screen shows and what the database believes cannot drift
/// apart.
class DrawScreen extends ConsumerStatefulWidget {
  const DrawScreen({super.key, required this.schoolClass});

  final SchoolClass schoolClass;

  @override
  ConsumerState<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends ConsumerState<DrawScreen> {
  List<Student> _drawn = const [];
  bool _busy = false;

  int get _classId => widget.schoolClass.id;

  @override
  Widget build(BuildContext context) {
    final pool = ref.watch(poolProvider(_classId));
    final settings = ref.watch(drawSettingsProvider(_classId)).valueOrNull ?? const DrawSettings();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.schoolClass.label),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => switch (value) {
              'round' => _startNewRound(),
              _ => null,
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'round',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.restart_alt),
                  title: Text('Neue Runde'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(child: _Result(drawn: _drawn)),
                  const SizedBox(height: 12),
                  ModeChipBar(chips: _chips(pool.valueOrNull, settings)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (_drawn.isNotEmpty) ...[
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _undo,
                          icon: const Icon(Icons.undo),
                          label: const Text('Zurück'),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _draw,
                          icon: const Icon(Icons.casino),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(_drawn.isEmpty ? 'Würfeln' : 'Nochmal'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChip> _chips(PoolState? pool, DrawSettings settings) {
    return [
      ModeChip(
        label: 'Wiederholung',
        iconOn: Icons.repeat,
        iconOff: Icons.repeat_outlined,
        on: settings.replacement,
        explanation: settings.replacement
            ? 'Gezogene bleiben im Topf und können nochmal drankommen.'
            : 'Wer dran war, kommt erst nach einer neuen Runde wieder dran.',
        onTap: () => _update(settings.copyWith(replacement: !settings.replacement)),
      ),
      if (pool != null) ...[
        StatusChip(
          label: '${pool.available.length}/${pool.total}',
          progress: poolProgress(pool.available.length, pool.total),
          explanation: pool.absent.isEmpty
              ? 'Noch nicht dran gewesen.'
              : 'Noch nicht dran gewesen. ${pool.absent.length} heute abwesend.',
          onTap: () => _showPool(pool),
        ),
        StatusChip(
          label: '${pool.total - pool.absent.length}/${pool.total} da',
          icon: Icons.how_to_reg,
          explanation: 'Wer heute fehlt, wird nicht gezogen — und verbraucht '
              'seinen Zug auch nicht.',
          onTap: _openAttendance,
        ),
      ],
      TuningChip(
        label: settings.count == 1 ? 'Einzeln' : '×${settings.count}',
        icon: Icons.groups_2_outlined,
        atDefault: settings.count == 1,
        value: '${settings.count}',
        explanation: 'Wie viele auf einmal gezogen werden.',
        onTap: () => _pickNumber(
          title: 'Wie viele auf einmal?',
          current: settings.count,
          options: const [1, 2, 3, 4, 5],
          onPicked: (value) => _update(settings.copyWith(count: value)),
        ),
      ),
      TuningChip(
        label: settings.cooldown == 0 ? 'Pause aus' : 'Pause ${settings.cooldown}',
        icon: Icons.hourglass_empty,
        atDefault: settings.cooldown == const DrawSettings().cooldown,
        value: settings.cooldown == 0 ? 'aus' : '${settings.cooldown}',
        explanation: 'So viele der zuletzt Gezogenen werden übersprungen — '
            'ausser es bliebe niemand übrig.',
        onTap: () => _pickNumber(
          title: 'Wie viele überspringen?',
          current: settings.cooldown,
          options: const [0, 1, 2, 3, 5],
          onPicked: (value) => _update(settings.copyWith(cooldown: value)),
        ),
      ),
    ];
  }

  Future<void> _update(DrawSettings settings) =>
      ref.read(drawSettingsProvider(_classId).notifier).save(settings);

  /// A status chip shows a detail rather than switching something — and a
  /// mistyped tap must not wipe the round that is running.
  Future<void> _showPool(PoolState pool) async {
    final students = await ref.read(databaseProvider).studentsInClass(_classId);
    if (!mounted) return;
    final byId = {for (final student in students) student.id: student};

    final start = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Noch im Topf: ${pool.available.length} von ${pool.total}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _NameWrap(names: [for (final student in pool.available) student.firstName]),
              if (pool.drawn.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('Schon dran', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                _NameWrap(
                  names: [for (final id in pool.drawn) byId[id]?.firstName ?? '?'],
                  muted: true,
                ),
              ],
              if (pool.absent.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('Heute abwesend', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                _NameWrap(
                  names: [for (final id in pool.absent) byId[id]?.firstName ?? '?'],
                  muted: true,
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.restart_alt),
                label: const Text('Neue Runde'),
              ),
            ],
          ),
        ),
      ),
    );
    if (start == true) await _startNewRound();
  }

  Future<void> _openAttendance() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AttendanceScreen(schoolClass: widget.schoolClass),
    ));
    ref.invalidate(poolProvider(_classId));
  }

  Future<void> _pickNumber({
    required String title,
    required int current,
    required List<int> options,
    required void Function(int) onPicked,
  }) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(title)),
            for (final option in options)
              ListTile(
                title: Text(option == 0 ? 'aus' : '$option'),
                trailing: option == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _draw() async {
    setState(() => _busy = true);
    try {
      final settings = await ref.read(drawSettingsProvider(_classId).future);
      final drawn = await ref.read(selectionRepositoryProvider).draw(
            classId: _classId,
            settings: settings,
          );
      if (!mounted) return;

      if (drawn.isEmpty) {
        await _offerNewRound();
        return;
      }
      setState(() => _drawn = drawn);
    } catch (e) {
      _report('Ziehen fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
      ref.invalidate(poolProvider(_classId));
    }
  }

  /// An empty pool asks rather than silently starting over: seeing where a
  /// round ended is the point of recording the reset at all.
  Future<void> _offerNewRound() async {
    final pool = await ref.read(selectionRepositoryProvider).pool(_classId);
    if (!mounted) return;

    final everyone = pool.total - pool.absent.length;
    final start = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alle waren dran'),
        content: Text(
          everyone <= 0
              ? 'Heute ist niemand anwesend.'
              : 'Alle $everyone Anwesenden waren dran. Neue Runde starten?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Abbrechen')),
          if (everyone > 0)
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Neue Runde')),
        ],
      ),
    );
    if (start == true) await _startNewRound(silent: true);
  }

  Future<void> _startNewRound({bool silent = false}) async {
    await ref.read(selectionRepositoryProvider).startNewRound(_classId);
    ref.invalidate(poolProvider(_classId));
    if (!mounted) return;
    setState(() => _drawn = const []);
    if (!silent) _report('Neue Runde — alle sind wieder im Topf.');
  }

  Future<void> _undo() async {
    setState(() => _busy = true);
    try {
      final undone = await ref.read(selectionRepositoryProvider).undoLastDraw(_classId);
      if (!mounted) return;
      setState(() => _drawn = const []);
      if (!undone) _report('Es gibt nichts zurückzunehmen.');
    } finally {
      if (mounted) setState(() => _busy = false);
      ref.invalidate(poolProvider(_classId));
    }
  }

  void _report(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _NameWrap extends StatelessWidget {
  const _NameWrap({required this.names, this.muted = false});

  final List<String> names;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (names.isEmpty) return Text('—', style: TextStyle(color: scheme.onSurfaceVariant));

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final name in names)
          Chip(
            label: Text(name.isEmpty ? '?' : name),
            visualDensity: VisualDensity.compact,
            backgroundColor: muted ? scheme.surfaceContainerHighest : scheme.secondaryContainer,
            side: BorderSide.none,
          ),
      ],
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.drawn});

  final List<Student> drawn;

  @override
  Widget build(BuildContext context) {
    if (drawn.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.casino_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            const Text('Noch niemand gezogen.'),
          ],
        ),
      );
    }

    if (drawn.length == 1) return _Portrait(student: drawn.single, large: true);

    return GridView.count(
      crossAxisCount: drawn.length <= 4 ? 2 : 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.8,
      children: [for (final student in drawn) _Portrait(student: student, large: false)],
    );
  }
}

class _Portrait extends StatelessWidget {
  const _Portrait({required this.student, required this.large});

  final Student student;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: large ? maxPhotoSize : 160,
              maxHeight: large ? maxPhotoSize : 160,
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: ZoomablePhoto(
                jpegBytes: student.jpegBytes,
                caption: student.displayName,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          student.displayName,
          textAlign: TextAlign.center,
          style: large ? theme.textTheme.headlineMedium : theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}
