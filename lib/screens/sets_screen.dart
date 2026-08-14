import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/providers.dart';
import '../data/set_archive.dart';

class SetsScreen extends ConsumerWidget {
  const SetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sets = ref.watch(photoSetsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Klassen verwalten'),
        actions: [
          IconButton(
            icon: const Icon(Icons.unarchive),
            tooltip: 'ZIP importieren',
            onPressed: () => _importZip(context, ref),
          ),
        ],
      ),
      body: sets.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (list) => list.isEmpty
            ? const Center(child: Text('Noch keine Klassen vorhanden.'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) => _SetTile(set: list[index]),
              ),
      ),
    );
  }

  Future<void> _importZip(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      withData: true,
    );
    final bytes = picked?.files.singleOrNull?.bytes;
    if (bytes == null) return;

    try {
      final archived = importSet(Uint8List.fromList(bytes));
      await ref.read(databaseProvider).createPhotoSet(
            label: archived.label,
            sourceFile: archived.sourceFile,
            people: [
              for (final p in archived.people)
                (
                  displayName: p.displayName,
                  firstName: p.firstName,
                  lastName: p.lastName,
                  jpegBytes: p.jpegBytes,
                ),
            ],
          );
      messenger.showSnackBar(
        SnackBar(content: Text('"${archived.label}" mit ${archived.people.length} Personen importiert')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Import fehlgeschlagen: $e')));
    }
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
          data: (s) => '${s.total} Personen · ${s.secure} sicher',
          loading: () => '…',
          error: (e, _) => 'Statistik nicht verfügbar',
        ),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => switch (value) {
          'rename' => _rename(context, ref),
          'export' => _export(context, ref),
          'reset' => _resetProgress(context, ref),
          'delete' => _delete(context, ref),
          _ => null,
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'rename', child: Text('Umbenennen')),
          PopupMenuItem(value: 'export', child: Text('Als ZIP exportieren')),
          PopupMenuItem(value: 'reset', child: Text('Fortschritt zurücksetzen')),
          PopupMenuItem(value: 'delete', child: Text('Löschen')),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: set.label);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Klasse umbenennen'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.of(context).pop(value);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
    if (name == null) return;
    await ref.read(databaseProvider).renamePhotoSet(set.id, name);
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final db = ref.read(databaseProvider);
    final people = await db.personsInSet(set.id);
    final zip = exportSet(set, people);

    final path = await FilePicker.saveFile(
      dialogTitle: 'Klassensatz exportieren',
      fileName: '${set.label}.zip',
      type: FileType.custom,
      allowedExtensions: ['zip'],
      bytes: zip,
    );
    messenger.showSnackBar(SnackBar(
      content: Text(path == null ? 'Export abgebrochen' : 'Exportiert: ${set.label}.zip'),
    ));
  }

  Future<void> _resetProgress(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fortschritt zurücksetzen?'),
        content: Text(
          'Die Lernfortschritte und Verwechslungen von "${set.label}" werden gelöscht. '
          'Fotos und Namen bleiben erhalten.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Zurücksetzen')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(databaseProvider).resetProgress(set.id);
    ref.invalidate(setStatsProvider(set.id));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('"${set.label}" löschen?'),
        content: const Text(
          'Alle Fotos, Namen und Lernfortschritte dieser Klasse werden entfernt. '
          'Das lässt sich nur über einen früheren ZIP-Export rückgängig machen.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Abbrechen')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(databaseProvider).deletePhotoSet(set.id);
  }
}
