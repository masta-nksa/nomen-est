import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/data/database.dart';
import 'package:nomen_est/data/providers.dart';
import 'package:nomen_est/screens/home_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  SchoolClass aClass(int id, String label) => SchoolClass(
        id: id,
        label: label,
        sourceFile: 'test.pdf',
        importedAt: DateTime(2026, 8, 14),
      );

  /// The class list is stubbed so a test can state it in one line, but the
  /// database behind the settings is real — remembering the chosen class is
  /// exactly the behaviour worth testing rather than faking.
  Future<void> pumpHome(WidgetTester tester, List<SchoolClass> classes) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        classesProvider.overrideWith((ref) => Stream.value(classes)),
        classStatsProvider.overrideWith(
          (ref, classId) => Stream.value(const ClassStats(total: 24, secure: 18)),
        ),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('without a class the import is the only thing offered', (tester) async {
    await pumpHome(tester, []);

    expect(find.text('Noch keine Klasse vorhanden.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Neue Klasse'), findsOneWidget);
    expect(find.text('Namen lernen'), findsNothing);
  });

  testWidgets('the class context and all four features are on the first screen', (tester) async {
    await pumpHome(tester, [aClass(1, 'INF-G1H-SMA')]);

    expect(find.text('INF-G1H-SMA'), findsOneWidget);
    expect(find.text('18 von 24 sicher'), findsOneWidget);
    for (final tile in ['Namen lernen', 'Zufall', 'Gruppen', 'Statistik']) {
      expect(find.text(tile), findsOneWidget, reason: '$tile is missing from the home screen');
    }
  });

  /// The statistics do not exist yet. That tile stays visible but inert, and
  /// says so — an empty tile that does nothing reads as a bug.
  testWidgets('features that are not built yet are labelled, not hidden', (tester) async {
    await pumpHome(tester, [aClass(1, 'INF-G1H-SMA')]);

    expect(find.text('später'), findsOneWidget);

    for (final built in ['Namen lernen', 'Zufall', 'Gruppen']) {
      final tile = tester.widget<InkWell>(
        find.ancestor(of: find.text(built), matching: find.byType(InkWell)).first,
      );
      expect(tile.onTap, isNotNull, reason: '$built is built and must be reachable');
    }
  });

  testWidgets('falls back to the newest import when nothing was chosen yet', (tester) async {
    await pumpHome(tester, [aClass(1, 'Neueste'), aClass(2, '2c Mathe')]);

    expect(find.text('Neueste'), findsOneWidget);
  });

  testWidgets('the last used class is preselected on the next start', (tester) async {
    await db.into(db.settings).insert(SettingsCompanion.insert(key: selectedClassKey, value: '2'));

    await pumpHome(tester, [aClass(1, 'Neueste'), aClass(2, '2c Mathe')]);

    expect(find.text('2c Mathe'), findsOneWidget, reason: 'not simply the newest import');
  });

  /// A class can be deleted while it is the selected one; the stored id then
  /// points at nothing and must not leave the screen without a class.
  testWidgets('a stored class that no longer exists falls back', (tester) async {
    await db.into(db.settings).insert(SettingsCompanion.insert(key: selectedClassKey, value: '99'));

    await pumpHome(tester, [aClass(1, 'Neueste')]);

    expect(find.text('Neueste'), findsOneWidget);
    expect(find.text('Klasse wählen'), findsNothing);
  });

  testWidgets('the privacy note is always visible', (tester) async {
    await pumpHome(tester, []);
    expect(find.textContaining('bleiben auf diesem Gerät'), findsOneWidget);
  });
}
