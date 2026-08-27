import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/theme/app_theme.dart';

/// A house colour is usually bright enough that some pairings are unreadable —
/// white on the NKSA orange reaches only 2.4:1, the AME blue on the dark
/// surface only 3.0:1. The themes work around that, and these tests hold every
/// palette to it, so that adding a school cannot quietly produce a screen
/// nobody can read.
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

  for (final palette in BrandPalette.all) {
    final themes = {'hell': AppTheme.light(palette), 'dunkel': AppTheme.dark(palette)};

    for (final theme in themes.entries) {
      final scheme = theme.value.colorScheme;

      group('${palette.label} ${theme.key}', () {
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

    test('${palette.label}: die Hausfarbe kommt sichtbar vor', () {
      // Unaltered and as a filled area, in light mode: that is what makes the
      // app recognisable from the back of the room.
      final light = AppTheme.light(palette);
      expect(
        [light.colorScheme.primaryContainer, light.appBarTheme.backgroundColor],
        contains(palette.brand),
      );
    });
  }

  test('jede Palette hat eine eigene Kennung', () {
    // The id is what lands in the settings table; two schools sharing one would
    // silently show the wrong colours.
    final ids = BrandPalette.all.map((p) => p.id).toSet();
    expect(ids, hasLength(BrandPalette.all.length));
  });

  test('eine unbekannte Kennung faellt auf die Voreinstellung zurueck', () {
    // A palette added later and then removed, or a database carried over from a
    // newer build, must not leave the app without colours.
    expect(BrandPalette.byId('gibt-es-nicht'), BrandPalette.nksa);
    expect(BrandPalette.byId(null), BrandPalette.nksa);
    expect(BrandPalette.byId('ame'), BrandPalette.ame);
  });

  test('die Hausfarben brauchen entgegengesetzte Kunstgriffe', () {
    // The premise both palettes are built on. NKSA: white on the orange is
    // unreadable, so light mode darkens it and dark mode may use it as it is.
    // AME: the blue carries white text but disappears on the dark surface, so
    // it is dark mode that has to lighten it. If a future Flutter or a changed
    // house colour makes either false, the workarounds can be dropped.
    expect(contrast(BrandPalette.nksa.brand, Colors.white), lessThan(readable));
    expect(contrast(BrandPalette.nksa.brand, BrandPalette.nksa.dark.surface),
        greaterThanOrEqualTo(readable));

    expect(contrast(BrandPalette.ame.brand, Colors.white), greaterThanOrEqualTo(readable));
    expect(contrast(BrandPalette.ame.brand, BrandPalette.ame.dark.surface), lessThan(readable));
  });
}
