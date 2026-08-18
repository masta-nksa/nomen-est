import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/quiz/chunks.dart';

void main() {
  List<int> classOf(int n) => [for (var i = 1; i <= n; i++) i];

  test('an even class splits evenly', () {
    expect(chunksOf(classOf(20), 5).map((c) => c.length), [5, 5, 5, 5]);
  });

  /// The reason this borrows the grouping's distribution instead of slicing:
  /// plain slices would leave one student alone in a chunk of their own.
  test('an uneven class never leaves a chunk of one', () {
    expect(chunksOf(classOf(21), 5).map((c) => c.length), [6, 5, 5, 5]);
    expect(chunksOf(classOf(23), 5).map((c) => c.length), [6, 6, 6, 5]);
  });

  test('everyone appears exactly once, in class order', () {
    for (var n = 1; n <= 40; n++) {
      final chunks = chunksOf(classOf(n), 5);
      expect(chunks.expand((c) => c).toList(), classOf(n), reason: 'n=$n');
    }
  });

  test('a class smaller than the chunk stays one chunk', () {
    expect(chunksOf(classOf(3), 5), [classOf(3)]);
  });

  test('an empty class has no chunks', () {
    expect(chunksOf(<int>[], 5), isEmpty);
  });

  test('a nonsensical size is treated as off', () {
    expect(chunksOf(classOf(9), 0), [classOf(9)]);
    expect(chunksOf(classOf(9), -3), [classOf(9)]);
  });
}
