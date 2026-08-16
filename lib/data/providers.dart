import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final classesProvider = StreamProvider<List<SchoolClass>>((ref) {
  return ref.watch(databaseProvider).watchClasses();
});

final studentsProvider = StreamProvider.family<List<Student>, int>((ref, classId) {
  return ref.watch(databaseProvider).watchStudentsInClass(classId);
});

/// How many students in a class are considered "sicher" (Leitner box 4 or 5).
class ClassStats {
  const ClassStats({required this.total, required this.secure});

  final int total;
  final int secure;

  double get ratio => total == 0 ? 0 : secure / total;
}

/// Streams so the tile updates after a quiz round, not just after an import.
final classStatsProvider = StreamProvider.family<ClassStats, int>((ref, classId) {
  return ref.watch(databaseProvider).watchProgressForClass(classId).map(
        (rows) => ClassStats(
          total: rows.length,
          secure: rows.where((r) => r.box >= 4).length,
        ),
      );
});
