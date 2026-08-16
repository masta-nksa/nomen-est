import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/data/class_archive.dart';
import 'package:nomen_est/data/database.dart';

void main() {
  SchoolClass aClass() => SchoolClass(
        id: 1,
        label: 'INF-G1H-SMA',
        sourceFile: 'g2026h.pdf',
        importedAt: DateTime(2026, 8, 14),
      );

  List<Student> students() => [
        Student(
          id: 1,
          classId: 1,
          displayName: 'Brändli Lyan',
          firstName: 'Lyan',
          lastName: 'Brändli',
          jpegBytes: Uint8List.fromList([1, 2, 3, 4]),
          orderIndex: 0,
          active: true,
        ),
        Student(
          id: 2,
          classId: 1,
          displayName: 'Ahumada Torres Gloria',
          firstName: 'Gloria',
          lastName: 'Ahumada Torres',
          jpegBytes: Uint8List.fromList([5, 6, 7, 8]),
          orderIndex: 1,
          active: true,
        ),
      ];

  test('a class survives an export/import round trip', () {
    final restored = importClass(exportClass(aClass(), students()));

    expect(restored.label, 'INF-G1H-SMA');
    expect(restored.sourceFile, 'g2026h.pdf');
    expect(restored.students, hasLength(2));
    expect(restored.students[0].displayName, 'Brändli Lyan');
    expect(restored.students[0].jpegBytes, [1, 2, 3, 4]);
    expect(restored.students[1].lastName, 'Ahumada Torres', reason: 'the reviewed split must be preserved');
    expect(restored.students[1].jpegBytes, [5, 6, 7, 8]);
  });

  test('an empty class round trips', () {
    final restored = importClass(exportClass(aClass(), []));
    expect(restored.students, isEmpty);
    expect(restored.label, 'INF-G1H-SMA');
  });

  test('a non-archive file is rejected with a readable message', () {
    expect(
      () => importClass(Uint8List.fromList(List.filled(64, 0))),
      throwsA(isA<Exception>()),
    );
  });
}
