import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'database.dart';

/// Version marker so a future format change can be detected on import.
const _formatVersion = 1;

class ArchivedPerson {
  ArchivedPerson({
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.jpegBytes,
  });

  final String displayName;
  final String firstName;
  final String lastName;
  final Uint8List jpegBytes;
}

class ArchivedSet {
  ArchivedSet({required this.label, required this.sourceFile, required this.people});

  final String label;
  final String sourceFile;
  final List<ArchivedPerson> people;
}

/// Packs a class set into a ZIP: one manifest plus one JPEG per person.
///
/// Learning progress is deliberately left out — it belongs to the device it was
/// earned on, and carrying it over would misrepresent what the learner knows.
Uint8List exportSet(PhotoSet set, List<Person> people) {
  final archive = Archive();
  final manifest = {
    'version': _formatVersion,
    'label': set.label,
    'sourceFile': set.sourceFile,
    'people': [
      for (var i = 0; i < people.length; i++)
        {
          'displayName': people[i].displayName,
          'firstName': people[i].firstName,
          'lastName': people[i].lastName,
          'photo': '$i.jpg',
        },
    ],
  };

  final manifestBytes = utf8.encode(jsonEncode(manifest));
  archive.addFile(ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));
  for (var i = 0; i < people.length; i++) {
    final bytes = people[i].jpegBytes;
    archive.addFile(ArchiveFile('$i.jpg', bytes.length, bytes));
  }
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

/// Reads a ZIP written by [exportSet].
ArchivedSet importSet(Uint8List zipBytes) {
  final archive = ZipDecoder().decodeBytes(zipBytes);
  final manifestFile = archive.findFile('manifest.json');
  if (manifestFile == null) {
    throw const FormatException('Kein manifest.json im ZIP — stammt die Datei aus dieser App?');
  }

  final manifest = jsonDecode(utf8.decode(manifestFile.content as List<int>)) as Map<String, dynamic>;
  final version = manifest['version'] as int?;
  if (version != _formatVersion) {
    throw FormatException('Unbekannte Archiv-Version: $version');
  }

  final people = <ArchivedPerson>[];
  for (final entry in (manifest['people'] as List).cast<Map<String, dynamic>>()) {
    final photo = archive.findFile(entry['photo'] as String);
    if (photo == null) {
      throw FormatException('Foto ${entry['photo']} fehlt im ZIP.');
    }
    people.add(ArchivedPerson(
      displayName: entry['displayName'] as String,
      firstName: entry['firstName'] as String,
      lastName: entry['lastName'] as String,
      jpegBytes: Uint8List.fromList(photo.content as List<int>),
    ));
  }

  return ArchivedSet(
    label: manifest['label'] as String,
    sourceFile: manifest['sourceFile'] as String,
    people: people,
  );
}
