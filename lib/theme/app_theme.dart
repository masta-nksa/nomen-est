import 'package:flutter/material.dart';

/// The tones one school's house colour resolves into for a single brightness.
///
/// [ink] is the house colour *as a foreground* — a button label, an icon, a
/// focus ring. It is rarely the house colour itself: a colour bright enough to
/// carry black text is usually too bright to be text on white, and the other
/// way round. Which of the two problems a school has depends on its colour, so
/// both modes name their own [ink] rather than deriving one.
class BrandTones {
  const BrandTones({
    required this.ink,
    required this.onInk,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.surface,
    required this.surfaceHigh,
    required this.onSurfaceVariant,
  });

  final Color ink;
  final Color onInk;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color surface;
  final Color surfaceHigh;
  final Color onSurfaceVariant;
}

/// One school's colours.
///
/// The app is used at two schools on the same campus, and a teacher may work at
/// both. So the colours are a stored setting rather than a second build: one
/// URL, one service worker, one update.
///
/// Every palette is held to the contrast rules by `app_theme_test.dart`, which
/// runs over all of [all]. A new school is a new entry here and nothing else;
/// if its colours cannot carry their text, the test says so before anyone sees
/// an unreadable screen.
class BrandPalette {
  const BrandPalette({
    required this.id,
    required this.label,
    required this.brand,
    required this.onBrand,
    required this.deep,
    required this.onDeep,
    required this.light,
    required this.dark,
  });

  /// Stored in the settings table, so it has to stay stable.
  final String id;

  /// What the school is called in the appearance sheet.
  final String label;

  /// The house colour as a *filled area*: the light AppBar, the primary
  /// container. This is what makes the app recognisable across the room, so
  /// here it is used unaltered.
  final Color brand;

  /// Text and icons that sit on [brand].
  final Color onBrand;

  /// The same filled area for dark mode, muted so it does not glare.
  final Color deep;

  /// Text and icons that sit on [deep].
  final Color onDeep;

  final BrandTones light;
  final BrandTones dark;

  /// Neue Kantonsschule Aarau.
  ///
  /// The orange cannot simply be dropped into every Material role: white text
  /// on it reaches only 2.4:1, and as a foreground on the light surface it
  /// reaches 2.3:1 — both far short of the 4.5:1 body text needs. So wherever
  /// the orange is a background, the text on it is near-black, and light mode
  /// darkens it for foreground roles. Dark mode can use the house colour
  /// itself, which reaches 7.9:1 on the dark surface.
  ///
  /// `tool/gen_icons.py` holds [brand] a second time for the app icons; change
  /// it in both places.
  static const nksa = BrandPalette(
    id: 'nksa',
    label: 'NKSA',
    brand: Color(0xFFFF890A),
    onBrand: Color(0xFF2A1400),
    deep: Color(0xFF8A4A00),
    onDeep: Color(0xFFFFDDBF),
    light: BrandTones(
      // `#B35F00` would be the obvious darkening and misses by a hair: it
      // clears 4.5:1 against pure white but only reaches 4.47:1 against the
      // warm surface actually used.
      ink: Color(0xFFA85A00),
      onInk: Colors.white,
      secondaryContainer: Color(0xFFFFE2C6),
      onSecondaryContainer: Color(0xFF4A2B00),
      surface: Color(0xFFFFFBF7),
      surfaceHigh: Color(0xFFF6EADF),
      onSurfaceVariant: Color(0xFF574434),
    ),
    dark: BrandTones(
      ink: Color(0xFFFF890A),
      onInk: Color(0xFF2A1400),
      secondaryContainer: Color(0xFF46301A),
      onSecondaryContainer: Color(0xFFFFDDBF),
      surface: Color(0xFF17110C),
      surfaceHigh: Color(0xFF33291F),
      onSurfaceVariant: Color(0xFFD9C5B2),
    ),
  );

  /// Maturitätsschule für Erwachsene, Aarau.
  ///
  /// The blue is the mirror image of the NKSA orange, which is why the two
  /// modes carry their own [BrandTones] instead of deriving one from the
  /// other. White on the blue reaches 6.4:1 and the blue reaches 6.2:1 as text
  /// on the light surface — light mode therefore needs no darkening at all and
  /// its bar carries white text. On the dark surface the same blue drops to
  /// 3.0:1, so there it is dark mode that has to lighten the house colour.
  ///
  /// The neutrals are tinted cool for the same reason the NKSA ones are tinted
  /// warm: the blue on a cream-tinted white looks soiled.
  static const ame = BrandPalette(
    id: 'ame',
    label: 'AME',
    brand: Color(0xFF005EB8),
    onBrand: Colors.white,
    deep: Color(0xFF00468B),
    onDeep: Color(0xFFD3E4FF),
    light: BrandTones(
      ink: Color(0xFF005EB8),
      onInk: Colors.white,
      secondaryContainer: Color(0xFFD7E6F7),
      onSecondaryContainer: Color(0xFF0A2E52),
      surface: Color(0xFFF9FBFD),
      surfaceHigh: Color(0xFFE6EDF5),
      onSurfaceVariant: Color(0xFF3F4E5E),
    ),
    dark: BrandTones(
      ink: Color(0xFF74B4F0),
      onInk: Color(0xFF00325C),
      secondaryContainer: Color(0xFF1B3A57),
      onSecondaryContainer: Color(0xFFD3E4FF),
      surface: Color(0xFF0D1218),
      surfaceHigh: Color(0xFF232B34),
      onSurfaceVariant: Color(0xFFBFCBD8),
    ),
  );

  static const all = [nksa, ame];

  /// The palette a stored id names — or the default, for an id written by a
  /// future version that this build does not know.
  static BrandPalette byId(String? id) =>
      all.where((p) => p.id == id).firstOrNull ?? nksa;
}

/// One light and one dark theme, built from a school's [BrandPalette].
///
/// Feeding a house colour to `ColorScheme.fromSeed` alone does not work:
/// Material's tonal mapping answers the NKSA orange with `#895020`, a muted
/// brown in which the house colour is no longer recognisable. So the neutrals
/// come from the seed — they are well-balanced and carry a tint that suits the
/// house colour — and the branded roles are then set explicitly on top.
abstract final class AppTheme {
  static ThemeData light(BrandPalette palette) => _build(palette, Brightness.light);

  static ThemeData dark(BrandPalette palette) => _build(palette, Brightness.dark);

  static ThemeData _build(BrandPalette palette, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final tones = isLight ? palette.light : palette.dark;
    final base = ColorScheme.fromSeed(seedColor: palette.brand, brightness: brightness);

    final scheme = base.copyWith(
      primary: tones.ink,
      onPrimary: tones.onInk,
      // The house colour lives here: a container is a filled area, and a filled
      // area is where a colour may be itself. Dark mode fills with the muted
      // version instead.
      primaryContainer: isLight ? palette.brand : palette.deep,
      onPrimaryContainer: isLight ? palette.onBrand : palette.onDeep,
      secondaryContainer: tones.secondaryContainer,
      onSecondaryContainer: tones.onSecondaryContainer,
      surface: tones.surface,
      surfaceContainerHighest: tones.surfaceHigh,
      onSurfaceVariant: tones.onSurfaceVariant,
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      // Light mode wears the house colour as a full bar, which is what makes
      // the app recognisable at a glance. Dark mode does not: a bright band
      // above a near-black page glares in a darkened classroom, so there the
      // house colour shrinks to the title and the icons.
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? palette.brand : scheme.surface,
        foregroundColor: isLight ? palette.onBrand : tones.ink,
        elevation: 0,
        scrolledUnderElevation: isLight ? 0 : 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: isLight ? palette.onBrand : tones.ink,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
