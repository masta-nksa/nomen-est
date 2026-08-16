import 'dart:math';

import 'package:flutter/material.dart';

/// One entry in a [ModeChipBar].
sealed class BarChip {
  const BarChip({required this.label, this.onTap, this.explanation});

  /// One or two words. Mode chips keep theirs even though it costs width:
  /// there is no drawable symbol for "draw without replacement", and a chip you
  /// have to tap to find out what it does is worse than a wide one.
  final String label;

  final VoidCallback? onTap;

  /// Shown on a long press. The place to explain what a chip actually does.
  final String? explanation;
}

/// Decides *what* the function does. Always visible, filled when on.
class ModeChip extends BarChip {
  const ModeChip({
    required super.label,
    required this.iconOn,
    required this.iconOff,
    required this.on,
    super.onTap,
    super.explanation,
  });

  final IconData iconOn;
  final IconData iconOff;
  final bool on;
}

/// Shows a number rather than a state. Tapping jumps to the detail behind it
/// instead of switching anything.
class StatusChip extends BarChip {
  const StatusChip({
    required super.label,
    this.icon,
    this.progress,
    super.onTap,
    super.explanation,
  });

  final IconData? icon;

  /// 0…1. Draws an emptying ring instead of a glyph — the one element in the
  /// bar that needs no label to be understood.
  final double? progress;
}

/// Fine adjustment. Lives behind the `⋯` chip while it is on its default and
/// moves into the bar as soon as it is not.
class TuningChip extends BarChip {
  const TuningChip({
    required super.label,
    required this.icon,
    required this.atDefault,
    required this.value,
    super.onTap,
    super.explanation,
  });

  final IconData icon;

  /// The rule that makes the bar a diagnosis and not just a control: a
  /// non-default value is never invisible. Without it you get "the generator
  /// keeps picking the same people" three weeks after nudging a slider.
  final bool atDefault;

  /// The current setting in a word or two, for the `⋯` sheet.
  final String value;
}

/// A horizontally scrollable row of chips, in the same place on every screen:
/// directly above the main action button, because that is where the thumb is
/// and because the class context already sits at the top.
class ModeChipBar extends StatelessWidget {
  const ModeChipBar({super.key, required this.chips, this.visible = true});

  final List<BarChip> chips;

  /// Hidden in presentation mode after a few seconds of inactivity — at the
  /// beamer the class sees the bar too.
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final hidden = [
      for (final chip in chips)
        if (chip is TuningChip && chip.atDefault) chip,
    ];
    final shown = [
      for (final chip in chips)
        if (chip is! TuningChip || !chip.atDefault) chip,
    ];

    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !visible,
        child: SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final chip in shown) _Chip(chip: chip),
              if (hidden.isNotEmpty) _MoreChip(chips: hidden),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.chip});

  final BarChip chip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filled = switch (chip) {
      ModeChip(:final on) => on,
      TuningChip() => true,
      StatusChip() => false,
    };
    final foreground = filled ? scheme.onSecondaryContainer : scheme.onSurfaceVariant;

    final leading = switch (chip) {
      ModeChip(:final on, :final iconOn, :final iconOff) => Icon(on ? iconOn : iconOff, size: 18, color: foreground),
      StatusChip(:final progress?) => _Ring(value: progress, color: foreground),
      StatusChip(:final icon?) => Icon(icon, size: 18, color: foreground),
      StatusChip() => null,
      TuningChip(:final icon) => Icon(icon, size: 18, color: foreground),
    };

    // 28 high to stay quiet, 44 to hit: understated means soft-spoken, not hard
    // to tap.
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: Material(
          color: filled ? scheme.secondaryContainer : Colors.transparent,
          shape: StadiumBorder(
            side: filled ? BorderSide.none : BorderSide(color: scheme.outlineVariant),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: chip.onTap,
            onLongPress: chip.explanation == null ? null : () => _explain(context),
            child: Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[leading, const SizedBox(width: 6)],
                  Text(
                    chip.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: foreground),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _explain(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(chip.explanation!), duration: const Duration(seconds: 4)),
    );
  }
}

/// A ring that empties. Needs no label, which is why the pool chip has one
/// instead of a glyph.
class _Ring extends StatelessWidget {
  const _Ring({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        value: value.clamp(0, 1),
        strokeWidth: 2.5,
        color: color,
        backgroundColor: color.withValues(alpha: 0.2),
      ),
    );
  }
}

class _MoreChip extends StatelessWidget {
  const _MoreChip({required this.chips});

  final List<TuningChip> chips;

  @override
  Widget build(BuildContext context) {
    return _Chip(
      chip: StatusChip(
        label: '⋯',
        onTap: () => showModalBottomSheet<void>(
          context: context,
          builder: (context) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final chip in chips)
                  ListTile(
                    leading: Icon(chip.icon),
                    title: Text(chip.label),
                    trailing: Text(chip.value),
                    subtitle: chip.explanation == null ? null : Text(chip.explanation!),
                    onTap: () {
                      Navigator.of(context).pop();
                      chip.onTap?.call();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounds a fraction for a status chip without ever showing a full ring for a
/// pool that still has someone in it.
double poolProgress(int available, int total) => total == 0 ? 0 : max(0, available / total);
