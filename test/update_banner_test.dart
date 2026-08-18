import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/data/providers.dart';
import 'package:nomen_est/widgets/update_banner.dart';

/// Stands in for the service worker, which no widget test has.
class _FakeUpdate extends UpdateNotifier {
  _FakeUpdate({required this.ready});

  final bool ready;
  var applied = 0;

  @override
  bool build() => ready;

  @override
  void apply() => applied++;
}

void main() {
  Future<_FakeUpdate> pump(WidgetTester tester, {required bool ready}) async {
    final fake = _FakeUpdate(ready: ready);
    await tester.pumpWidget(ProviderScope(
      overrides: [updateAvailableProvider.overrideWith(() => fake)],
      child: const MaterialApp(home: Scaffold(body: UpdateBanner())),
    ));
    await tester.pumpAndSettle();
    return fake;
  }

  testWidgets('stays out of the way when there is nothing to update', (tester) async {
    await pump(tester, ready: false);

    expect(find.text('Neue Version bereit'), findsNothing);
    // Not merely invisible — it must take up no room, or every ordinary day
    // would start with a gap at the top of the screen.
    expect(tester.getSize(find.byType(UpdateBanner)), Size.zero);
  });

  testWidgets('offers the update and promises the data stays', (tester) async {
    await pump(tester, ready: true);

    expect(find.text('Neue Version bereit'), findsOneWidget);
    expect(find.textContaining('bleiben erhalten'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Laden'), findsOneWidget);
  });

  testWidgets('nothing happens until it is asked for', (tester) async {
    final fake = await pump(tester, ready: true);

    expect(fake.applied, 0, reason: 'ein Update darf sich nie von selbst einspielen');

    await tester.tap(find.text('Laden'));
    await tester.pumpAndSettle();

    expect(fake.applied, 1);
  });

  testWidgets('appears without a restart when the update arrives late', (tester) async {
    // The worker usually finishes downloading while the app is already open.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: UpdateBanner())),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Neue Version bereit'), findsNothing);

    container.read(updateAvailableProvider.notifier).state = true;
    await tester.pumpAndSettle();

    expect(find.text('Neue Version bereit'), findsOneWidget);
  });
}
