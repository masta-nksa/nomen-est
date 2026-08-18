import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pdfrx/pdfrx.dart';

/// One student extracted from a class-photo PDF.
class ImportedStudent {
  ImportedStudent({
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.jpegBytes,
    required this.orderIndex,
  });

  final String displayName;
  final String firstName;
  final String lastName;
  final Uint8List jpegBytes;
  final int orderIndex;

  ImportedStudent copyWith({String? firstName, String? lastName}) => ImportedStudent(
        displayName: displayName,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        jpegBytes: jpegBytes,
        orderIndex: orderIndex,
      );
}

/// A detected photo rectangle in rendered-bitmap pixel coordinates.
class PhotoBox {
  const PhotoBox(this.x, this.y, this.width, this.height, {required this.rowBottom});

  final int x;
  final int y;
  final int width;
  final int height;

  /// Bottom of the row this photo sits in, which is not its own bottom when a
  /// neighbour is taller.
  ///
  /// Names are placed by the row, so they have to be looked for from here — a
  /// photo trimmed to its own height would otherwise start its search 50 pt
  /// above where the text actually is.
  final int rowBottom;
}

const _renderDpi = 200.0;
const _pxToPt = 72.0 / _renderDpi;

/// Pixel is "ink" below this average brightness.
const _inkThreshold = 245;

/// A row band starts once this fraction of the page width is ink.
const _bandInkFraction = 0.04;

/// Text lines are ~20px tall at 200 DPI, photos ~213px — this filter drops text.
const _minBandHeightPx = 80;

/// Within a band, a column starts once this fraction of the band height is ink.
const _boxInkFraction = 0.5;
const _minBoxWidthPx = 80;

/// How far below a photo's bottom edge its name block may reach.
const _nameSearchDepthPt = 70.0;

/// Words start at the photo's left edge; allow for sub-point rendering drift.
const _leftEdgeTolerancePt = 3.0;

/// Lines further apart than this are not part of the same name.
const _maxLineGapPt = 14.0;

/// Long names wrap onto a second line; nothing in the template uses a third.
const _maxNameLines = 2;

/// Words on the same text line share a baseline within this tolerance.
const _sameLineTolerancePt = 2.0;

/// Extracts photo/name pairs from a class-photo PDF produced by the school
/// administration.
///
/// The layout constants of the source template (column pitch, photo size, ...)
/// are derived from the rendered page rather than hard-coded, so a template
/// change does not silently break the import.
Future<List<ImportedStudent>> parsePdf(Uint8List bytes, {String sourceName = 'memory'}) async {
  // Required because this uses the document API without ever building a pdfrx
  // widget; on web nothing else sets up the PDFium WASM entry points. The call
  // is idempotent, so doing it here keeps callers from having to remember.
  await pdfrxFlutterInitialize();

  final doc = await PdfDocument.openData(bytes, sourceName: sourceName);
  try {
    final students = <ImportedStudent>[];
    for (final page in doc.pages) {
      final image = await page.render(
        fullWidth: page.width * _renderDpi / 72,
        fullHeight: page.height * _renderDpi / 72,
      );
      if (image == null) continue;

      // pixels is a view onto memory that dispose() frees, so copy it out
      // before releasing the image — both the projection scan and the crops
      // below outlive the PdfImage.
      final int width;
      final int height;
      final Uint8List bgra;
      try {
        width = image.width;
        height = image.height;
        bgra = Uint8List.fromList(image.pixels);
      } finally {
        image.dispose();
      }

      final boxes = detectPhotoBoxes(bgra, width, height);
      if (boxes.isEmpty) continue;

      final bitmap = img.Image.fromBytes(
        width: width,
        height: height,
        bytes: bgra.buffer,
        numChannels: 4,
        order: img.ChannelOrder.bgra,
      );

      final text = await page.loadStructuredText();
      final names = _assignNames(boxes, text, page.height);

      for (var i = 0; i < boxes.length; i++) {
        final box = boxes[i];
        final crop = img.copyCrop(bitmap, x: box.x, y: box.y, width: box.width, height: box.height);
        final displayName = names[i];
        final (firstName, lastName) = splitName(displayName);
        students.add(ImportedStudent(
          displayName: displayName,
          firstName: firstName,
          lastName: lastName,
          jpegBytes: img.encodeJpg(crop, quality: 85),
          orderIndex: students.length,
        ));
      }
    }
    return students;
  } finally {
    await doc.dispose();
  }
}

/// Finds photo rectangles in a rendered page via ink projection profiles.
///
/// Rows are scanned first and filtered by height, which discards text lines
/// outright and lets the ink threshold stay low enough that a row holding a
/// single photo is still detected.
List<PhotoBox> detectPhotoBoxes(Uint8List bgra, int width, int height) {
  bool isInk(int x, int y) {
    final i = (y * width + x) * 4;
    return (bgra[i] + bgra[i + 1] + bgra[i + 2]) / 3 < _inkThreshold;
  }

  final bands = <(int, int)>[];
  final bandInkMin = _bandInkFraction * width;
  int? bandStart;
  for (var y = 0; y < height; y++) {
    var ink = 0;
    for (var x = 0; x < width; x++) {
      if (isInk(x, y)) ink++;
    }
    if (ink > bandInkMin) {
      bandStart ??= y;
    } else if (bandStart != null) {
      if (y - bandStart > _minBandHeightPx) bands.add((bandStart, y));
      bandStart = null;
    }
  }
  if (bandStart != null && height - bandStart > _minBandHeightPx) {
    bands.add((bandStart, height));
  }

  /// Trims a column's rectangle to its own photo.
  ///
  /// A row band is as tall as its tallest photo, and not every PDF has photos
  /// of one size — a single portrait-format picture in a row would otherwise
  /// give all its neighbours a white bar underneath. Measured against the real
  /// files, the signal is absolute: a row inside a photo is ink across its full
  /// width and a row outside it is empty, so the threshold barely matters.
  PhotoBox trimmed(int x0, int x1, int top, int bottom) {
    final boxWidth = x1 - x0;
    final rowInkMin = _boxInkFraction * boxWidth;
    var first = -1;
    var last = -1;
    for (var y = top; y < bottom; y++) {
      var ink = 0;
      for (var x = x0; x < x1; x++) {
        if (isInk(x, y)) ink++;
      }
      if (ink > rowInkMin) {
        if (first == -1) first = y;
        last = y;
      }
    }
    // Cannot normally happen — the column was found by the same threshold — but
    // falling back to the band beats returning nothing.
    if (first == -1) return PhotoBox(x0, top, boxWidth, bottom - top, rowBottom: bottom);
    return PhotoBox(x0, first, boxWidth, last - first + 1, rowBottom: bottom);
  }

  final boxes = <PhotoBox>[];
  for (final (top, bottom) in bands) {
    final bandHeight = bottom - top;
    final colInkMin = _boxInkFraction * bandHeight;
    int? colStart;
    for (var x = 0; x < width; x++) {
      var ink = 0;
      for (var y = top; y < bottom; y++) {
        if (isInk(x, y)) ink++;
      }
      if (ink > colInkMin) {
        colStart ??= x;
      } else if (colStart != null) {
        if (x - colStart > _minBoxWidthPx) boxes.add(trimmed(colStart, x, top, bottom));
        colStart = null;
      }
    }
    if (colStart != null && width - colStart > _minBoxWidthPx) {
      boxes.add(trimmed(colStart, width, top, bottom));
    }
  }
  return boxes;
}

/// How many of a photo's candidate text lines belong to its name.
///
/// [tops] are the lines' y coordinates in PDF points, highest first, and
/// [texts] their joined text.
///
/// Three guards, because one is not enough at the measured spacing. On the
/// reference layout a name sits 31.8 pt below its photo, a wrapped second line
/// 8.6 pt under that, and the page footer's date another 11 pt lower. The gap
/// rule alone therefore catches a one-line name followed by the date (19.6 pt
/// apart) but *not* a wrapped one — the date is then closer to the second line
/// than the threshold, and gets appended to the name.
///
/// A third line is dropped rather than kept: the template does not produce one,
/// and the import review screen exists for the rare case where that is wrong.
int nameLineCount(List<double> tops, List<String> texts) {
  var kept = 0;
  for (var i = 0; i < tops.length && i < _maxNameLines; i++) {
    if (i > 0 && tops[i - 1] - tops[i] >= _maxLineGapPt) break;
    // Names carry no digits, dates and page numbers do.
    if (texts[i].contains(RegExp(r'\d'))) break;
    kept++;
  }
  return kept;
}

/// Splits "Nachname Vorname(n)" into (firstName, lastName).
///
/// The boundary is genuinely ambiguous in the source data ("Ahumada Torres
/// Gloria" has a two-token last name), so this only guesses and the import
/// review screen lets the user move the split.
(String, String) splitName(String displayName) {
  final tokens = displayName.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  if (tokens.isEmpty) return ('', '');
  if (tokens.length == 1) return ('', tokens.first);
  return (tokens.sublist(1).join(' '), tokens.first);
}

/// Collects the name text belonging to each photo box, in box order.
List<String> _assignNames(List<PhotoBox> boxes, PdfPageText text, double pageHeight) {
  double pdfTop(PhotoBox b) => pageHeight - b.y * _pxToPt;

  /// From the row, not from the photo: a trimmed photo ends above its row when a
  /// neighbour is taller, and the name still sits under the row.
  double pdfBottom(PhotoBox b) => pageHeight - b.rowBottom * _pxToPt;
  final headerCutoff = boxes.map(pdfTop).reduce((a, b) => a > b ? a : b);
  final columns = _columnLefts(boxes);
  final columnPitch = _deriveColumnPitch(columns, boxes);

  /// The left edge of the photo's *column*, not of the photo.
  ///
  /// A photo that is a few pixels narrower sits slightly off its column, and
  /// its name still starts where the column does. Searching from the photo's
  /// own edge would start to the right of the text and find nothing.
  double pdfLeft(PhotoBox b) {
    var column = columns.first;
    for (final left in columns) {
      if (left <= b.x) column = left;
    }
    return column * _pxToPt;
  }

  final words = text.fragments
      .where((f) => f.text.trim().isNotEmpty)
      .where((f) => f.bounds.top < headerCutoff)
      .toList();

  return [
    for (final box in boxes) _nameForBox(box, words, pdfLeft(box), pdfBottom(box), columnPitch),
  ];
}

/// The left edge of each photo column, in pixels, left to right.
///
/// Photo edges are not perfectly aligned down a column — one class had a
/// picture 18 px narrower than the rest, sitting 19 px to the right of its
/// column. Left edges within half a photo width of each other are therefore
/// folded into one column, taking the leftmost as the edge.
///
/// Without this, that single stray photo halves the measured column spacing
/// (its own edge sits 19 px from its neighbour's, where columns are 275 px
/// apart), the search window for every name on the page collapses to a few
/// points, and each student ends up with their first word and nothing else.
List<int> _columnLefts(List<PhotoBox> boxes) {
  final widths = boxes.map((b) => b.width).toList()..sort();
  return columnLefts(
    boxes.map((b) => b.x).toList(),
    tolerance: widths[widths.length ~/ 2] * 0.5,
  );
}

/// Groups [lefts] that lie within [tolerance] of each other, keeping the
/// leftmost of each group.
List<int> columnLefts(List<int> lefts, {required double tolerance}) {
  final sorted = lefts.toSet().toList()..sort();
  final columns = <int>[];
  for (final left in sorted) {
    if (columns.isEmpty || left - columns.last > tolerance) columns.add(left);
  }
  return columns;
}

/// Horizontal distance between adjacent photo columns, in points.
///
/// Falls back to a generous multiple of the photo width when a page holds only
/// one column and the pitch cannot be measured.
double _deriveColumnPitch(List<int> columns, List<PhotoBox> boxes) {
  if (columns.length < 2) return boxes.first.width * _pxToPt * 1.5;
  var minGap = columns[1] - columns[0];
  for (var i = 2; i < columns.length; i++) {
    final gap = columns[i] - columns[i - 1];
    if (gap < minGap) minGap = gap;
  }
  return minGap * _pxToPt;
}

String _nameForBox(
  PhotoBox box,
  List<PdfPageTextFragment> words,
  double left,
  double bottom,
  double columnPitch,
) {
  final inColumn = words.where((w) {
    final x = w.bounds.left;
    final y = w.bounds.top;
    return x >= left - _leftEdgeTolerancePt &&
        x < left + columnPitch - _leftEdgeTolerancePt &&
        y < bottom &&
        y > bottom - _nameSearchDepthPt;
  }).toList()
    ..sort((a, b) {
      final byTop = b.bounds.top.compareTo(a.bounds.top);
      return byTop != 0 ? byTop : a.bounds.left.compareTo(b.bounds.left);
    });

  final lines = <List<PdfPageTextFragment>>[];
  for (final word in inColumn) {
    final last = lines.isEmpty ? null : lines.last;
    if (last != null && (last.first.bounds.top - word.bounds.top).abs() <= _sameLineTolerancePt) {
      last.add(word);
    } else {
      lines.add([word]);
    }
  }

  final texts = [for (final line in lines) line.map((w) => w.text.trim()).join(' ')];
  final count = nameLineCount([for (final line in lines) line.first.bounds.top], texts);
  return texts.take(count).join(' ');
}
