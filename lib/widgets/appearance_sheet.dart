import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

/// The light/dark switch, as a sheet rather than a settings screen.
///
/// A sheet covers only the lower part of the screen, so the app repaints in the
/// new theme in full view while you tap — which is the only way to judge the
/// choice. A separate screen would hide the very thing being decided.
Future<void> showAppearanceSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => const SafeArea(child: _AppearanceSheet()),
  );
}

class _AppearanceSheet extends ConsumerWidget {
  const _AppearanceSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mode = ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Darstellung', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Gilt für die ganze App und bleibt gespeichert.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto_outlined),
                label: Text('System'),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_outlined),
                label: Text('Hell'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_outlined),
                label: Text('Dunkel'),
              ),
            ],
            selected: {mode},
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              ref.read(themeModeProvider.notifier).select(selection.first);
            },
          ),
          const SizedBox(height: 16),
          _Hint(mode: mode),
        ],
      ),
    );
  }
}

/// Says what the current choice actually does. "System" is the one people
/// misread — it is not a third look but a deferral to the device.
class _Hint extends StatelessWidget {
  const _Hint({required this.mode});

  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = switch (mode) {
      ThemeMode.system => 'Folgt der Einstellung des Geräts und wechselt mit ihr.',
      ThemeMode.light => 'Immer hell — auch nachts und unabhängig vom Gerät.',
      ThemeMode.dark => 'Immer dunkel. Am Beamer in einem hellen Raum ist Hell besser lesbar.',
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
