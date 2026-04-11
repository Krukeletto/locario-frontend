import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/explore/widgets/map_event_clusterer.dart';
import 'package:locario/l10n/app_localizations_pl.dart';

void main() {
  final l10n = AppLocalizationsPl();
  final events = buildExploreEvents(l10n);

  group('MapEventClusterer', () {
    test('clusters nearby screen positions together', () {
      const clusterer = MapEventClusterer();

      final clusters = clusterer.cluster(
        events: events.take(3).toList(growable: false),
        screenPositions: const [
          Offset(100, 100),
          Offset(108, 104),
          Offset(360, 320),
        ],
        zoom: 13,
        viewportSize: const Size(400, 800),
      );

      expect(clusters, hasLength(2));
      expect(clusters.first.events.length, 2);
      expect(clusters.last.events.length, 1);
    });
  });
}
