import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/providers.dart';
import 'gallery_screen.dart';
import 'quiz_setup_screen.dart';

/// Choose which class set to practise.
class SetPickerScreen extends ConsumerWidget {
  const SetPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sets = ref.watch(photoSetsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Klasse wählen')),
      body: sets.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) => _SetTile(set: list[index]),
        ),
      ),
    );
  }
}

class _SetTile extends ConsumerWidget {
  const _SetTile({required this.set});

  final PhotoSet set;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(setStatsProvider(set.id));
    return ListTile(
      title: Text(set.label),
      subtitle: Text(
        stats.when(
          data: (s) => s.total == 0 ? 'Keine Personen' : '${s.secure}/${s.total} sicher',
          loading: () => '…',
          error: (e, _) => 'Statistik nicht verfügbar',
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: 'Galerie',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => GalleryScreen(set: set)),
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => QuizSetupScreen(set: set)),
      ),
    );
  }
}
