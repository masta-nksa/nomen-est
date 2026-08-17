import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
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

  /// Some classes hand in a photo that is not square. A row band is as tall as
  /// its tallest photo, so every neighbour used to get a white bar underneath.
  group('photos are cropped to themselves, not to the tallest in their row', () {
    Future<void> expectNoWhiteBar(String path) async {
      final students = await _parseFixture(path);
      if (students == null) return;

      for (final student in students) {
        final photo = img.decodeJpg(student.jpegBytes)!;
        final bottom = photo.height - 1;
        var white = 0;
        for (var x = 0; x < photo.width; x++) {
          final pixel = photo.getPixel(x, bottom);
          if ((pixel.r + pixel.g + pixel.b) / 3 >= 245) white++;
        }
        expect(
          white,
          lessThan(photo.width),
          reason: '${student.displayName} in $path ends in a blank row',
        );
      }
    }

    test('the set with mixed photo sizes', () => expectNoWhiteBar('pdfs/g2025a.pdf'));
    test('the sets where they all match', () async {
      await expectNoWhiteBar('pdfs/g2026h.pdf');
      await expectNoWhiteBar('pdfs/f2026A.pdf');
    });

    test('a taller photo keeps its height', () async {
      final students = await _parseFixture('pdfs/g2025a.pdf');
      if (students == null) return;

      final ratios = [
        for (final student in students)
          img.decodeJpg(student.jpegBytes)!.width / img.decodeJpg(student.jpegBytes)!.height,
      ];
      expect(ratios.any((r) => r < 0.9), isTrue, reason: 'the portrait-format photo must stay tall');
      expect(ratios.where((r) => (r - 1).abs() < 0.05).length, greaterThan(students.length ~/ 2),
          reason: 'and the square ones must stay square');
    });

    test('names still land on the right photo when a row is mixed', () async {
      final students = await _parseFixture('pdfs/g2025a.pdf');
      if (students == null) return;

      expect(students.every((s) => s.displayName.trim().isNotEmpty), isTrue,
          reason: 'a trimmed photo must not lose the name that hangs off its row');
    });
  });

  /// Coordinates measured from the reference PDFs: the photo's bottom edge sits
  /// at 92.4 pt, the name line at 60.6, a wrapped second line at 52.0, and the
  /// page footer's date at 41.0. Those 11 points between a wrapped name and the
  /// date are what the old distance rule could not tell apart.
  group('nameLineCount', () {
    test('a one-line name does not swallow the footer date', () {
      expect(nameLineCount([60.6, 41.0], ['Wernli Carina', '11. August 2026']), 1);
    });

    test('a wrapped name keeps both its lines', () {
      expect(
        nameLineCount([60.6, 52.0], ['Mühlhäuser Niklas', 'David']),
        2,
      );
    });

    test('a wrapped name at the page bottom still drops the date', () {
      expect(
        nameLineCount([60.6, 52.0, 41.0], ['Mühlhäuser Niklas', 'David', '11. August 2026']),
        2,
        reason: 'the date is only 11 pt below the second line — closer than the gap rule sees',
      );
    });

    test('far-away text is dropped by distance alone', () {
      expect(nameLineCount([605.4, 41.0], ['Zumsteg Roxy', '12. August 2026']), 1);
    });

    test('a third line is never part of a name', () {
      expect(nameLineCount([60.6, 52.0, 43.4], ['Aaa', 'Bbb', 'Ccc']), 2);
    });

    test('a photo with nothing but the footer under it gets no name', () {
      expect(nameLineCount([41.0], ['11. August 2026']), 0);
    });

    test('no lines at all', () {
      expect(nameLineCount([], []), 0);
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
