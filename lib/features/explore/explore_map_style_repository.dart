import 'package:flutter/services.dart';

class ExploreMapStyleRepository {
  const ExploreMapStyleRepository({
    AssetBundle? assetBundle,
    this.assetPath = defaultAssetPath,
    this.inlineStyleJson,
  }) : _assetBundle = assetBundle;

  static const String defaultAssetPath =
      'assets/map_styles/openstreetmap_custom.json';

  final AssetBundle? _assetBundle;
  final String assetPath;
  final String? inlineStyleJson;

  Future<String> loadStyleJson() async {
    final inlineStyleJson = this.inlineStyleJson;
    if (inlineStyleJson != null) {
      return inlineStyleJson;
    }

    return (_assetBundle ?? rootBundle).loadString(assetPath);
  }
}
