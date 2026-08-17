import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/widgets/mode_chip_bar.dart';
import 'package:nomen_est/widgets/presentation.dart';

void main() {
  group('when to suggest presentation mode', () {
    /// The platform override has to be cleared before the test body ends —
    /// Flutter asserts on it there, so `addTearDown` would be too late.
    Future<bool> suggestsAt(WidgetTester tester, Size size, TargetPlatform platform) async {
      late bool result;
      debugDefaultTargetPlatformOverride = platform;
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      try {
        await tester.pumpWidget(MaterialApp(
          home: Builder(builder: (context) {
            result = suggestsPresentation(context);
            return const SizedBox();
          }),
        ));
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
      return result;
    }

    testWidgets('an iPad held sideways, yes', (tester) async {
      expect(await suggestsAt(tester, const Size(1024, 768), TargetPlatform.iOS), isTrue);
    });

    testWidgets('an iPad upright, no', (tester) async {
      expect(await suggestsAt(tester, const Size(768, 1024), TargetPlatform.iOS), isFalse);
    });

    /// A phone turned sideways is not an audience.
    testWidgets('a phone sideways, no', (tester) async {
      expect(await suggestsAt(tester, const Size(844, 390), TargetPlatform.iOS), isFalse);
    });

    /// The concept asks for landscape alone to switch the mode on. A laptop
    /// window is always landscape, and its pixel dimensions are close enough to
    /// a tablet's that size cannot tell them apart — so the platform has to.
    testWidgets('a laptop window, no, even at tablet dimensions', (tester) async {
      expect(await suggestsAt(tester, const Size(1024, 768), TargetPlatform.macOS), isFalse);
      expect(await suggestsAt(tester, const Size(1440, 900), TargetPlatform.windows), isFalse);
    });
  });

  group('the name size carries to the back row', () {
    test('grows with the available height', () {
      final small = presentationNameSize(const BoxConstraints(maxHeight: 500, maxWidth: 800));
      final large = presentationNameSize(const BoxConstraints(maxHeight: 1080, maxWidth: 1920));
      expect(large, greaterThan(small));
    });

    test('never drops below the 48 the concept asks for', () {
      expect(presentationNameSize(const BoxConstraints(maxHeight: 200, maxWidth: 400)), 48.0);
    });

    test('stays sane on a very tall window', () {
      expect(presentationNameSize(const BoxConstraints(maxHeight: 4000, maxWidth: 4000)), 160.0);
    });
  });

  group('controls get out of the picture', () {
    Future<void> pumpShell(WidgetTester tester, {required bool presenting}) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PresentationScaffold(
            presenting: presenting,
            content: const Center(child: Text('Foto')),
            // Mirrors what the screens do: the builder decides what hides.
            controlsBuilder: (context, visible) => PresentationFade(
              hide: !visible,
              child: FilledButton(onPressed: () {}, child: const Text('Würfeln')),
            ),
            onExit: () {},
          ),
        ),
      ));
      await tester.pump();
    }

    double opacityOfControls(WidgetTester tester) {
      final finder = find.ancestor(
        of: find.text('Würfeln'),
        matching: find.byType(AnimatedOpacity),
      );
      return tester.widget<AnimatedOpacity>(finder.last).opacity;
    }

    testWidgets('outside presentation they simply stay', (tester) async {
      await pumpShell(tester, presenting: false);
      await tester.pump(const Duration(seconds: 10));

      expect(opacityOfControls(tester), 1);
    });

    testWidgets('presenting, they fade after a few seconds of quiet', (tester) async {
      await pumpShell(tester, presenting: true);
      expect(opacityOfControls(tester), 1, reason: 'visible to begin with');

      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 300));
      expect(opacityOfControls(tester), 0);
    });

    Future<void> waitForHiding(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('a tap anywhere brings them back', (tester) async {
      await pumpShell(tester, presenting: true);
      await waitForHiding(tester);
      expect(opacityOfControls(tester), 0);

      await tester.tap(find.text('Foto'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(opacityOfControls(tester), 1);
    });

    /// The way every video player behaves, which is where everyone has already
    /// learned it. With a mouse there is nothing to touch, so movement has to
    /// be the signal — otherwise the way out can only be found by clicking into
    /// empty space.
    testWidgets('moving the mouse brings them back', (tester) async {
      await pumpShell(tester, presenting: true);
      await waitForHiding(tester);
      expect(opacityOfControls(tester), 0);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Foto')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(opacityOfControls(tester), 1);
    });

    /// The reported bug: resizing the window left the way out hidden while the
    /// screen visibly changed under your hands.
    testWidgets('resizing the window brings them back', (tester) async {
      await pumpShell(tester, presenting: true);
      await waitForHiding(tester);
      expect(opacityOfControls(tester), 0);

      tester.view.physicalSize = const Size(1200, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(opacityOfControls(tester), 1);
    });

    testWidgets('leaving presentation shows them again at once', (tester) async {
      await pumpShell(tester, presenting: true);
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 300));
      expect(opacityOfControls(tester), 0);

      await pumpShell(tester, presenting: false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(opacityOfControls(tester), 1);
    });
  });

  /// Section 6.8: the pool counter is more interesting to a class than
  /// distracting, a row of toggles is neither.
  group('a dimmed chip bar keeps its numbers', () {
    Future<void> pumpBar(WidgetTester tester, {required bool dimmed}) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ModeChipBar(
            dimmed: dimmed,
            chips: const [
              ModeChip(
                label: 'Wiederholung',
                iconOn: Icons.repeat,
                iconOff: Icons.repeat_outlined,
                on: false,
              ),
              StatusChip(label: '17/24', progress: 0.7),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    double opacityOf(WidgetTester tester, String label) {
      final finder = find.ancestor(of: find.text(label), matching: find.byType(AnimatedOpacity));
      return tester.widget<AnimatedOpacity>(finder.first).opacity;
    }

    testWidgets('undimmed everything shows', (tester) async {
      await pumpBar(tester, dimmed: false);
      expect(opacityOf(tester, 'Wiederholung'), 1);
      expect(opacityOf(tester, '17/24'), 1);
    });

    testWidgets('dimmed the switch goes and the counter stays', (tester) async {
      await pumpBar(tester, dimmed: true);
      expect(opacityOf(tester, 'Wiederholung'), 0);
      expect(opacityOf(tester, '17/24'), 1);
    });
  });
}
