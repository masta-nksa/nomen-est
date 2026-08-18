import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

/// Offers a waiting update, and says the one thing a teacher needs to know
/// before tapping it: the classes stay.
///
/// Deliberately not a dialog. An update is never urgent, and a box in the way
/// at the start of a lesson is worse than an old version.
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(updateAvailableProvider)) return const SizedBox.shrink();

    final theme = Theme.of(context);
    // Carries its own spacing: when there is nothing to offer it collapses to
    // nothing, and a padded empty box would leave a gap at the top of the
    // screen on every ordinary day.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              Icon(Icons.system_update_alt, color: theme.colorScheme.onPrimaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Neue Version bereit',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Klassen und Lernstand bleiben erhalten.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => ref.read(updateAvailableProvider.notifier).apply(),
                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onPrimaryContainer),
                child: const Text('Laden'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
