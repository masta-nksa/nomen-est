import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/data/database.dart';
import 'package:nomen_est/data/providers.dart';
import 'package:nomen_est/widgets/appearance_sheet.dart';

/// The database behind the setting is real: that the choice survives a restart
/// is the whole point of storing it, and a faked repository would not say so.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<ProviderContainer> pumpSheet(WidgetTester tester) async {
    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showAppearanceSheet(context),
              child: const Text('oeffnen'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('oeffnen'));
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('the sheet offers all three choices and starts on the device setting',
      (tester) async {
    final container = await pumpSheet(tester);

    expect(find.text('System'), findsOneWidget);
    expect(find.text('Hell'), findsOneWidget);
    expect(find.text('Dunkel'), findsOneWidget);
    expect(container.read(themeModeProvider).valueOrNull, ThemeMode.system);
  });

  testWidgets('picking dark switches immediately', (tester) async {
    final container = await pumpSheet(tester);

    await tester.tap(find.text('Dunkel'));
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider).valueOrNull, ThemeMode.dark);
  });

  testWidgets('the choice survives the next start', (tester) async {
    final container = await pumpSheet(tester);
    await tester.tap(find.text('Hell'));
    await tester.pumpAndSettle();

    // A fresh container is what a restart looks like: same database, nothing
    // else carried over.
    final restarted = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(restarted.dispose);

    expect(await restarted.read(themeModeProvider.future), ThemeMode.light);
    expect(container.read(themeModeProvider).valueOrNull, ThemeMode.light);
  });

  testWidgets('the hint follows the choice', (tester) async {
    await pumpSheet(tester);

    expect(find.textContaining('Folgt der Einstellung des Geräts'), findsOneWidget);

    await tester.tap(find.text('Dunkel'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Immer dunkel'), findsOneWidget);
  });
}
