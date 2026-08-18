import 'package:flutter/material.dart';

/// The NKSA house colours, as one light and one dark theme.
///
/// The school's orange is [brand]. It cannot simply be dropped into every
/// Material role, for two measured reasons:
///
///  * White text on it reaches a contrast of only 2.4:1, far short of the 4.5:1
///    that body text needs. Dark text on it reaches 8.8:1. So wherever the
///    orange is a *background*, the text on top of it is near-black, never
///    white.
///  * As a *foreground* — a button label, an icon, a focus ring — it is
///    unreadable on white (2.4:1) but perfectly readable on the dark surface
///    (7.9:1). Light mode therefore darkens it to [_brandInk] for those roles,
///    while dark mode uses the house colour itself.
///
/// Feeding the orange to `ColorScheme.fromSeed` alone does not work either:
/// Material's tonal mapping answers with `#895020`, a muted brown in which the
/// house colour is no longer recognisable. So the neutrals come from the seed —
/// they are well-balanced and carry a warm tint that suits the orange — and the
/// branded roles are then set explicitly on top.
abstract final class AppTheme {
  /// The single source of truth for the house colour. `tool/gen_icons.py` holds
  /// the same value for the app icons; change it in both places.
  static const brand = Color(0xFFFF890A);

  /// Text and icons that sit *on* the orange.
  static const _onBrand = Color(0xFF2A1400);

  /// The orange darkened until it clears 4.5:1 both ways — white text on it,
  /// and it as text on the light surface. For light mode, where the house
  /// colour itself would be illegible as a foreground.
  ///
  /// The obvious `#B35F00` misses by a hair: it clears 4.5:1 against pure
  /// white but only reaches 4.47:1 against the warm surface actually used.
  static const _brandInk = Color(0xFFA85A00);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final base = ColorScheme.fromSeed(seedColor: brand, brightness: brightness);

    final scheme = isLight
        ? base.copyWith(
            primary: _brandInk,
            onPrimary: Colors.white,
            // The house colour lives here: a container is a filled area, and
            // filled areas carry dark text.
            primaryContainer: brand,
            onPrimaryContainer: _onBrand,
            secondaryContainer: const Color(0xFFFFE2C6),
            onSecondaryContainer: const Color(0xFF4A2B00),
            surface: const Color(0xFFFFFBF7),
            surfaceContainerHighest: const Color(0xFFF6EADF),
            onSurfaceVariant: const Color(0xFF574434),
          )
        : base.copyWith(
            primary: brand,
            onPrimary: _onBrand,
            primaryContainer: const Color(0xFF8A4A00),
            onPrimaryContainer: const Color(0xFFFFDDBF),
            secondaryContainer: const Color(0xFF46301A),
            onSecondaryContainer: const Color(0xFFFFDDBF),
            surface: const Color(0xFF17110C),
            surfaceContainerHighest: const Color(0xFF33291F),
            onSurfaceVariant: const Color(0xFFD9C5B2),
          );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      // Light mode wears the house colour as a full orange bar, which is what
      // makes the app recognisable at a glance. Dark mode does not: a bright
      // orange band above a near-black page glares in a darkened classroom, so
      // there the orange shrinks to the title and the icons.
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? brand : scheme.surface,
        foregroundColor: isLight ? _onBrand : brand,
        elevation: 0,
        scrolledUnderElevation: isLight ? 0 : 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: isLight ? _onBrand : brand,
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
