import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/theme/app_theme.dart';

/// The house colour is bright enough that some pairings are unreadable —
/// white on the orange reaches only 2.4:1. The themes work around that, and
/// these tests hold them to it, so that changing the orange in one place
/// cannot quietly produce a screen nobody can read.
double _channel(double c) => c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

double contrast(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  /// WCAG AA for body text.
  const readable = 4.5;

  for (final theme in {'hell': AppTheme.light, 'dunkel': AppTheme.dark}.entries) {
    final scheme = theme.value.colorScheme;

    group('Theme ${theme.key}', () {
      test('jede Farbrolle traegt ihre Schrift', () {
        final pairs = {
          'primary': (scheme.primary, scheme.onPrimary),
          'primaryContainer': (scheme.primaryContainer, scheme.onPrimaryContainer),
          'secondaryContainer': (scheme.secondaryContainer, scheme.onSecondaryContainer),
          'surface': (scheme.surface, scheme.onSurface),
          'surfaceContainerHighest': (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
          'error': (scheme.error, scheme.onError),
        };

        for (final pair in pairs.entries) {
          final ratio = contrast(pair.value.$1, pair.value.$2);
          expect(ratio, greaterThanOrEqualTo(readable),
              reason: '${pair.key} erreicht nur ${ratio.toStringAsFixed(2)}:1');
        }
      });

      test('die AppBar traegt ihre Schrift', () {
        final bar = theme.value.appBarTheme;
        final ratio = contrast(bar.backgroundColor!, bar.foregroundColor!);
        expect(ratio, greaterThanOrEqualTo(readable),
            reason: 'AppBar erreicht nur ${ratio.toStringAsFixed(2)}:1');
      });

      test('primary ist als Schrift auf der Flaeche lesbar', () {
        // primary is not only a fill: text buttons, focus rings and the active
        // switch draw with it directly on the surface.
        final ratio = contrast(scheme.primary, scheme.surface);
        expect(ratio, greaterThanOrEqualTo(readable),
            reason: 'primary auf surface erreicht nur ${ratio.toStringAsFixed(2)}:1');
      });
    });
  }

  test('die Hausfarbe kommt in beiden Themes sichtbar vor', () {
    expect(
      [AppTheme.light.colorScheme.primaryContainer, AppTheme.light.appBarTheme.backgroundColor],
      contains(AppTheme.brand),
    );
    expect(AppTheme.dark.colorScheme.primary, AppTheme.brand);
  });

  test('weisse Schrift auf der Hausfarbe waere unlesbar', () {
    // The premise the whole theme is built on. If a future Flutter or a new
    // brand colour makes this false, the workarounds above can be dropped.
    expect(contrast(AppTheme.brand, Colors.white), lessThan(readable));
  });
}
