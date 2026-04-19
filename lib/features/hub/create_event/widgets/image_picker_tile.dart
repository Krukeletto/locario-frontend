import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Tappable image picker tile. Shows a dashed border when no image is selected,
/// and overlays a semi-transparent scrim when one is set.
class CreateEventImagePickerTile extends StatelessWidget {
  const CreateEventImagePickerTile({
    super.key,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.imageUrl,
    this.imageBytes,
    this.selectedFileName,
  });

  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final String? imageUrl;
  final List<int>? imageBytes;
  final String? selectedFileName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final hasLocalImage = imageBytes != null && imageBytes!.isNotEmpty;
    final hasRemoteImage = imageUrl != null && imageUrl!.isNotEmpty;
    final showImage = hasLocalImage || hasRemoteImage;

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
                      image: hasLocalImage
                          ? MemoryImage(Uint8List.fromList(imageBytes!))
                          : CachedNetworkImageProvider(imageUrl!)
                                as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  )
                : null,
            child: Container(
              color: showImage ? Colors.black.withValues(alpha: 0.3) : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    showImage
                        ? Icons.photo_library_rounded
                        : Icons.add_a_photo_rounded,
                    size: 42,
                    color: showImage ? Colors.white : scheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: showImage ? Colors.white : null,
                    ),
                  ),
                  Text(
                    selectedFileName ?? subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: showImage
                          ? Colors.white.withValues(alpha: 0.8)
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
