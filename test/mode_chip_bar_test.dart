import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/widgets/mode_chip_bar.dart';

void main() {
  Future<void> pumpBar(WidgetTester tester, List<BarChip> chips) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ModeChipBar(chips: chips)),
    ));
  }

  const mode = ModeChip(
    label: 'Wiederholung',
    iconOn: Icons.repeat,
    iconOff: Icons.repeat_outlined,
    on: false,
  );

  TuningChip tuning({required bool atDefault}) => TuningChip(
        label: atDefault ? 'Pause 3' : 'Pause aus',
        icon: Icons.hourglass_empty,
        atDefault: atDefault,
        value: atDefault ? '3' : 'aus',
      );

  test('an empty pool leaves the ring empty rather than full', () {
    expect(poolProgress(0, 24), 0);
    expect(poolProgress(24, 24), 1);
    expect(poolProgress(17, 24), closeTo(0.708, 0.001));
    expect(poolProgress(0, 0), 0, reason: 'a class without students must not divide by zero');
  });

  testWidgets('mode chips keep their label — there is no icon for "without replacement"',
      (tester) async {
    await pumpBar(tester, [mode]);
    expect(find.text('Wiederholung'), findsOneWidget);
  });

  testWidgets('a status chip shows its number', (tester) async {
    await pumpBar(tester, [const StatusChip(label: '17/24', progress: 0.7)]);
    expect(find.text('17/24'), findsOneWidget);
  });

  /// Section 6.3, the rule the whole bar hangs on: a non-default value is never
  /// invisible. Without it you get "the generator keeps picking the same
  /// people" three weeks after nudging a setting.
  group('a non-default value is never invisible', () {
    testWidgets('a tuning chip on its default stays behind the ⋯', (tester) async {
      await pumpBar(tester, [mode, tuning(atDefault: true)]);

      expect(find.text('Pause 3'), findsNothing);
      expect(find.text('⋯'), findsOneWidget);
    });

    testWidgets('a tuning chip off its default moves into the bar', (tester) async {
      await pumpBar(tester, [mode, tuning(atDefault: false)]);

      expect(find.text('Pause aus'), findsOneWidget);
      expect(find.text('⋯'), findsNothing, reason: 'nothing is left to hide');
    });

    testWidgets('the ⋯ stays for the ones still on their default', (tester) async {
      await pumpBar(tester, [tuning(atDefault: false), tuning(atDefault: true)]);

      expect(find.text('Pause aus'), findsOneWidget);
      expect(find.text('⋯'), findsOneWidget);
    });
  });

  testWidgets('the ⋯ opens the settings it hides', (tester) async {
    await pumpBar(tester, [tuning(atDefault: true)]);

    await tester.tap(find.text('⋯'));
    await tester.pumpAndSettle();

    expect(find.text('Pause 3'), findsOneWidget);
    expect(find.text('3'), findsOneWidget, reason: 'the current value belongs in the sheet');
  });

  testWidgets('a long press explains what a chip does', (tester) async {
    await pumpBar(tester, [
      const ModeChip(
        label: 'Wiederholung',
        iconOn: Icons.repeat,
        iconOff: Icons.repeat_outlined,
        on: false,
        explanation: 'Wer dran war, kommt erst nach einer neuen Runde wieder dran.',
      ),
    ]);

    await tester.longPress(find.text('Wiederholung'));
    await tester.pump();

    expect(find.textContaining('neuen Runde'), findsOneWidget);
  });

  testWidgets('the bar can be hidden without being removed', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ModeChipBar(visible: false, chips: [mode])),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Wiederholung'), findsOneWidget, reason: 'hidden, not removed');
    expect(tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity, 0);

    final ignoring = tester.widget<IgnorePointer>(
      find.descendant(of: find.byType(ModeChipBar), matching: find.byType(IgnorePointer)).first,
    );
    expect(ignoring.ignoring, isTrue, reason: 'an invisible bar must not be tappable');
  });
}
