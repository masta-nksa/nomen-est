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

  group('upToChunk', () {
    test('step 0 is the first chunk alone', () {
      expect(upToChunk(chunksOf(classOf(20), 5), 0), [1, 2, 3, 4, 5]);
    });

    test('a later step carries the earlier ones along', () {
      expect(upToChunk(chunksOf(classOf(20), 5), 1), classOf(10));
      expect(upToChunk(chunksOf(classOf(20), 5), 3), classOf(20));
    });

    test('a step past the end is the whole class, not a crash', () {
      expect(upToChunk(chunksOf(classOf(20), 5), 99), classOf(20));
    });

    test('no chunks, nobody', () {
      expect(upToChunk(<List<int>>[], 0), isEmpty);
    });
  });

  /// Box 4 of five means three correct answers.
  group('automaticScope', () {
    List<int> scopeOf(Map<int, int> boxes, int classSize) => automaticScope(
          classOf(classSize),
          boxOf: (s) => boxes[s] ?? 1,
        );

    test('starts as a handful when nothing is learned yet', () {
      expect(scopeOf({}, 26), [1, 2, 3, 4, 5]);
    });

    test('admits one more as soon as one sits', () {
      expect(scopeOf({1: 4}, 26), [1, 2, 3, 4, 5, 6]);
      expect(scopeOf({1: 4, 2: 5}, 26), [1, 2, 3, 4, 5, 6, 7]);
    });

    /// The learned stay in: they need refreshing, and they are exactly what
    /// makes the newcomers hard to tell apart.
    test('keeps the learned ones in play', () {
      expect(scopeOf({1: 5, 2: 5, 3: 5}, 26), containsAll([1, 2, 3]));
    });

    test('a box below the threshold does not count as learned', () {
      expect(scopeOf({1: 3}, 26), [1, 2, 3, 4, 5], reason: 'box 3 is two right, not three');
    });

    test('ends at the whole class once everyone sits', () {
      final boxes = {for (var i = 1; i <= 12; i++) i: 4};
      expect(scopeOf(boxes, 12), classOf(12));
    });

    test('a class smaller than the handful is all of it', () {
      expect(scopeOf({}, 3), classOf(3));
    });

    test('an empty class stays empty', () {
      expect(automaticScope(<int>[], boxOf: (s) => 1), isEmpty);
    });
  });

  test('a nonsensical size is treated as off', () {
    expect(chunksOf(classOf(9), 0), [classOf(9)]);
    expect(chunksOf(classOf(9), -3), [classOf(9)]);
  });
}
