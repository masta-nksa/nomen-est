import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/providers.dart';
import 'classes_screen.dart';
import 'import_screen.dart';
import 'quiz_setup_screen.dart';

/// Class first, then what to do with it.
///
/// The class sits above the features rather than inside each of them, because
/// attendance, the draw pool and the grouping all depend on it — picking it
/// once per feature would be four chances to work on the wrong one.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(classesProvider);
    final selected = ref.watch(selectedClassProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nomen est'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Verwaltung',
            onSelected: (value) => switch (value) {
              'import' => _open(context, const ImportScreen()),
              'manage' => _open(context, const ClassesScreen()),
              _ => null,
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'import',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.add_photo_alternate_outlined),
                  title: Text('Neue Klasse'),
                ),
              ),
              PopupMenuItem(
                value: 'manage',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.folder_outlined),
                  title: Text('Klassen verwalten'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: classes.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _Message(
              icon: Icons.error_outline,
              text: 'Die Datenbank konnte nicht gelesen werden.\n\n$e',
            ),
            data: (list) => list.isEmpty ? const _EmptyState() : _Home(selected: selected),
          ),
        ),
      ),
    );
  }

  static void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _Home extends ConsumerWidget {
  const _Home({required this.selected});

  final SchoolClass? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolClass = selected;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ClassBar(selected: schoolClass),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: [
            _FeatureTile(
              icon: Icons.school_outlined,
              label: 'Namen lernen',
              onTap: schoolClass == null
                  ? null
                  : () => HomeScreen._open(context, QuizSetupScreen(schoolClass: schoolClass)),
            ),
            const _FeatureTile(icon: Icons.casino_outlined, label: 'Zufall', hint: 'kommt als Nächstes'),
            const _FeatureTile(icon: Icons.groups_outlined, label: 'Gruppen', hint: 'später'),
            const _FeatureTile(icon: Icons.bar_chart_outlined, label: 'Statistik', hint: 'später'),
          ],
        ),
        const SizedBox(height: 24),
        const _PrivacyNote(),
      ],
    );
  }
}

/// The current class, and a tap to switch. Carries the "sicher" count so the
/// most-looked-at number is on the first screen rather than a level down.
class _ClassBar extends ConsumerWidget {
  const _ClassBar({required this.selected});

  final SchoolClass? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final schoolClass = selected;
    final stats = schoolClass == null ? null : ref.watch(classStatsProvider(schoolClass.id));

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: const Icon(Icons.class_outlined),
        title: Text(
          schoolClass?.label ?? 'Klasse wählen',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: stats == null
            ? null
            : Text(stats.when(
                data: (s) => s.total == 0 ? 'Keine Personen' : '${s.secure} von ${s.total} sicher',
                loading: () => '…',
                error: (e, _) => 'Statistik nicht verfügbar',
              )),
        trailing: const Icon(Icons.expand_more),
        onTap: () => _pick(context, ref),
      ),
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final classes = ref.read(classesProvider).valueOrNull ?? const <SchoolClass>[];
    final picked = await showModalBottomSheet<SchoolClass>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final schoolClass in classes)
              ListTile(
                title: Text(schoolClass.label),
                trailing: schoolClass.id == selected?.id ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(schoolClass),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    await ref.read(selectedClassProvider.notifier).select(picked);
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.label, this.hint, this.onTap});

  final IconData icon;
  final String label;

  /// Shown instead of an action when the feature is not built yet — an empty
  /// tile that does nothing reads as a bug, a labelled one as a roadmap.
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    final foreground = enabled ? scheme.onSecondaryContainer : scheme.onSurfaceVariant;

    return Card(
      color: enabled ? scheme.secondaryContainer : scheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: foreground),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: foreground),
              ),
              if (hint != null)
                Text(
                  hint!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Noch keine Klasse vorhanden.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Lies ein Klassenfoto-PDF der Schulverwaltung ein, dann geht es los.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => HomeScreen._open(context, const ImportScreen()),
            icon: const Icon(Icons.add_photo_alternate),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Neue Klasse'),
            ),
          ),
          const SizedBox(height: 32),
          const _PrivacyNote(),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline, size: 20, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Alle Fotos bleiben auf diesem Gerät. Auf iPhone/iPad die App zuerst zum '
                'Home-Bildschirm hinzufügen, sonst löscht Safari die Daten nach 7 Tagen.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
