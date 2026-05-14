import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:locario/app/theme/app_theme_colors.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../create_event_state.dart';

/// Tappable image picker tile. Shows a dashed border when no image is selected,
/// and overlays a semi-transparent scrim when one is set.
class CreateEventImagePickerTile extends StatelessWidget {
  const CreateEventImagePickerTile({
    super.key,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.selectedImages = const [],
  });

  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final List<CreateEventSelectedImage> selectedImages;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final themeColors =
        theme.extension<LocarioThemeColors>() ??
        const LocarioThemeColors(onScrim: Colors.white);
    final l10n = AppLocalizations.of(context);
    final primaryImage = selectedImages.firstOrNull;
    final showImage = primaryImage != null;
    final labelText = selectedImages.isEmpty
        ? label
        : l10n.hubCreateEventPhotosLabel;
    final subtitleText = selectedImages.isEmpty
        ? subtitle
        : selectedImages.length == 1
        ? primaryImage!.fileName
        : l10n.hubCreateEventSelectedPhotosCount(selectedImages.length);

    return InkWell(
      key: const Key('create-event-image-picker'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: scheme.primary.withValues(alpha: 0.3),
            radius: 16,
          ),
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: showImage
                ? BoxDecoration(
                    image: DecorationImage(
                      image: MemoryImage(
                        Uint8List.fromList(primaryImage.bytes),
                      ),
                      fit: BoxFit.cover,
                    ),
                  )
                : null,
            child: Container(
              color: showImage ? scheme.scrim.withValues(alpha: 0.3) : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    showImage
                        ? Icons.photo_library_rounded
                        : Icons.add_a_photo_rounded,
                    size: 42,
                    color: showImage ? themeColors.onScrim : scheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    labelText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: showImage ? themeColors.onScrim : null,
                    ),
                  ),
                  Text(
                    subtitleText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: showImage
                          ? themeColors.onScrim.withValues(alpha: 0.8)
                          : scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 8), paint);
        distance += 16;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
