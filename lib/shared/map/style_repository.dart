import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MapStyleRepository {
  const MapStyleRepository({
    AssetBundle? assetBundle,
    this.assetPath = defaultAssetPath,
    this.inlineStyleJson,
    this.darkAssetPath,
    this.inlineDarkStyleJson,
  }) : _assetBundle = assetBundle;

  static const String defaultAssetPath =
      'assets/map_styles/openstreetmap_custom.json';

  final AssetBundle? _assetBundle;
  final String assetPath;
  final String? inlineStyleJson;
  final String? darkAssetPath;
  final String? inlineDarkStyleJson;

  Future<String> loadStyleJson({
    Brightness brightness = Brightness.light,
  }) async {
    if (brightness == Brightness.dark) {
      final inlineDarkStyleJson = this.inlineDarkStyleJson;
      if (inlineDarkStyleJson != null) {
        return inlineDarkStyleJson;
      }

      final darkAssetPath = this.darkAssetPath;
      if (darkAssetPath != null) {
        return (_assetBundle ?? rootBundle).loadString(darkAssetPath);
      }

      final sourceStyleJson =
          this.inlineStyleJson ??
          await (_assetBundle ?? rootBundle).loadString(assetPath);
      return _buildDarkStyleJson(sourceStyleJson);
    }

    final inlineStyleJson = this.inlineStyleJson;
    if (inlineStyleJson != null) {
      return inlineStyleJson;
    }

    return (_assetBundle ?? rootBundle).loadString(assetPath);
  }

  String _buildDarkStyleJson(String sourceStyleJson) {
    final decodedStyle = json.decode(sourceStyleJson);
    final transformedStyle = _transformNode(decodedStyle);
    return json.encode(transformedStyle);
  }

  dynamic _transformNode(
    dynamic node, {
    String? key,
    String? layerId,
    String? layerType,
  }) {
    if (node is Map) {
      final nextLayerId = node['id'] is String ? node['id'] as String : layerId;
      final nextLayerType = node['type'] is String
          ? node['type'] as String
          : layerType;

      return {
        for (final entry in node.entries)
          entry.key: _transformNode(
            entry.value,
            key: entry.key.toString(),
            layerId: nextLayerId,
            layerType: nextLayerType,
          ),
      };
    }

    if (node is List) {
      return [
        for (final value in node)
          _transformNode(
            value,
            key: key,
            layerId: layerId,
            layerType: layerType,
          ),
      ];
    }

    if (node is String) {
      return _transformColorValue(
        node,
        key: key,
        layerId: layerId,
        layerType: layerType,
      );
    }

    return node;
  }

  String _transformColorValue(
    String value, {
    String? key,
    String? layerId,
    String? layerType,
  }) {
    final color = _parseColor(value);
    if (color == null) {
      return value;
    }

    final transformedColor = _transformColor(
      color,
      key: key,
      layerId: layerId,
      layerType: layerType,
    );

    return _toCssColor(transformedColor);
  }

  Color _transformColor(
    Color color, {
    String? key,
    String? layerId,
    String? layerType,
  }) {
    final normalizedKey = key ?? '';
    final normalizedLayerId = layerId?.toLowerCase() ?? '';
    final hsl = HSLColor.fromColor(color);

    if (normalizedKey == 'background-color') {
      return _colorFromHsl(
        hsl.withSaturation(hsl.saturation.clamp(0.0, 0.05)).withLightness(0.02),
        alpha: _alphaInt(color),
      );
    }

    if (normalizedKey.contains('halo')) {
      return Color.fromARGB(_alphaInt(color), 4, 7, 5);
    }

    if (normalizedKey == 'text-color' || normalizedKey == 'icon-color') {
      final textSaturation = (hsl.saturation * 0.28).clamp(0.0, 0.18);
      final textLightness = (0.76 + (hsl.lightness * 0.14)).clamp(0.74, 0.9);
      return _colorFromHsl(
        hsl.withSaturation(textSaturation).withLightness(textLightness),
        alpha: _alphaInt(color),
      );
    }

    final isWaterLayer =
        normalizedLayerId.contains('water') ||
        normalizedLayerId.contains('waterway') ||
        (hsl.hue >= 170 && hsl.hue <= 255 && hsl.saturation > 0.16);
    if (isWaterLayer) {
      final waterSaturation = (hsl.saturation * 0.72 + 0.06).clamp(0.12, 0.42);
      final waterLightness = (0.16 + hsl.lightness * 0.14).clamp(0.14, 0.28);
      return _colorFromHsl(
        hsl.withSaturation(waterSaturation).withLightness(waterLightness),
        alpha: _alphaInt(color),
      );
    }

    final isSymbolLayer = layerType == 'symbol';
    final baseSaturation = isSymbolLayer
        ? (hsl.saturation * 0.4).clamp(0.0, 0.2)
        : (hsl.saturation * 0.5).clamp(0.02, 0.32);
    final baseLightness = hsl.saturation < 0.08
        ? (0.07 + (1 - hsl.lightness) * 0.12).clamp(0.05, 0.2)
        : (0.08 + (1 - hsl.lightness) * 0.18).clamp(0.06, 0.24);

    return _colorFromHsl(
      hsl.withSaturation(baseSaturation).withLightness(baseLightness),
      alpha: _alphaInt(color),
    );
  }

  Color? _parseColor(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.startsWith('#')) {
      return _parseHexColor(trimmedValue);
    }

    final rgbMatch = RegExp(
      r'^rgba?\(\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*(?:,\s*(\d*(?:\.\d+)?)\s*)?\)$',
      caseSensitive: false,
    ).firstMatch(trimmedValue);
    if (rgbMatch != null) {
      return Color.fromRGBO(
        rgbMatch.group(1)!.contains('.')
            ? double.parse(rgbMatch.group(1)!).round().clamp(0, 255)
            : int.parse(rgbMatch.group(1)!).clamp(0, 255),
        rgbMatch.group(2)!.contains('.')
            ? double.parse(rgbMatch.group(2)!).round().clamp(0, 255)
            : int.parse(rgbMatch.group(2)!).clamp(0, 255),
        rgbMatch.group(3)!.contains('.')
            ? double.parse(rgbMatch.group(3)!).round().clamp(0, 255)
            : int.parse(rgbMatch.group(3)!).clamp(0, 255),
        double.tryParse(rgbMatch.group(4) ?? '1')?.clamp(0.0, 1.0) ?? 1,
      );
    }

    final hslMatch = RegExp(
      r'^hsla?\(\s*(-?\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)%\s*,\s*(\d+(?:\.\d+)?)%\s*(?:,\s*(\d*(?:\.\d+)?)\s*)?\)$',
      caseSensitive: false,
    ).firstMatch(trimmedValue);
    if (hslMatch != null) {
      return HSLColor.fromAHSL(
        double.tryParse(hslMatch.group(4) ?? '1')?.clamp(0.0, 1.0) ?? 1,
        double.parse(hslMatch.group(1)!) % 360,
        (double.parse(hslMatch.group(2)!) / 100).clamp(0.0, 1.0),
        (double.parse(hslMatch.group(3)!) / 100).clamp(0.0, 1.0),
      ).toColor();
    }

    return null;
  }

  Color? _parseHexColor(String value) {
    final hex = value.substring(1);
    if (hex.length == 3) {
      final red = '${hex[0]}${hex[0]}';
      final green = '${hex[1]}${hex[1]}';
      final blue = '${hex[2]}${hex[2]}';
      return Color(int.parse('FF$red$green$blue', radix: 16));
    }

    if (hex.length == 4) {
      final red = '${hex[0]}${hex[0]}';
      final green = '${hex[1]}${hex[1]}';
      final blue = '${hex[2]}${hex[2]}';
      final alpha = '${hex[3]}${hex[3]}';
      return Color(int.parse('$alpha$red$green$blue', radix: 16));
    }

    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }

    if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }

    return null;
  }

  Color _colorFromHsl(HSLColor color, {required int alpha}) {
    final rgbColor = color.toColor();
    return Color.fromARGB(
      alpha,
      _channelInt(rgbColor.r),
      _channelInt(rgbColor.g),
      _channelInt(rgbColor.b),
    );
  }

  String _toCssColor(Color color) {
    final alpha = _alphaInt(color);
    final red = _channelInt(color.r);
    final green = _channelInt(color.g);
    final blue = _channelInt(color.b);

    if (alpha == 255) {
      final redHex = red.toRadixString(16).padLeft(2, '0');
      final greenHex = green.toRadixString(16).padLeft(2, '0');
      final blueHex = blue.toRadixString(16).padLeft(2, '0');
      return '#$redHex$greenHex$blueHex';
    }

    final opacity = (alpha / 255).toStringAsFixed(3);
    final normalizedOpacity = opacity
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
    return 'rgba($red, $green, $blue, $normalizedOpacity)';
  }

  int _alphaInt(Color color) => _channelInt(color.a);

  int _channelInt(double channel) => (channel * 255).round().clamp(0, 255);
}
