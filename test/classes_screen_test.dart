import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/data/database.dart';
import 'package:nomen_est/data/providers.dart';
import 'package:nomen_est/screens/classes_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// The class list is handed in as a finished stream: drift's live queries
  /// schedule timers that fake time keeps re-firing, and `pumpAndSettle` never
  /// returns. Empty, so no tile pulls in a second live query for its statistics.
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        classesProvider.overrideWith((ref) => Stream.value(const <SchoolClass>[])),
      ],
      child: const MaterialApp(home: ClassesScreen()),
    ));
    await tester.pumpAndSettle();
  }

  /// Whoever is already renaming and deleting classes is in the right frame of
  /// mind to add the next one; sending them back a screen for it is a detour.
  testWidgets('a new class can be added from here too', (tester) async {
    await pump(tester);

    expect(find.widgetWithText(FloatingActionButton, 'Neue Klasse'), findsOneWidget);

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Neue Klasse'));
    await tester.pumpAndSettle();

    expect(find.text('PDF auswählen'), findsOneWidget);
  });

  testWidgets('the ZIP import stays where it was', (tester) async {
    await pump(tester);
    expect(find.byIcon(Icons.unarchive), findsOneWidget);
  });
}
