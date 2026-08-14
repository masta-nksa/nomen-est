import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/data/database.dart';
import 'package:nomen_est/data/providers.dart';
import 'package:nomen_est/screens/home_screen.dart';

void main() {
  Future<void> pumpHome(WidgetTester tester, List<PhotoSet> sets) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [photoSetsProvider.overrideWith((ref) => Stream.value(sets))],
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pump();
  }

  PhotoSet aSet(String label) => PhotoSet(
        id: 1,
        label: label,
        sourceFile: 'test.pdf',
        importedAt: DateTime(2026, 8, 14),
      );

  testWidgets('Üben is disabled while no class exists', (tester) async {
    await pumpHome(tester, []);

    expect(find.text('Noch keine Klasse vorhanden.'), findsOneWidget);
    final practise = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Üben'));
    expect(practise.onPressed, isNull);
  });

  testWidgets('Üben becomes available once a class is imported', (tester) async {
    await pumpHome(tester, [aSet('INF-G1H-SMA')]);

    expect(find.text('1 Klasse auf diesem Gerät'), findsOneWidget);
    final practise = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Üben'));
    expect(practise.onPressed, isNotNull);
  });

  testWidgets('the privacy note is always visible', (tester) async {
    await pumpHome(tester, []);
    expect(find.textContaining('bleiben auf diesem Gerät'), findsOneWidget);
  });
}
