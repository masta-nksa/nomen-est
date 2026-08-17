import 'dart:async';

import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';

/// How long the controls stay up before they get out of the way.
const _idleBeforeHiding = Duration(seconds: 3);

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
/// The controls fade after [_idleBeforeHiding] of stillness and come back on any
/// movement — the way a video player behaves, because that is where everyone
/// has already learned it.
///
/// The concept asks for the bottom edge specifically, so that a class cannot
/// summon a row of buttons by pointing at the photo. That guards against
/// something that does not happen: nobody touches a projection, and the tablet
/// is lying in front of the teacher. Requiring a click into empty space at the
/// bottom edge to find the way out is the worse trade.
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

class _PresentationScaffoldState extends State<PresentationScaffold>
    with WidgetsBindingObserver {
  Timer? _idle;
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.presenting) _restartIdle();
  }

  /// Resizing the window is somebody fiddling with the app, so the way out has
  /// to be within reach again. Without this the controls stay hidden while the
  /// screen visibly changes under your hands, which reads as them being gone
  /// for good.
  @override
  void didChangeMetrics() => _wake();

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
    WidgetsBinding.instance.removeObserver(this);
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

    // An ancestor listener sees every pointer event on the way down without
    // taking it away from the button underneath.
    return Listener(
      onPointerHover: (_) => _wake(),
      onPointerDown: (_) => _wake(),
      onPointerMove: (_) => _wake(),
      child: Stack(
      children: [
        Positioned.fill(child: widget.content),
        // Deliberately not faded here: the builder decides what goes and what
        // stays, because a pool counter may keep showing while the switches
        // next to it disappear.
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: widget.controlsBuilder(context, visible),
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
      ),
    );
  }
}
