import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/data/database.dart';
import 'package:nomen_est/data/set_archive.dart';

void main() {
  PhotoSet aSet() => PhotoSet(
        id: 1,
        label: 'INF-G1H-SMA',
        sourceFile: 'g2026h.pdf',
        importedAt: DateTime(2026, 8, 14),
      );

  List<Person> people() => [
        Person(
          id: 1,
          setId: 1,
          displayName: 'Brändli Lyan',
          firstName: 'Lyan',
          lastName: 'Brändli',
          jpegBytes: Uint8List.fromList([1, 2, 3, 4]),
          orderIndex: 0,
        ),
        Person(
          id: 2,
          setId: 1,
          displayName: 'Ahumada Torres Gloria',
          firstName: 'Gloria',
          lastName: 'Ahumada Torres',
          jpegBytes: Uint8List.fromList([5, 6, 7, 8]),
          orderIndex: 1,
        ),
      ];

  test('a set survives an export/import round trip', () {
    final restored = importSet(exportSet(aSet(), people()));

    expect(restored.label, 'INF-G1H-SMA');
    expect(restored.sourceFile, 'g2026h.pdf');
    expect(restored.people, hasLength(2));
    expect(restored.people[0].displayName, 'Brändli Lyan');
    expect(restored.people[0].jpegBytes, [1, 2, 3, 4]);
    expect(restored.people[1].lastName, 'Ahumada Torres', reason: 'the reviewed split must be preserved');
    expect(restored.people[1].jpegBytes, [5, 6, 7, 8]);
  });

  test('an empty set round trips', () {
    final restored = importSet(exportSet(aSet(), []));
    expect(restored.people, isEmpty);
    expect(restored.label, 'INF-G1H-SMA');
  });

  test('a non-archive file is rejected with a readable message', () {
    expect(
      () => importSet(Uint8List.fromList(List.filled(64, 0))),
      throwsA(isA<Exception>()),
    );
  });
}
