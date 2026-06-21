import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/events/widgets/gallery/event_gallery.dart';
import 'package:locario/features/explore/models.dart';

void main() {
  testWidgets('does not duplicate thumbnail variant as a separate image', (
    tester,
  ) async {
    const media = [
      EventMedia(
        id: 'media-1',
        url: 'http://localhost:9000/original-1.jpg',
        thumbnailUrl: 'http://localhost:9000/thumb_640/original-1.jpg',
        pinUrl: 'http://localhost:9000/pin_128/original-1.jpg',
        type: MediaType.image,
      ),
      EventMedia(
        id: 'media-2',
        url: 'http://localhost:9000/original-2.jpg',
        thumbnailUrl: 'http://localhost:9000/thumb_640/original-2.jpg',
        pinUrl: 'http://localhost:9000/pin_128/original-2.jpg',
        type: MediaType.image,
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 240,
            child: EventGallery(
              media: media,
              thumbnailUrl: 'http://localhost:9000/thumb_640/original-1.jpg',
            ),
          ),
        ),
      ),
    );

    final pageView = tester.widget<PageView>(find.byType(PageView));

    expect(pageView.childrenDelegate.estimatedChildCount, 2);
  });
}
