import '../groups/partition.dart';

/// Splits a class into learning chunks of roughly [size], in class order.
///
/// The point of learning in chunks is how often a face comes back: with 24
/// students and a round of 15 cards each person appears about half a time,
/// while in a chunk of five they appear three times in the same round.
///
/// The sizes come from the grouping's own distribution rather than from plain
/// slicing, so the last chunk is never a lonely one — 21 students in fives
/// becomes 6+5+5+5 and not 5+5+5+5+1. Order is kept, so a chunk stays the same
/// chunk between sessions and you know where you are.
List<List<T>> chunksOf<T>(List<T> items, int size) {
  if (items.isEmpty) return const [];
  if (size <= 0 || size >= items.length) return [List.of(items)];

  final plan = partition(students: items.length, spec: BySize(size));
  if (plan is! Partition) return [List.of(items)];

  final chunks = <List<T>>[];
  var at = 0;
  for (final chunkSize in plan.sizes) {
    chunks.add(items.sublist(at, at + chunkSize));
    at += chunkSize;
  }
  return chunks;
}
