import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Tappable image picker tile. Shows a dashed border when no image is selected,
/// and overlays a semi-transparent scrim when one is set.
class CreateEventImagePickerTile extends StatelessWidget {
  const CreateEventImagePickerTile({
    super.key,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.imageUrl,
  });

  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return InkWell(
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
            decoration: imageUrl != null
                ? BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  )
                : null,
            child: Container(
              color: imageUrl != null ? Colors.black.withValues(alpha: 0.3) : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    imageUrl != null
                        ? Icons.photo_library_rounded
                        : Icons.add_a_photo_rounded,
                    size: 42,
                    color: imageUrl != null ? Colors.white : scheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: imageUrl != null ? Colors.white : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: imageUrl != null
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
