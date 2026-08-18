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

/// Everybody up to and including chunk [step].
///
/// Step 0 is the first chunk alone, step 2 is the first three together.
List<T> upToChunk<T>(List<List<T>> chunks, int step) {
  if (chunks.isEmpty) return const [];
  final last = step.clamp(0, chunks.length - 1);
  return [for (var i = 0; i <= last; i++) ...chunks[i]];
}

/// A student counts as learned from this Leitner box up — two correct answers
/// in a row. Below it they are still being learned.
const learnedFromBox = 3;

/// How many not-yet-learned students the automatic scope keeps in play.
const activeAtOnce = 5;

/// Who to practise when the app decides the scope itself.
///
/// Everyone already learned stays in — they need refreshing, and they are
/// precisely what makes the new ones hard to tell apart — plus the next
/// [activeAtOnce] who are not. So the set starts as a handful and grows by one
/// each time somebody sits, which keeps the round just past what is already
/// comfortable.
///
/// The Leitner weighting does the rest: a box-1 face is worth 25 times a box-5
/// one in the draw, so the newcomers dominate the round even once the learned
/// half of the class is along for the ride.
List<T> automaticScope<T>(
  List<T> students, {
  required int Function(T) boxOf,
  int learnedFrom = learnedFromBox,
  int active = activeAtOnce,
}) {
  final chosen = <T>[];
  var admitted = 0;
  for (final student in students) {
    if (boxOf(student) >= learnedFrom) {
      chosen.add(student);
    } else if (admitted < active) {
      chosen.add(student);
      admitted++;
    }
  }
  return chosen;
}
