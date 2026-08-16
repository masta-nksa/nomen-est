import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Largest sensible on-screen size for a stored photo.
///
/// The embedded JPEGs in the source PDFs are 200 px square, so anything much
/// beyond this is upscaling that only looks soft. Layouts should treat this as
/// a ceiling and shrink below it on small screens.
const maxPhotoSize = 260.0;

/// A photo thumbnail that opens a zoomed view when tapped.
///
/// The stored JPEG is only ~213px square (the PDF is rendered at 200 DPI), so
/// this scales up rather than loading anything sharper — still far easier to
/// recognise a face in than the grid thumbnail.
class ZoomablePhoto extends StatelessWidget {
  const ZoomablePhoto({
    super.key,
    required this.jpegBytes,
    this.caption,
    this.fit = BoxFit.cover,
    this.borderRadius = 8,
  });

  final Uint8List jpegBytes;
  final String? caption;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: caption == null ? 'Foto vergrössern' : 'Foto von $caption vergrössern',
      child: InkWell(
        onTap: () => showPhotoZoom(context, jpegBytes: jpegBytes, caption: caption),
        borderRadius: BorderRadius.circular(borderRadius),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.memory(
            jpegBytes,
            fit: fit,
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}

Future<void> showPhotoZoom(
  BuildContext context, {
  required Uint8List jpegBytes,
  String? caption,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (context) => _PhotoZoomDialog(jpegBytes: jpegBytes, caption: caption),
  );
}

class _PhotoZoomDialog extends StatelessWidget {
  const _PhotoZoomDialog({required this.jpegBytes, this.caption});

  final Uint8List jpegBytes;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: InteractiveViewer(
                maxScale: 6,
                child: Image.memory(
                  jpegBytes,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: 16),
              Text(
                caption!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
