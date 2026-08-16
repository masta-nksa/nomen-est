import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/class_archive.dart';
import '../data/database.dart';
import '../data/providers.dart';

class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(classesProvider);
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
      body: classes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (list) => list.isEmpty
            ? const Center(child: Text('Noch keine Klassen vorhanden.'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) => _ClassTile(schoolClass: list[index]),
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
      final archived = importClass(Uint8List.fromList(bytes));
      await ref.read(databaseProvider).createClass(
            label: archived.label,
            sourceFile: archived.sourceFile,
            students: [
              for (final s in archived.students)
                (
                  displayName: s.displayName,
                  firstName: s.firstName,
                  lastName: s.lastName,
                  jpegBytes: s.jpegBytes,
                ),
            ],
          );
      messenger.showSnackBar(
        SnackBar(content: Text('"${archived.label}" mit ${archived.students.length} Personen importiert')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Import fehlgeschlagen: $e')));
    }
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
          data: (s) => '${s.total} Personen · ${s.secure} sicher',
          loading: () => '…',
          error: (e, _) => 'Statistik nicht verfügbar',
        ),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => switch (value) {
          'rename' => _rename(context, ref),
          'export' => _export(context, ref),
          'reset' => _reset(context, ref),
          'delete' => _delete(context, ref),
          _ => null,
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'rename', child: Text('Umbenennen')),
          PopupMenuItem(value: 'export', child: Text('Als ZIP exportieren')),
          PopupMenuItem(value: 'reset', child: Text('Zurücksetzen …')),
          PopupMenuItem(value: 'delete', child: Text('Löschen')),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: schoolClass.label);
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
    await ref.read(databaseProvider).renameClass(schoolClass.id, name);
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final db = ref.read(databaseProvider);
    final students = await db.studentsInClass(schoolClass.id);
    final zip = exportClass(schoolClass, students);

    final path = await FilePicker.saveFile(
      dialogTitle: 'Klasse exportieren',
      fileName: '${schoolClass.label}.zip',
      type: FileType.custom,
      allowedExtensions: ['zip'],
      bytes: zip,
    );
    messenger.showSnackBar(SnackBar(
      content: Text(path == null ? 'Export abgebrochen' : 'Exportiert: ${schoolClass.label}.zip'),
    ));
  }

  /// The four histories are reset separately on purpose: forgetting the quiz
  /// results must not also forget who was already called on this term.
  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final choice = await showDialog<_ResetKind>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('"${schoolClass.label}" zurücksetzen'),
        children: [
          for (final kind in _ResetKind.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(kind),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(kind.icon),
                title: Text(kind.title),
                subtitle: Text(kind.description),
              ),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(),
            child: const Align(alignment: Alignment.centerRight, child: Text('Abbrechen')),
          ),
        ],
      ),
    );
    if (choice == null) return;
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${choice.title}?'),
        content: Text(choice.confirmation),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Zurücksetzen')),
        ],
      ),
    );
    if (confirmed != true) return;

    final db = ref.read(databaseProvider);
    await switch (choice) {
      _ResetKind.progress => db.resetProgress(schoolClass.id),
      _ResetKind.draws => db.resetDrawHistory(schoolClass.id),
      _ResetKind.absences => db.resetAbsences(schoolClass.id),
      _ResetKind.groups => db.resetGroupHistory(schoolClass.id),
    };
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('"${schoolClass.label}" löschen?'),
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
    await ref.read(databaseProvider).deleteClass(schoolClass.id);
  }
}

enum _ResetKind {
  progress(
    Icons.school_outlined,
    'Lernfortschritt',
    'Leitner-Boxen und Verwechslungen',
    'Die Lernfortschritte und Verwechslungen werden gelöscht. Fotos, Namen und '
        'alles aus dem Unterricht bleiben erhalten.',
  ),
  draws(
    Icons.casino_outlined,
    'Ziehungen',
    'Wer schon aufgerufen wurde',
    'Der Ziehungsverlauf wird gelöscht. Der Topf ist danach wieder voll und die '
        'Statistik beginnt bei null.',
  ),
  absences(
    Icons.how_to_reg_outlined,
    'Anwesenheit',
    'Alle erfassten Abwesenheiten',
    'Alle erfassten Abwesenheiten werden gelöscht — danach gelten wieder alle '
        'als anwesend.',
  ),
  groups(
    Icons.groups_outlined,
    'Gruppenverlauf',
    'Gespeicherte Einteilungen und Paarungen',
    'Gespeicherte Einteilungen und die Paarungshistorie werden gelöscht. '
        'Feste Regeln (zusammen / getrennt) bleiben bestehen.',
  );

  const _ResetKind(this.icon, this.title, this.description, this.confirmation);

  final IconData icon;
  final String title;
  final String description;
  final String confirmation;
}
