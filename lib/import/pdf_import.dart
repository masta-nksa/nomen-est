import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pdfrx/pdfrx.dart';

/// One person extracted from a class-photo PDF.
class ImportedPerson {
  ImportedPerson({
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

  ImportedPerson copyWith({String? firstName, String? lastName}) => ImportedPerson(
        displayName: displayName,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        jpegBytes: jpegBytes,
        orderIndex: orderIndex,
      );
}

/// A detected photo rectangle in rendered-bitmap pixel coordinates.
class PhotoBox {
  const PhotoBox(this.x, this.y, this.width, this.height);

  final int x;
  final int y;
  final int width;
  final int height;
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

/// Words on the same text line share a baseline within this tolerance.
const _sameLineTolerancePt = 2.0;

/// Extracts photo/name pairs from a class-photo PDF produced by the school
/// administration.
///
/// The layout constants of the source template (column pitch, photo size, ...)
/// are derived from the rendered page rather than hard-coded, so a template
/// change does not silently break the import.
Future<List<ImportedPerson>> parsePdf(Uint8List bytes, {String sourceName = 'memory'}) async {
  // Required because this uses the document API without ever building a pdfrx
  // widget; on web nothing else sets up the PDFium WASM entry points. The call
  // is idempotent, so doing it here keeps callers from having to remember.
  await pdfrxFlutterInitialize();

  final doc = await PdfDocument.openData(bytes, sourceName: sourceName);
  try {
    final people = <ImportedPerson>[];
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
        people.add(ImportedPerson(
          displayName: displayName,
          firstName: firstName,
          lastName: lastName,
          jpegBytes: img.encodeJpg(crop, quality: 85),
          orderIndex: people.length,
        ));
      }
    }
    return people;
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
        if (x - colStart > _minBoxWidthPx) {
          boxes.add(PhotoBox(colStart, top, x - colStart, bandHeight));
        }
        colStart = null;
      }
    }
    if (colStart != null && width - colStart > _minBoxWidthPx) {
      boxes.add(PhotoBox(colStart, top, width - colStart, bandHeight));
    }
  }
  return boxes;
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
  double pdfBottom(PhotoBox b) => pageHeight - (b.y + b.height) * _pxToPt;
  double pdfLeft(PhotoBox b) => b.x * _pxToPt;

  final headerCutoff = boxes.map(pdfTop).reduce((a, b) => a > b ? a : b);
  final columnPitch = _deriveColumnPitch(boxes);

  final words = text.fragments
      .where((f) => f.text.trim().isNotEmpty)
      .where((f) => f.bounds.top < headerCutoff)
      .toList();

  return [
    for (final box in boxes) _nameForBox(box, words, pdfLeft(box), pdfBottom(box), columnPitch),
  ];
}

/// Horizontal distance between adjacent photo columns, in points.
///
/// Falls back to a generous multiple of the photo width when a page holds only
/// one photo and the pitch cannot be measured.
double _deriveColumnPitch(List<PhotoBox> boxes) {
  final lefts = boxes.map((b) => b.x).toSet().toList()..sort();
  if (lefts.length < 2) return boxes.first.width * _pxToPt * 1.5;
  var minGap = lefts[1] - lefts[0];
  for (var i = 2; i < lefts.length; i++) {
    final gap = lefts[i] - lefts[i - 1];
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

  // Stop at the first large vertical gap — otherwise the page footer's date
  // gets appended to the last name in the first column.
  final kept = <PdfPageTextFragment>[];
  for (var i = 0; i < lines.length; i++) {
    if (i > 0 && lines[i - 1].first.bounds.top - lines[i].first.bounds.top >= _maxLineGapPt) break;
    kept.addAll(lines[i]);
  }
  return kept.map((w) => w.text.trim()).join(' ');
}
