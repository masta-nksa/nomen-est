import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/providers.dart';
import 'gallery_screen.dart';
import 'quiz_setup_screen.dart';

/// Choose which class to practise.
class ClassPickerScreen extends ConsumerWidget {
  const ClassPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(classesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Klasse wählen')),
      body: classes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) => _ClassTile(schoolClass: list[index]),
        ),
      ),
    );
  }
}

class _ClassTile extends ConsumerWidget {
  const _ClassTile({required this.schoolClass});

  final SchoolClass schoolClass;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(classStatsProvider(schoolClass.id));
    return ListTile(
      title: Text(schoolClass.label),
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
              MaterialPageRoute(builder: (_) => GalleryScreen(schoolClass: schoolClass)),
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => QuizSetupScreen(schoolClass: schoolClass)),
      ),
    );
  }
}
