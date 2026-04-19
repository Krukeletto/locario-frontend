import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../explore/models.dart';
import 'event_gallery.dart';
import 'event_image_placeholder.dart';

class EventDetailsGallery extends StatelessWidget {
  const EventDetailsGallery({
    super.key,
    required this.event,
    this.maxImageWidth = 360.0,
    this.padding = const EdgeInsets.only(top: 8.0),
  });

  final ExploreEvent event;
  final double maxImageWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final imageWidth = math.min(screenWidth - 40, maxImageWidth);

    return Padding(
      padding: padding,
      child: Center(
        child: SizedBox(
          width: imageWidth,
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: event.media.isEmpty && event.effectiveThumbnailUrl == null
                  ? const EventImagePlaceholder()
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: EventGallery(
                        media: event.media,
                        thumbnailUrl: event.thumbnailUrl,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
