import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'database.dart';

/// Version marker so a future format change can be detected on import.
///
/// The manifest still says `people` where the app now says students — the file
/// format is a wire format, and renaming a key would reject every archive that
/// has already been written for no gain.
const _formatVersion = 1;

class ArchivedStudent {
  ArchivedStudent({
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

class ArchivedClass {
  ArchivedClass({required this.label, required this.sourceFile, required this.students});

  final String label;
  final String sourceFile;
  final List<ArchivedStudent> students;
}

/// Packs a class into a ZIP: one manifest plus one JPEG per student.
///
/// Learning progress is deliberately left out — it belongs to the device it was
/// earned on, and carrying it over would misrepresent what the learner knows.
/// The same goes for draws, absences and groups: they record what happened in
/// one teacher's lessons, not what the class is.
Uint8List exportClass(SchoolClass schoolClass, List<Student> students) {
  final archive = Archive();
  final manifest = {
    'version': _formatVersion,
    'label': schoolClass.label,
    'sourceFile': schoolClass.sourceFile,
    'people': [
      for (var i = 0; i < students.length; i++)
        {
          'displayName': students[i].displayName,
          'firstName': students[i].firstName,
          'lastName': students[i].lastName,
          'photo': '$i.jpg',
        },
    ],
  };

  final manifestBytes = utf8.encode(jsonEncode(manifest));
  archive.addFile(ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));
  for (var i = 0; i < students.length; i++) {
    final bytes = students[i].jpegBytes;
    archive.addFile(ArchiveFile('$i.jpg', bytes.length, bytes));
  }
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

/// Reads a ZIP written by [exportClass].
ArchivedClass importClass(Uint8List zipBytes) {
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

  final students = <ArchivedStudent>[];
  for (final entry in (manifest['people'] as List).cast<Map<String, dynamic>>()) {
    final photo = archive.findFile(entry['photo'] as String);
    if (photo == null) {
      throw FormatException('Foto ${entry['photo']} fehlt im ZIP.');
    }
    students.add(ArchivedStudent(
      displayName: entry['displayName'] as String,
      firstName: entry['firstName'] as String,
      lastName: entry['lastName'] as String,
      jpegBytes: Uint8List.fromList(photo.content as List<int>),
    ));
  }

  return ArchivedClass(
    label: manifest['label'] as String,
    sourceFile: manifest['sourceFile'] as String,
    students: students,
  );
}
