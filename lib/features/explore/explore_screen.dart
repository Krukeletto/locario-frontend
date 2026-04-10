import 'package:flutter/material.dart';

import '../../shared/location/location_service.dart';
import 'explore_map_style_repository.dart';
import 'explore_map_view_model.dart';
import 'widgets/map_widget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    ExploreMapViewModel? controller,
    ExploreMapStyleRepository? styleRepository,
  }) : _controller = controller,
       _styleRepository = styleRepository;

  final ExploreMapViewModel? _controller;
  final ExploreMapStyleRepository? _styleRepository;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final ExploreMapViewModel _controller;
  late final ExploreMapStyleRepository _styleRepository;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget._controller == null;
    _controller =
        widget._controller ??
        ExploreMapViewModel(locationService: GeolocatorLocationService());
    _styleRepository =
        widget._styleRepository ?? const ExploreMapStyleRepository();
    _controller.loadInitialLocation();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.18),
      Theme.of(context).colorScheme.primary,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: MapWidget(
        controller: _controller,
        styleRepository: _styleRepository,
      ),
    );
  }
}
