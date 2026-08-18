import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../draw/draw_settings.dart';
import '../groups/group_settings.dart';
import 'database.dart';
import 'selection_repository.dart';
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

/// Light, dark, or whatever the device says — remembered across restarts.
///
/// Global rather than per class: it describes the room the app is used in, not
/// the class being taught. A beamer in a bright room wants the light theme
/// whichever class is on screen.
class ThemeModeController extends AsyncNotifier<ThemeMode> {
  static const key = 'app.themeMode';

  @override
  Future<ThemeMode> build() async {
    final stored = await ref.watch(settingsProvider).read(key);
    return ThemeMode.values.where((m) => m.name == stored).firstOrNull ?? ThemeMode.system;
  }

  Future<void> select(ThemeMode mode) async {
    // Painted first, written after: the switch is the kind of thing you flick
    // back and forth to compare, and waiting on a disk write to see the result
    // would make it feel broken.
    state = AsyncData(mode);
    await ref.read(settingsProvider).write(key, mode.name);
  }
}

final themeModeProvider = AsyncNotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

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

final selectionRepositoryProvider = Provider<SelectionRepository>((ref) {
  return SelectionRepository(ref.watch(databaseProvider));
});

/// Recomputed rather than cached — the pool is derived from the log, so the
/// only way it can go stale is if someone forgets to invalidate this after a
/// draw, a reset or an attendance change.
///
/// Reads the repetition setting because with repetition on nobody is consumed,
/// and a counter that ticked down anyway would be describing a rule that is not
/// in force.
final poolProvider = FutureProvider.family<PoolState, int>((ref, classId) async {
  final settings = await ref.watch(drawSettingsProvider(classId).future);
  return ref.watch(selectionRepositoryProvider).pool(classId, replacement: settings.replacement);
});

/// Who is marked absent today. Presence is the default, so this is usually
/// empty and never has to be filled in on a normal day.
final absencesProvider = FutureProvider.family<Set<int>, int>((ref, classId) {
  return ref.watch(selectionRepositoryProvider).absencesOn(classId, DateTime.now());
});

/// Chip states, per class with a global fallback. Teachers treat classes
/// differently — in one the generator draws without replacement, in another it
/// is a warm-up game.
class DrawSettingsController extends FamilyAsyncNotifier<DrawSettings, int> {
  static const replacementKey = 'random.replacement';
  static const cooldownKey = 'random.cooldown';

  @override
  Future<DrawSettings> build(int classId) async {
    final settings = ref.watch(settingsProvider);
    const defaults = DrawSettings();
    return DrawSettings(
      replacement: await settings.read(replacementKey, classId: classId) == 'true',
      cooldown: int.tryParse(await settings.read(cooldownKey, classId: classId) ?? '') ?? defaults.cooldown,
    );
  }

  Future<void> save(DrawSettings next) async {
    final settings = ref.read(settingsProvider);
    final classId = arg;
    await settings.write(replacementKey, '${next.replacement}', classId: classId);
    await settings.write(cooldownKey, '${next.cooldown}', classId: classId);
    state = AsyncData(next);
  }
}

final drawSettingsProvider =
    AsyncNotifierProvider.family<DrawSettingsController, DrawSettings, int>(DrawSettingsController.new);

/// Everyone who is in class today — the grouping works on all of them, not on
/// the draw pool, which is a different question entirely.
final presentStudentsProvider = FutureProvider.family<List<Student>, int>((ref, classId) async {
  final students = await ref.watch(databaseProvider).studentsInClass(classId);
  final absent = await ref.watch(absencesProvider(classId).future);
  return [
    for (final student in students)
      if (!absent.contains(student.id)) student,
  ];
});

class GroupSettingsController extends FamilyAsyncNotifier<GroupSettings, int> {
  static const modeKey = 'groups.mode';
  static const groupsKey = 'groups.count';
  static const sizeKey = 'groups.size';
  static const minKey = 'groups.min';
  static const maxKey = 'groups.max';
  static const evenKey = 'groups.even';

  @override
  Future<GroupSettings> build(int classId) async {
    final settings = ref.watch(settingsProvider);
    const defaults = GroupSettings();

    Future<int> number(String key, int fallback) async =>
        int.tryParse(await settings.read(key, classId: classId) ?? '') ?? fallback;

    final mode = await settings.read(modeKey, classId: classId);
    return GroupSettings(
      mode: GroupMode.values.where((m) => m.name == mode).firstOrNull ?? defaults.mode,
      groups: await number(groupsKey, defaults.groups),
      size: await number(sizeKey, defaults.size),
      min: await number(minKey, defaults.min),
      max: await number(maxKey, defaults.max),
      even: await settings.read(evenKey, classId: classId) != 'false',
    );
  }

  Future<void> save(GroupSettings next) async {
    final settings = ref.read(settingsProvider);
    final classId = arg;
    await settings.write(modeKey, next.mode.name, classId: classId);
    await settings.write(groupsKey, '${next.groups}', classId: classId);
    await settings.write(sizeKey, '${next.size}', classId: classId);
    await settings.write(minKey, '${next.min}', classId: classId);
    await settings.write(maxKey, '${next.max}', classId: classId);
    await settings.write(evenKey, '${next.even}', classId: classId);
    state = AsyncData(next);
  }
}

final groupSettingsProvider =
    AsyncNotifierProvider.family<GroupSettingsController, GroupSettings, int>(GroupSettingsController.new);
