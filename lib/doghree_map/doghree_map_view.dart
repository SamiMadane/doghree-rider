// طبقة وسيطة بين الشاشات ومكتبات الخرائط.
// الشاشة تعطيها: ماركرات + خط مسار + أوامر كاميرا (عبر DoghreeMapHandle).
// تختار هي الرسّام:
//   1) maplibre_gl  (الأساسي) إذا أعطى السيرفر style_light
//   2) flutter_map  (الاحتياطي) = DoghreeMap القديم، إذا لا يوجد ستايل
//      أو تأخر تحميل الستايل أكثر من 15 ثانية.
// المسار: lib/doghree_map/doghree_map_view.dart

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;

import 'doghree_map.dart';
import 'map_config.dart';
import 'map_safety.dart';

/// ماركر على الخريطة.
/// [asset] = صورة PNG؛ null = نقطة زرقاء (موقع المندوب).
class DoghreeMarker {
  final String id;
  final LatLng point;
  final String? asset;
  final double size; // بالـ dp
  final bool anchorBottom; // true: رأس الدبوس (أسفل الصورة) على النقطة

  const DoghreeMarker({
    required this.id,
    required this.point,
    this.asset,
    this.size = 40,
    this.anchorBottom = true,
  });

  const DoghreeMarker.dot({required this.id, required this.point})
      : asset = null,
        size = 22,
        anchorBottom = false;

  @override
  bool operator ==(Object other) =>
      other is DoghreeMarker &&
      other.id == id &&
      other.point == point &&
      other.asset == asset &&
      other.size == size &&
      other.anchorBottom == anchorBottom;

  @override
  int get hashCode => Object.hash(id, point, asset, size, anchorBottom);
}

/// أوامر الكاميرا التي تستعملها الشاشة (لا تعرف أي مكتبة تحتها).
abstract class DoghreeMapHandle {
  Future<void> fitPoints(
    List<LatLng> points, {
    EdgeInsets padding = const EdgeInsets.all(48),
    double maxZoom = 17,
  });
  Future<void> moveTo(LatLng point, {double zoom = 16});
}

class DoghreeMapView extends StatefulWidget {
  final DoghreeMapConfig config;
  final LatLng? initialCenter;
  final double initialZoom;

  /// ميلان الكاميرا (0 = مسطحة). الدليل يوصي 30–45 لإظهار المباني 3D.
  final double tilt;

  /// false = الخريطة للعرض فقط.
  final bool interactive;

  /// true = الخريطة تأخذ كل السحب فوقها (لا تتمرّر الصفحة وإصبعك على الخريطة).
  /// false (الافتراضي) = نفس سلوك المكتبة؛ فصل السكرول عن الخريطة تتحكم فيه أنت.
  final bool captureGestures;

  final List<DoghreeMarker> markers;
  final List<LatLng> routePoints;
  final Color routeColor;

  /// يُستدعى عندما تصبح الخريطة جاهزة لأوامر الكاميرا.
  final void Function(DoghreeMapHandle handle)? onReady;

  const DoghreeMapView({
    super.key,
    required this.config,
    this.initialCenter,
    this.initialZoom = 15,
    this.tilt = 0,
    this.interactive = true,
    this.captureGestures = false,
    this.markers = const [],
    this.routePoints = const [],
    this.routeColor = Colors.blue,
    this.onReady,
  });

  @override
  State<DoghreeMapView> createState() => _DoghreeMapViewState();
}

class _DoghreeMapViewState extends State<DoghreeMapView> {
  bool _fallback = false;
  bool _styleLoaded = false;
  Timer? _timeout;

  bool get _useMapLibre => !_fallback && widget.config.useMapLibre;

  @override
  void initState() {
    super.initState();
    if (_useMapLibre) {
      // إذا لم يُحمَّل الستايل خلال 15 ثانية ننزل للخريطة الاحتياطية
      _timeout = Timer(const Duration(seconds: 15), () {
        if (mounted && !_styleLoaded) {
          debugPrint('Doghree map: style timeout, using flutter_map fallback');
          setState(() => _fallback = true);
        }
      });
    }
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final centre =
        safeCentre(widget.initialCenter, widget.config.defaultCentre);

    if (!_useMapLibre) {
      return _FlutterMapImpl(
        config: widget.config,
        centre: centre,
        zoom: widget.initialZoom,
        markers: widget.markers,
        routePoints: widget.routePoints,
        routeColor: widget.routeColor,
        onReady: widget.onReady,
      );
    }

    final dark = Theme.of(context).brightness == Brightness.dark;
    final style = (dark ? widget.config.styleDark : null) ??
        widget.config.styleLight!;

    return _MapLibreImpl(
      key: ValueKey(style),
      styleUrl: style,
      centre: centre,
      zoom: widget.initialZoom,
      tilt: widget.tilt,
      interactive: widget.interactive,
      captureGestures: widget.captureGestures,
      markers: widget.markers,
      routePoints: widget.routePoints,
      routeColor: widget.routeColor,
      onStyleLoaded: () {
        _styleLoaded = true;
        _timeout?.cancel();
      },
      onReady: widget.onReady,
    );
  }
}

// ───────────────────────── maplibre_gl ─────────────────────────

ml.LatLng _ml(LatLng p) => ml.LatLng(p.latitude, p.longitude);

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

class _MapLibreImpl extends StatefulWidget {
  final String styleUrl;
  final LatLng centre;
  final double zoom;
  final double tilt;
  final bool interactive;
  final bool captureGestures;
  final List<DoghreeMarker> markers;
  final List<LatLng> routePoints;
  final Color routeColor;
  final VoidCallback onStyleLoaded;
  final void Function(DoghreeMapHandle handle)? onReady;

  const _MapLibreImpl({
    super.key,
    required this.styleUrl,
    required this.centre,
    required this.zoom,
    required this.tilt,
    required this.interactive,
    required this.captureGestures,
    required this.markers,
    required this.routePoints,
    required this.routeColor,
    required this.onStyleLoaded,
    required this.onReady,
  });

  @override
  State<_MapLibreImpl> createState() => _MapLibreImplState();
}

class _MapLibreImplState extends State<_MapLibreImpl>
    implements DoghreeMapHandle {
  // حدود قطاع غزة: يمنع سحب الخريطة بعيداً عنه
  static final ml.LatLngBounds _gaza = ml.LatLngBounds(
    southwest: ml.LatLng(31.19, 34.18),
    northeast: ml.LatLng(31.62, 34.60),
  );

  ml.MapLibreMapController? _c;
  bool _styleReady = false;
  bool _syncing = false;
  bool _pending = false;
  final Set<String> _registered = {};
  final Map<String, double> _imageWidth = {};

  @override
  void didUpdateWidget(covariant _MapLibreImpl old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.markers, widget.markers) ||
        !listEquals(old.routePoints, widget.routePoints) ||
        old.routeColor != widget.routeColor) {
      _sync();
    }
  }

  Future<void> _onStyleLoaded() async {
    _styleReady = true;
    _registered.clear(); // الصور تضيع عند تحميل ستايل جديد
    widget.onStyleLoaded();
    try {
      await _c?.setSymbolIconAllowOverlap(true);
      await _c?.setSymbolIconIgnorePlacement(true);
    } catch (e) {
      debugPrint('Doghree map: symbol overlap setup failed: $e');
    }
    await _sync();
    if (mounted) widget.onReady?.call(this);
  }

  Future<void> _ensureImages() async {
    final c = _c;
    if (c == null) return;
    for (final m in widget.markers) {
      final a = m.asset;
      if (a == null || _registered.contains(a)) continue;
      final data = await rootBundle.load(a);
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _imageWidth[a] = frame.image.width.toDouble();
      frame.image.dispose();
      codec.dispose();
      await c.addImage(a, bytes);
      _registered.add(a);
    }
  }

  Future<void> _sync() async {
    final c = _c;
    if (c == null || !_styleReady || !mounted) return;
    if (_syncing) {
      _pending = true;
      return;
    }
    _syncing = true;
    try {
      final dpr = MediaQuery.of(context).devicePixelRatio;
      await _ensureImages();
      await c.clearLines();
      await c.clearSymbols();
      await c.clearCircles();

      if (widget.routePoints.length >= 2) {
        final geo = widget.routePoints.map(_ml).toList();
        // حدّ أبيض ثم الخط الملوّن فوقه
        await c.addLine(ml.LineOptions(
            geometry: geo,
            lineColor: '#FFFFFF',
            lineWidth: 9,
            lineJoin: 'round'));
        await c.addLine(ml.LineOptions(
            geometry: geo,
            lineColor: _hex(widget.routeColor),
            lineWidth: 5,
            lineJoin: 'round'));
      }

      for (final m in widget.markers) {
        if (m.asset == null) {
          await c.addCircle(ml.CircleOptions(
            geometry: _ml(m.point),
            circleRadius: 8,
            circleColor: '#2196F3',
            circleStrokeColor: '#FFFFFF',
            circleStrokeWidth: 3,
          ));
        } else {
          final w = _imageWidth[m.asset!] ?? 1;
          await c.addSymbol(ml.SymbolOptions(
            geometry: _ml(m.point),
            iconImage: m.asset,
            // حجم الصورة بالـ dp = m.size  (قيمة أولية، عدّلها على الجهاز إذا لزم)
            iconSize: m.size * dpr / w,
            iconAnchor: m.anchorBottom ? 'bottom' : 'center',
          ));
        }
      }
    } catch (e) {
      debugPrint('Doghree map: annotation sync failed: $e');
    } finally {
      _syncing = false;
      if (_pending) {
        _pending = false;
        _sync();
      }
    }
  }

  @override
  Future<void> fitPoints(
    List<LatLng> points, {
    EdgeInsets padding = const EdgeInsets.all(48),
    double maxZoom = 17,
  }) async {
    final c = _c;
    if (c == null || points.isEmpty) return;
    try {
      if (points.length == 1) {
        await c.animateCamera(
            ml.CameraUpdate.newLatLngZoom(_ml(points.first), maxZoom - 1));
        return;
      }
      double minLat = points.first.latitude, maxLat = minLat;
      double minLng = points.first.longitude, maxLng = minLng;
      for (final p in points) {
        if (p.latitude < minLat) minLat = p.latitude;
        if (p.latitude > maxLat) maxLat = p.latitude;
        if (p.longitude < minLng) minLng = p.longitude;
        if (p.longitude > maxLng) maxLng = p.longitude;
      }
      final bounds = ml.LatLngBounds(
        southwest: ml.LatLng(minLat, minLng),
        northeast: ml.LatLng(maxLat, maxLng),
      );
      await c.animateCamera(ml.CameraUpdate.newLatLngBounds(
        bounds,
        left: padding.left,
        top: padding.top,
        right: padding.right,
        bottom: padding.bottom,
      ));
      // نقطتان متقاربتان جداً: لا نزوّم أكثر من maxZoom
      final pos = await c.queryCameraPosition();
      if (pos != null && pos.zoom > maxZoom) {
        await c.animateCamera(ml.CameraUpdate.zoomTo(maxZoom));
      }
      // newLatLngBounds يصفّر الميلان؛ نعيده إن طُلب
      if (widget.tilt > 0) {
        await c.animateCamera(ml.CameraUpdate.tiltTo(widget.tilt));
      }
    } catch (e) {
      debugPrint('Doghree map: fitPoints failed: $e');
    }
  }

  @override
  Future<void> moveTo(LatLng point, {double zoom = 16}) async {
    try {
      await _c?.animateCamera(ml.CameraUpdate.newLatLngZoom(_ml(point), zoom));
    } catch (e) {
      debugPrint('Doghree map: moveTo failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ml.MapLibreMap(
      styleString: widget.styleUrl,
      initialCameraPosition: ml.CameraPosition(
        target: _ml(widget.centre),
        zoom: widget.zoom,
        tilt: widget.tilt,
      ),
      onMapCreated: (c) => _c = c,
      onStyleLoadedCallback: _onStyleLoaded,
      cameraTargetBounds: ml.CameraTargetBounds(_gaza),
      minMaxZoomPreference: const ml.MinMaxZoomPreference(10, 19),
      compassEnabled: false,
      rotateGesturesEnabled: widget.interactive,
      scrollGesturesEnabled: widget.interactive,
      zoomGesturesEnabled: widget.interactive,
      tiltGesturesEnabled: widget.interactive,
      gestureRecognizers: widget.captureGestures
          ? <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer()),
            }
          : null,
      // إلزامي قانونياً (ODbL): زر الحقوق يبقى ظاهراً
      attributionButtonPosition: ml.AttributionButtonPosition.bottomRight,
    );
  }
}

// ───────────────────────── flutter_map (احتياطي) ─────────────────────────

class _FlutterMapImpl extends StatefulWidget {
  final DoghreeMapConfig config;
  final LatLng centre;
  final double zoom;
  final List<DoghreeMarker> markers;
  final List<LatLng> routePoints;
  final Color routeColor;
  final void Function(DoghreeMapHandle handle)? onReady;

  const _FlutterMapImpl({
    required this.config,
    required this.centre,
    required this.zoom,
    required this.markers,
    required this.routePoints,
    required this.routeColor,
    required this.onReady,
  });

  @override
  State<_FlutterMapImpl> createState() => _FlutterMapImplState();
}

class _FlutterMapImplState extends State<_FlutterMapImpl>
    implements DoghreeMapHandle {
  final fm.MapController _mc = fm.MapController();
  bool _ready = false;

  @override
  void dispose() {
    _mc.dispose();
    super.dispose();
  }

  @override
  Future<void> fitPoints(
    List<LatLng> points, {
    EdgeInsets padding = const EdgeInsets.all(48),
    double maxZoom = 17,
  }) async {
    if (!_ready || points.isEmpty) return;
    if (points.length == 1) {
      _mc.move(points.first, maxZoom - 1);
      return;
    }
    _mc.fitCamera(fm.CameraFit.coordinates(
      coordinates: points,
      padding: padding,
      maxZoom: maxZoom,
    ));
  }

  @override
  Future<void> moveTo(LatLng point, {double zoom = 16}) async {
    if (_ready) _mc.move(point, zoom);
  }

  Widget _markerChild(DoghreeMarker m) {
    if (m.asset != null) return Image.asset(m.asset!);
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DoghreeMap(
      config: widget.config,
      controller: _mc,
      initialCenter: widget.centre,
      initialZoom: widget.zoom,
      onMapReady: () {
        _ready = true;
        widget.onReady?.call(this);
      },
      children: [
        if (widget.routePoints.length >= 2)
          fm.PolylineLayer(polylines: [
            fm.Polyline(
              points: widget.routePoints,
              strokeWidth: 5,
              color: widget.routeColor,
              borderStrokeWidth: 2,
              borderColor: Colors.white,
            ),
          ]),
        fm.MarkerLayer(markers: [
          for (final m in widget.markers)
            fm.Marker(
              point: m.point,
              width: m.size,
              height: m.size,
              alignment: m.anchorBottom ? Alignment.topCenter : Alignment.center,
              child: _markerChild(m),
            ),
        ]),
      ],
    );
  }
}