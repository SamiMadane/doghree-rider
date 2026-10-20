import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;
import 'package:wefrh_rider/util/manager_assets.dart';

import 'map_config.dart';
import 'map_safety.dart';

class DoghreeMap extends StatefulWidget {
  final DoghreeMapConfig config;
  final MapController? controller;
  final LatLng? initialCenter;
  final double? initialZoom;
  final List<Widget> children;
  final void Function(TapPosition, LatLng)? onTap;
  final void Function(MapEvent)? onMapEvent;
  final VoidCallback? onMapReady;

  const DoghreeMap({
    super.key,
    required this.config,
    this.controller,
    this.initialCenter,
    this.initialZoom,
    this.children = const [],
    this.onTap,
    this.onMapEvent,
    this.onMapReady,
  });

  @override
  State<DoghreeMap> createState() => _DoghreeMapState();
}

class _DoghreeMapState extends State<DoghreeMap> {
  // يُحمَّل مرة واحدة لكل التطبيق
  static Future<_Vector?>? _vectorFuture;

  @override
  void initState() {
    super.initState();
    _vectorFuture ??= _loadVector(widget.config.pmtilesUrl);
  }

  static Future<_Vector?> _loadVector(String? url) async {
    if (url == null) return null;
    try {
      final provider = await PmTilesVectorTileProvider.fromSource(url);
      final styleJson =
          await rootBundle.loadString(ManagerAssets.doghreeLight);
      final theme =
          vtr.ThemeReader().read(jsonDecode(styleJson) as Map<String, dynamic>);
      return _Vector(provider, theme);
    } catch (e) {
      debugPrint('Doghree map: PMTiles failed, using raster fallback: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Vector?>(
      future: _vectorFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final vector = snap.data;
        final base = vector != null
            ? VectorTileLayer(
                theme: vector.theme,
                tileProviders: TileProviders({'protomaps': vector.provider}),
                maximumZoom: 15,
                layerMode: VectorTileLayerMode.vector,
                maximumTileSubstitutionDifference: 3,
                memoryTileCacheMaxSize: 80,
                memoryTileDataCacheMaxSize: 80,
                fileCacheTtl: const Duration(days: 30),
              )
            : TileLayer(
                urlTemplate: widget.config.tilesUrl,
                subdomains: widget.config.subdomains,
                maxZoom: widget.config.maxZoom.toDouble(),
                userAgentPackageName:
                    'com.doghree.app', // ضع package name التطبيق
              );

        return FlutterMap(
          mapController: widget.controller,
          options: MapOptions(
            initialCenter:
                safeCentre(widget.initialCenter, widget.config.defaultCentre),
            initialZoom: widget.initialZoom ?? widget.config.defaultZoom,
            minZoom: 10,
            maxZoom: 19,
            onMapReady: widget.onMapReady,

            // يمنع المستخدم من سحب الخريطة خارج غزة
            cameraConstraint: CameraConstraint.contain(bounds: gazaBounds),
            onTap: widget.onTap,
            onMapEvent: widget.onMapEvent,
          ),
          children: [
            base,
            ...widget.children,
            // إلزامي قانونياً (رخصة ODbL) — لا تحذفه
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors')
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Vector {
  final VectorTileProvider provider;
  final vtr.Theme theme;
  _Vector(this.provider, this.theme);
}
