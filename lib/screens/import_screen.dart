import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../import/pdf_import.dart';
import '../widgets/photo_zoom.dart';

/// PDF wählen → Klassenname vergeben → parsen → Review → speichern.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  String? _sourceFile;
  String? _label;
  bool _parsing = false;
  String? _error;
  List<ImportedPerson>? _people;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_people == null ? 'Neuer Satz' : 'Import prüfen')),
      body: _people != null
          ? _ReviewList(
              people: _people!,
              label: _label!,
              onDelete: (index) => setState(() => _people!.removeAt(index)),
              onEdit: _editPerson,
              onSave: _save,
            )
          : _buildPicker(context),
    );
  }

  Widget _buildPicker(BuildContext context) {
    if (_parsing) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('PDF wird ausgewertet …'),
          ],
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Wähle das Klassenfoto-PDF der Schulverwaltung aus.\n'
              'Fotos und Namen werden nur auf diesem Gerät gespeichert.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _pickAndParse,
              icon: const Icon(Icons.folder_open),
              label: const Text('PDF auswählen'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 24),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndParse() async {
    setState(() => _error = null);

    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    final file = picked?.files.singleOrNull;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return;
    if (!mounted) return;

    final defaultLabel = file.name.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
    final label = await _askForLabel(defaultLabel);
    if (label == null || !mounted) return;

    setState(() {
      _parsing = true;
      _sourceFile = file.name;
      _label = label;
    });

    try {
      final people = await parsePdf(Uint8List.fromList(bytes), sourceName: file.name);
      if (!mounted) return;
      if (people.isEmpty) {
        setState(() {
          _parsing = false;
          _error = 'In diesem PDF wurden keine Fotos gefunden. '
              'Stammt es wirklich aus der Klassenfoto-Ausgabe der Schulverwaltung?';
        });
        return;
      }
      setState(() {
        _parsing = false;
        _people = people;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _parsing = false;
        _error = 'Das PDF konnte nicht gelesen werden: $e';
      });
    }
  }

  Future<String?> _askForLabel(String initial) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Klassenname'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Name der Klasse',
            hintText: 'z.B. INF-G1H-SMA',
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim().isEmpty ? null : value.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.of(context).pop(value);
            },
            child: const Text('Weiter'),
          ),
        ],
      ),
    );
  }

  Future<void> _editPerson(int index) async {
    final person = _people![index];
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => _NameEditDialog(person: person),
    );
    if (result == null) return;
    setState(() {
      _people![index] = person.copyWith(firstName: result.$1, lastName: result.$2);
    });
  }

  Future<void> _save() async {
    final people = _people!;
    final db = ref.read(databaseProvider);
    await db.createPhotoSet(
      label: _label!,
      sourceFile: _sourceFile!,
      people: [
        for (final p in people)
          (
            displayName: p.displayName,
            firstName: p.firstName,
            lastName: p.lastName,
            jpegBytes: p.jpegBytes,
          ),
      ],
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${_label!}" mit ${people.length} Personen gespeichert')),
    );
    Navigator.of(context).pop();
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({
    required this.people,
    required this.label,
    required this.onDelete,
    required this.onEdit,
    required this.onSave,
  });

  final List<ImportedPerson> people;
  final String label;
  final void Function(int index) onDelete;
  final void Function(int index) onEdit;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '$label — ${people.length} Personen erkannt.\n'
            'Prüfe die Vor-/Nachnamen-Trennung: Tippe auf eine Karte zum Korrigieren.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: people.length,
            itemBuilder: (context, index) {
              final person = people[index];
              return _ReviewCard(
                person: person,
                onEdit: () => onEdit(index),
                onDelete: () => onDelete(index),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: people.isEmpty ? null : onSave,
              icon: const Icon(Icons.save),
              label: Text('${people.length} Personen speichern'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.person, required this.onEdit, required this.onDelete});

  final ImportedPerson person;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ZoomablePhoto(
                  jpegBytes: person.jpegBytes,
                  caption: person.displayName,
                  borderRadius: 0,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    tooltip: 'Karte entfernen',
                    style: IconButton.styleFrom(backgroundColor: Colors.black38),
                    onPressed: onDelete,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.firstName.isEmpty ? '—' : person.firstName,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    person.lastName,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lets the user move the split between last name and given names.
class _NameEditDialog extends StatefulWidget {
  const _NameEditDialog({required this.person});

  final ImportedPerson person;

  @override
  State<_NameEditDialog> createState() => _NameEditDialogState();
}

class _NameEditDialogState extends State<_NameEditDialog> {
  late List<String> _tokens;
  late int _splitAfter;

  @override
  void initState() {
    super.initState();
    _tokens = widget.person.displayName.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final lastNameTokens = widget.person.lastName.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).length;
    _splitAfter = lastNameTokens.clamp(1, _tokens.isEmpty ? 1 : _tokens.length);
  }

  @override
  Widget build(BuildContext context) {
    final lastName = _tokens.take(_splitAfter).join(' ');
    final firstName = _tokens.skip(_splitAfter).join(' ');
    return AlertDialog(
      title: const Text('Name aufteilen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wo endet der Nachname?'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: [
              for (var i = 0; i < _tokens.length; i++)
                ChoiceChip(
                  label: Text(_tokens[i]),
                  selected: i < _splitAfter,
                  onSelected: (_) => setState(() => _splitAfter = i + 1),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Nachname: $lastName'),
          Text('Vorname: ${firstName.isEmpty ? '—' : firstName}'),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Abbrechen')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop((firstName, lastName)),
          child: const Text('Übernehmen'),
        ),
      ],
    );
  }
}
