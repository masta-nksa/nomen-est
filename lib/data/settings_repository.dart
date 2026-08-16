import 'database.dart';

/// Key-value settings with a per-class override on top of a global default.
///
/// Teachers treat classes differently — in one the generator draws without
/// replacement, in another it is a warm-up game. So every key may carry a
/// class-scoped twin: reading prefers it and falls back to the global value,
/// writing picks which of the two it touches.
///
/// The alternative, a column per setting on the class, would need a migration
/// for every new switch. This needs none.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  static String scopedKey(String key, int classId) => '$key.class.$classId';

  /// The class-scoped value if there is one, otherwise the global one.
  Future<String?> read(String key, {int? classId}) async {
    if (classId != null) {
      final scoped = await _readRaw(scopedKey(key, classId));
      if (scoped != null) return scoped;
    }
    return _readRaw(key);
  }

  Future<void> write(String key, String value, {int? classId}) async {
    final target = classId == null ? key : scopedKey(key, classId);
    await _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: target, value: value),
        );
  }

  /// Drops an override so the global default applies again.
  Future<void> clear(String key, {int? classId}) async {
    final target = classId == null ? key : scopedKey(key, classId);
    await (_db.delete(_db.settings)..where((s) => s.key.equals(target))).go();
  }

  Future<String?> _readRaw(String key) async {
    final row = await (_db.select(_db.settings)..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }
}
