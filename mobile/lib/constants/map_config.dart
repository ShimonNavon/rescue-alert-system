import 'asset_paths.dart';

class MapConfig {
  static const double defaultZoom = 14;
  static const String sourceIdPrefix = 'source-';
  static const String layerIdPrefix = 'layer-';
  static const String imageIdPrefix = 'image-';
  static const int thumbRadius = 50;

  static const String alertIconName = 'alertIconName';
  static const String terrainIconName = 'Terrain';
  static const String deviceIconName = 'deviceIconName';

  static List<String> allLayerIds = EMapDataCategory.values
      .map((category) => category.categoryLayerIds)
      .expand((element) => element)
      .toList();
}

enum EMapStyle {
  standard,
  streets,
  outdoors,
  satellite,
  satelliteStreets,
  israelHiking,
}

extension EMapStyleExtension on EMapStyle {
  static const String _mapboxStyleUrl = 'mapbox://styles/mapbox/';

  String get mapPath {
    switch (this) {
      case EMapStyle.standard:
        return AssetPaths.mapStandard;

      case EMapStyle.streets:
        return AssetPaths.mapStandard3d;

      case EMapStyle.outdoors:
        return AssetPaths.mapTopography;

      case EMapStyle.satellite:
        return AssetPaths.mapSattelite;

      case EMapStyle.satelliteStreets:
        return AssetPaths.mapSatteliteStreet;

      case EMapStyle.israelHiking:
        return AssetPaths.mapStandard;
    }
  }

  String get id {
    switch (this) {
      case EMapStyle.standard:
        return 'standard';
      case EMapStyle.streets:
        return 'streets-v12';
      case EMapStyle.outdoors:
        return 'outdoors-v12';
      case EMapStyle.satellite:
        return 'satellite-v9';
      case EMapStyle.satelliteStreets:
        return 'satellite-streets-v12';
      case EMapStyle.israelHiking:
        return '';
    }
  }

  String get name {
    switch (this) {
      case EMapStyle.standard:
        return 'Standard 3D';
      case EMapStyle.streets:
        return 'Streets';
      case EMapStyle.outdoors:
        return 'Outdoors';
      case EMapStyle.satellite:
        return 'Satellite';
      case EMapStyle.satelliteStreets:
        return '`Satellite Streets`';
      case EMapStyle.israelHiking:
        return 'Israeli Hiking';
    }
  }

  String get url {
    return _mapboxStyleUrl + id;
  }
}

enum EMapDataCategory {
  terrain,
  device,
  alert,
  pole,
  site;

  static EMapDataCategory fromString(String type) {
    if (type.contains('@_Terrain_@')) {
      return EMapDataCategory.terrain;
    } else if (type.contains('@_Device_@')) {
      return EMapDataCategory.device;
    } else if (type.contains('@_Alert_@')) {
      return EMapDataCategory.alert;
    } else if (type.contains('@_Site_@')) {
      return EMapDataCategory.site;
    } else if (type.contains('@_Pole_@')) {
      return EMapDataCategory.pole;
    } else {
      return EMapDataCategory.terrain;
    }
  }
}

extension ESourceIdExtension on EMapDataCategory {
  String get sourceId => MapConfig.sourceIdPrefix + name;

  String toCategoryString() {
    switch (this) {
      case EMapDataCategory.terrain:
        return 'Terrain';
      case EMapDataCategory.device:
        return 'Device';
      case EMapDataCategory.alert:
        return 'Alert';
      case EMapDataCategory.site:
        return 'Site';
      case EMapDataCategory.pole:
        return 'Pole';
    }
  }

  String layerName(ELayerTypes layerType) {
    return '${MapConfig.layerIdPrefix}$name-${layerType.name}';
  }

  List<LayerType> get layerTypes {
    switch (this) {
      case EMapDataCategory.pole:
      case EMapDataCategory.site:
      case EMapDataCategory.terrain:
        return [
          LayerType(
            id: layerName(ELayerTypes.symbol),
            type: ELayerTypes.symbol,
            category: this,
          ),
          LayerType(
            id: layerName(ELayerTypes.line),
            type: ELayerTypes.line,
            category: this,
          ),
          LayerType(
            id: layerName(ELayerTypes.fill),
            type: ELayerTypes.fill,
            category: this,
          )
        ];
      case EMapDataCategory.device:
        return [
          LayerType(
            id: layerName(ELayerTypes.symbol),
            type: ELayerTypes.symbol,
            category: this,
          ),
        ];
      case EMapDataCategory.alert:
        return [
          LayerType(
            id: layerName(ELayerTypes.symbol),
            type: ELayerTypes.symbol,
            category: this,
          ),
        ];
    }
  }

  List<String> get categoryLayerIds {
    return layerTypes.map((layer) => layer.id).toList();
  }
}

enum ELayerTypes {
  symbol,
  line,
  fill,
  circle,
}

extension ELayerTypesExtension on ELayerTypes {
  int get featureTypeId {
    switch (this) {
      case ELayerTypes.symbol:
        return 1;
      case ELayerTypes.line:
        return 2;
      case ELayerTypes.fill:
        return 3;
      case ELayerTypes.circle:
        return 4;
    }
  }

  String get featureTypeName {
    switch (this) {
      case ELayerTypes.symbol:
        return 'Point';
      case ELayerTypes.line:
        return 'LineString';
      case ELayerTypes.fill:
        return 'Polygon';
      case ELayerTypes.circle:
        return 'Circle';
    }
  }
}

enum ELayerDetailedTypes {
  symbolDevice,
  symbolTerrain,
  symbolAlert,
  lineDevice,
  lineTerrain,
  lineAlert,
  fillDevice,
  fillTerrain,
  fillAlert,
  circle;

  String layerName() => name;
}

class LayerType {
  final String id;
  final ELayerTypes type;
  final EMapDataCategory category;

  LayerType({
    required this.id,
    required this.type,
    required this.category,
  });
}
