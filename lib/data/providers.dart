import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final photoSetsProvider = StreamProvider<List<PhotoSet>>((ref) {
  return ref.watch(databaseProvider).watchPhotoSets();
});

final personsProvider = StreamProvider.family<List<Person>, int>((ref, setId) {
  return ref.watch(databaseProvider).watchPersonsInSet(setId);
});

/// How many people in a set are considered "sicher" (Leitner box 4 or 5).
class SetStats {
  const SetStats({required this.total, required this.secure});

  final int total;
  final int secure;

  double get ratio => total == 0 ? 0 : secure / total;
}

final setStatsProvider = FutureProvider.family<SetStats, int>((ref, setId) async {
  final db = ref.watch(databaseProvider);
  // Re-read whenever the set's people change, so the tile stays live.
  await ref.watch(personsProvider(setId).future);
  final rows = await db.progressForSet(setId);
  return SetStats(
    total: rows.length,
    secure: rows.where((r) => r.box >= 4).length,
  );
});
