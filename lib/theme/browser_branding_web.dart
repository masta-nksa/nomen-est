import 'package:web/web.dart' as web;

import 'app_theme.dart';

/// Everything outside the Flutter canvas that carries the school's colour: the
/// tab icon, the icon iOS takes when the page is added to the home screen, and
/// the tint of the browser's own bars.
///
/// `web/index.html` ships one school in its tags, and those take effect before
/// Flutter has started. Once the stored palette is known, this corrects them —
/// so at worst the tab shows the wrong school for the first few frames instead
/// of for good.
///
/// What this cannot reach is the icon of an *installed* app: that one comes
/// from `manifest.json` and is fixed when the app is installed. Switching
/// school and only then adding it to the home screen does give the right icon,
/// because both iOS and Chrome read these tags at that moment.
void applyBrowserBranding(BrandPalette palette) {
  // Called from build(), which runs on every rebuild. Rewriting an unchanged
  // href makes some browsers re-fetch the icon, and a tab whose icon flickers
  // looks like a page that keeps reloading.
  if (palette.id == _applied) return;
  _applied = palette.id;

  final hex = (palette.brand.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
  _setMeta('theme-color', '#$hex');

  // Relative to the document's base href, which the build sets to the
  // deployment path — so this works under /nomen-est/ and /nomen-est/preview/
  // alike.
  _setLink('icon', 'icons/${palette.id}/favicon.png');
  _setLink('apple-touch-icon', 'icons/${palette.id}/apple-touch-icon.png');
}

String? _applied;

void _setMeta(String name, String content) =>
    web.document.querySelector('meta[name="$name"]')?.setAttribute('content', content);

void _setLink(String rel, String href) =>
    web.document.querySelector('link[rel="$rel"]')?.setAttribute('href', href);
