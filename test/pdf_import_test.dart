import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/import/pdf_import.dart';
import 'package:pdfrx/pdfrx.dart';

/// These run against the real class-photo PDFs, which are deliberately kept out
/// of version control. They skip themselves when the fixtures are absent.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // pdfrx would otherwise ask path_provider for a cache directory, and there is
  // no platform channel behind it in tests. Setting it up front skips that.
  Pdfrx.cacheDirectoryPath ??= Directory.systemTemp.createTempSync('nomen_est_test').path;

  group('parsePdf', () {
    test('Gymi set: 21 students on one page', () async {
      final students = await _parseFixture('pdfs/g2026h.pdf');
      if (students == null) return;

      expect(students.length, 21);
      expect(students.first.displayName, 'Brändli Lyan');
      expect(students.last.displayName, 'Wernli Carina');
      expect(students.map((p) => p.displayName), contains('Goldenberger Larissa'));
      expect(students.map((p) => p.displayName), contains('Mühlhäuser Niklas David'));
      expect(students.map((p) => p.displayName), contains('Tüscher Laurin Jonas'));
      expect(students.map((p) => p.displayName), contains('Huber Diana Elena'));
    });

    test('FMS set: 25 + 1 students across two pages', () async {
      final students = await _parseFixture('pdfs/f2026A.pdf');
      if (students == null) return;

      expect(students.length, 26);
      expect(students.first.displayName, 'Adili Erijona');
      expect(students.last.displayName, 'Zumsteg Roxy');
      expect(students.map((p) => p.displayName), contains('Ahumada Torres Gloria'));
    });

    test('no name picks up the footer date', () async {
      final students = await _parseFixture('pdfs/g2026h.pdf');
      if (students == null) return;

      for (final student in students) {
        expect(student.displayName, isNot(contains('August')));
        expect(student.displayName, isNot(contains('2026')));
      }
    });

    test('no name picks up the page header', () async {
      final students = await _parseFixture('pdfs/f2026A.pdf');
      if (students == null) return;

      for (final student in students) {
        expect(student.displayName, isNot(contains('Kurses')));
        expect(student.displayName, isNot(contains('INF-')));
        expect(student.displayName, isNot(contains('Fortsetzung')));
      }
    });

    test('every student gets a non-empty JPEG', () async {
      final students = await _parseFixture('pdfs/g2026h.pdf');
      if (students == null) return;

      for (final student in students) {
        expect(student.jpegBytes.length, greaterThan(500));
        expect(student.jpegBytes.take(2), [0xFF, 0xD8], reason: 'JPEG magic bytes');
      }
    });

    test('orderIndex is contiguous across pages', () async {
      final students = await _parseFixture('pdfs/f2026A.pdf');
      if (students == null) return;

      expect(students.map((p) => p.orderIndex), List.generate(students.length, (i) => i));
    });
  });

  group('splitName', () {
    test('single-token last name', () {
      expect(splitName('Brändli Lyan'), ('Lyan', 'Brändli'));
    });

    test('two given names stay together', () {
      expect(splitName('Huber Diana Elena'), ('Diana Elena', 'Huber'));
    });

    test('two-token last name is guessed wrong — review screen must fix it', () {
      expect(splitName('Ahumada Torres Gloria'), ('Torres Gloria', 'Ahumada'));
    });

    test('lone token becomes the last name', () {
      expect(splitName('Zumsteg'), ('', 'Zumsteg'));
    });

    test('empty input', () {
      expect(splitName(''), ('', ''));
      expect(splitName('   '), ('', ''));
    });
  });
}

Future<List<ImportedStudent>?> _parseFixture(String path) async {
  final file = File(path);
  if (!file.existsSync()) {
    markTestSkipped('fixture $path not available (PDFs are not committed)');
    return null;
  }
  return parsePdf(await file.readAsBytes(), sourceName: path);
}
