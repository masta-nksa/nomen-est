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

/// Streams so the tile updates after a quiz round, not just after an import.
final setStatsProvider = StreamProvider.family<SetStats, int>((ref, setId) {
  return ref.watch(databaseProvider).watchProgressForSet(setId).map(
        (rows) => SetStats(
          total: rows.length,
          secure: rows.where((r) => r.box >= 4).length,
        ),
      );
});
