import 'package:nomen_est/data/database.dart';

/// The indices drift actually created, so both the fresh-install path and the
/// migration path can be checked against the same expectation.
Future<List<String>> indexNames(AppDatabase db) async {
  final rows = await db
      .customSelect("SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%' ORDER BY name")
      .get();
  return [for (final row in rows) row.read<String>('name')];
}
