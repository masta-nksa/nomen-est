import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';
import 'settings_repository.dart';

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

final settingsProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseProvider));
});

/// Which class the app is currently working on — remembered across restarts.
const selectedClassKey = 'app.selectedClass';

/// The class every feature operates on.
///
/// Global rather than picked per feature: learning, drawing, grouping and the
/// statistics all need one, and choosing it four times over would be four
/// chances to be looking at a different class than you think.
///
/// Rebuilds when the class list changes, so deleting the selected class falls
/// back to the most recent import rather than leaving a dangling id.
class SelectedClass extends AsyncNotifier<SchoolClass?> {
  @override
  Future<SchoolClass?> build() async {
    final classes = await ref.watch(classesProvider.future);
    if (classes.isEmpty) return null;

    final stored = int.tryParse(await ref.read(settingsProvider).read(selectedClassKey) ?? '');
    for (final schoolClass in classes) {
      if (schoolClass.id == stored) return schoolClass;
    }
    return classes.first;
  }

  Future<void> select(SchoolClass schoolClass) async {
    await ref.read(settingsProvider).write(selectedClassKey, '${schoolClass.id}');
    state = AsyncData(schoolClass);
  }
}

final selectedClassProvider =
    AsyncNotifierProvider<SelectedClass, SchoolClass?>(SelectedClass.new);
