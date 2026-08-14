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
    test('Gymi set: 21 people on one page', () async {
      final people = await _parseFixture('pdfs/g2026h.pdf');
      if (people == null) return;

      expect(people.length, 21);
      expect(people.first.displayName, 'Brändli Lyan');
      expect(people.last.displayName, 'Wernli Carina');
      expect(people.map((p) => p.displayName), contains('Goldenberger Larissa'));
      expect(people.map((p) => p.displayName), contains('Mühlhäuser Niklas David'));
      expect(people.map((p) => p.displayName), contains('Tüscher Laurin Jonas'));
      expect(people.map((p) => p.displayName), contains('Huber Diana Elena'));
    });

    test('FMS set: 25 + 1 people across two pages', () async {
      final people = await _parseFixture('pdfs/f2026A.pdf');
      if (people == null) return;

      expect(people.length, 26);
      expect(people.first.displayName, 'Adili Erijona');
      expect(people.last.displayName, 'Zumsteg Roxy');
      expect(people.map((p) => p.displayName), contains('Ahumada Torres Gloria'));
    });

    test('no name picks up the footer date', () async {
      final people = await _parseFixture('pdfs/g2026h.pdf');
      if (people == null) return;

      for (final person in people) {
        expect(person.displayName, isNot(contains('August')));
        expect(person.displayName, isNot(contains('2026')));
      }
    });

    test('no name picks up the page header', () async {
      final people = await _parseFixture('pdfs/f2026A.pdf');
      if (people == null) return;

      for (final person in people) {
        expect(person.displayName, isNot(contains('Kurses')));
        expect(person.displayName, isNot(contains('INF-')));
        expect(person.displayName, isNot(contains('Fortsetzung')));
      }
    });

    test('every person gets a non-empty JPEG', () async {
      final people = await _parseFixture('pdfs/g2026h.pdf');
      if (people == null) return;

      for (final person in people) {
        expect(person.jpegBytes.length, greaterThan(500));
        expect(person.jpegBytes.take(2), [0xFF, 0xD8], reason: 'JPEG magic bytes');
      }
    });

    test('orderIndex is contiguous across pages', () async {
      final people = await _parseFixture('pdfs/f2026A.pdf');
      if (people == null) return;

      expect(people.map((p) => p.orderIndex), List.generate(people.length, (i) => i));
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

Future<List<ImportedPerson>?> _parseFixture(String path) async {
  final file = File(path);
  if (!file.existsSync()) {
    markTestSkipped('fixture $path not available (PDFs are not committed)');
    return null;
  }
  return parsePdf(await file.readAsBytes(), sourceName: path);
}
