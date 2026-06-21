import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../explore/models.dart';
import 'event_image_placeholder.dart';
import 'fullscreen_gallery.dart';

class EventGallery extends StatefulWidget {
  const EventGallery({
    super.key,
    required this.media,
    required this.thumbnailUrl,
  });

  final List<EventMedia> media;
  final String? thumbnailUrl;

  @override
  State<EventGallery> createState() => _EventGalleryState();
}

class _EventGalleryState extends State<EventGallery> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<EventMedia> _buildImageList() {
    final images = widget.media
        .where((m) => m.type == MediaType.image)
        .toList();
    final thumb = widget.thumbnailUrl;
    if (thumb != null && thumb.isNotEmpty) {
      final alreadyPresent = images.any(
        (m) =>
            m.url == thumb ||
            m.thumbnailUrl == thumb ||
            m.pinUrl == thumb ||
            m.previewUrl == thumb,
      );
      if (!alreadyPresent) {
        images.insert(
          0,
          EventMedia(id: 'thumb', url: thumb, type: MediaType.image),
        );
      }
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final images = _buildImageList();

    if (images.isEmpty) {
      return const EventImagePlaceholder();
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (page) => setState(() => _currentPage = page),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        FullscreenGallery(images: images, initialPage: index),
                  ),
                );
              },
              child: CachedNetworkImage(
                imageUrl: images[index].previewUrl,
                fit: BoxFit.cover,
                memCacheWidth: 900,
                memCacheHeight: 900,
                placeholder: (context, url) => Container(
                  color: scheme.surfaceContainerLow,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    const EventImagePlaceholder(),
              ),
            );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 12 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? scheme.primary
                        : scheme.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
