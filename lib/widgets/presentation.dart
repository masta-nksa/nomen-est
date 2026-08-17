import 'dart:async';

import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';

/// How long the controls stay up before they get out of the way.
const _idleBeforeHiding = Duration(seconds: 3);

/// How tall the strip at the bottom is that brings the controls back.
const _revealStripHeight = 72.0;

/// Whether this looks like a tablet held sideways at a beamer.
///
/// The concept wants landscape alone to switch the mode on, but a laptop window
/// is always landscape and would then sit permanently in beamer mode. Pixel
/// dimensions cannot separate the two either: an iPad in landscape is 1024×768
/// and a small laptop window is not far off.
///
/// So the platform decides whether it is a touch device at all, and the size
/// only rules out a phone — a phone turned sideways is not an audience.
bool suggestsPresentation(BuildContext context) {
  final touch = defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;
  if (!touch) return false;

  final size = MediaQuery.sizeOf(context);
  return size.width > size.height && size.shortestSide >= _tabletShortSide;
}

/// Below this a landscape screen is a phone, not something a room looks at.
/// An iPad is 768 on its short side, an iPhone around 400.
const _tabletShortSide = 500.0;

/// Font size for a name that has to carry to the back row.
///
/// Tied to the available height rather than fixed: a beamer, a tablet and a
/// laptop window differ by a factor of three, and 48 logical pixels that look
/// generous on a phone are unreadable from eight metres.
double presentationNameSize(BoxConstraints constraints) =>
    (constraints.maxHeight * 0.11).clamp(48.0, 160.0);

/// Fades something out of the picture and stops it responding.
class PresentationFade extends StatelessWidget {
  const PresentationFade({super.key, required this.hide, required this.child});

  final bool hide;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: hide ? 0 : 1,
      duration: const Duration(milliseconds: 250),
      child: IgnorePointer(ignoring: hide, child: child),
    );
  }
}

/// Shows content to a room: no app bar, and controls that take themselves out
/// of the picture.
///
/// The controls fade after [_idleBeforeHiding] and come back when the bottom
/// edge is touched. Only the bottom edge: the class watching a photo should not
/// be able to summon a row of buttons by pointing at the middle of it, and the
/// teacher's hand is at the bottom anyway.
class PresentationScaffold extends StatefulWidget {
  const PresentationScaffold({
    super.key,
    required this.presenting,
    required this.content,
    required this.controlsBuilder,
    required this.onExit,
  });

  final bool presenting;
  final Widget content;

  /// Built with whether the controls are currently showing, so a chip bar can
  /// keep its status chips visible while the switches disappear.
  final Widget Function(BuildContext context, bool visible) controlsBuilder;

  final VoidCallback onExit;

  @override
  State<PresentationScaffold> createState() => _PresentationScaffoldState();
}

class _PresentationScaffoldState extends State<PresentationScaffold> {
  Timer? _idle;
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    if (widget.presenting) _restartIdle();
  }

  @override
  void didUpdateWidget(PresentationScaffold old) {
    super.didUpdateWidget(old);
    if (widget.presenting != old.presenting) {
      setState(() => _controlsVisible = true);
      if (widget.presenting) {
        _restartIdle();
      } else {
        _idle?.cancel();
      }
    }
  }

  @override
  void dispose() {
    _idle?.cancel();
    super.dispose();
  }

  void _restartIdle() {
    _idle?.cancel();
    _idle = Timer(_idleBeforeHiding, () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _wake() {
    if (!widget.presenting) return;
    if (!_controlsVisible) setState(() => _controlsVisible = true);
    _restartIdle();
  }

  @override
  Widget build(BuildContext context) {
    final visible = !widget.presenting || _controlsVisible;

    return Stack(
      children: [
        Positioned.fill(child: widget.content),
        if (widget.presenting)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _revealStripHeight,
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => _wake(),
              // Never swallows a tap: the controls sit above this and get the
              // pointer first whenever they are showing.
              child: const SizedBox.expand(),
            ),
          ),
        // Deliberately not faded here: the builder decides what goes and what
        // stays, because a pool counter may keep showing while the switches
        // next to it disappear.
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Listener(
            onPointerDown: (_) => _wake(),
            child: widget.controlsBuilder(context, visible),
          ),
        ),
        if (widget.presenting)
          Positioned(
            top: 8,
            right: 8,
            child: AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !visible,
                child: IconButton(
                  icon: const Icon(Icons.fullscreen_exit),
                  tooltip: 'Präsentation beenden',
                  onPressed: widget.onExit,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
