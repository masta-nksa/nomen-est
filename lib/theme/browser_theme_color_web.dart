import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Repaints the browser's own surroundings — the address bar on Android, the
/// title bar of an installed app — in the school's colour.
///
/// `web/index.html` ships one house colour in its `theme-color` tag, and it
/// takes effect before Flutter has started; the app icon is fixed in the same
/// way. Once the stored palette is known, this corrects the tag, so at worst
/// the bar changes colour once during the first frames instead of staying the
/// wrong school's for good.
void setBrowserThemeColor(Color color) {
  final meta = web.document.querySelector('meta[name="theme-color"]');
  if (meta == null) return;
  final hex = (color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
  meta.setAttribute('content', '#$hex');
}
