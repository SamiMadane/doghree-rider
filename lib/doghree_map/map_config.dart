// إعدادات الخريطة كما يرسلها السيرفر في GET /api/v1/config
// لا تكتب رابط الخريطة في الكود أبداً — اقرأه من هنا.

import 'package:latlong2/latlong.dart';

class DoghreeMapConfig {
  /// رابط ملف الخريطة (PMTiles) للمسار الاحتياطي (flutter_map).
  final String? pmtilesUrl;
  final String flavor;

  /// رابط ستايل MapLibre الجاهز من السيرفر (المسار الأساسي الجديد).
  final String? styleLight;
  final String? styleDark;

  /// "maplibre" = يطلب السيرفر الرسم بـ maplibre_gl
  final String? mapRenderer;

  /// الخريطة البديلة: قالب {z}/{x}/{y}.png
  final String tilesUrl;
  final List<String> subdomains;
  final int maxZoom;

  /// المركز الذي تفتح عليه الخريطة إذا لم يكن عندك موقع صحيح.
  final LatLng defaultCentre;
  final double defaultZoom;

  /// بصمة بيانات الأماكن؛ أرسلها ?v= مع /api/v1/places حتى يُخزَّن الملف سنة.
  final String placesVersion;

  const DoghreeMapConfig({
    required this.pmtilesUrl,
    required this.flavor,
    required this.tilesUrl,
    required this.subdomains,
    required this.maxZoom,
    required this.defaultCentre,
    required this.defaultZoom,
    required this.placesVersion,
    this.styleLight,
    this.styleDark,
    this.mapRenderer,
  });

  /// هل نرسم بـ maplibre_gl؟ (يوجد ستايل، والسيرفر لم يطلب غير ذلك)
  bool get useMapLibre =>
      styleLight != null &&
      styleLight!.isNotEmpty &&
      (mapRenderer == null || mapRenderer == 'maplibre');

  /// [json] هو جسم الرد الكامل من /api/v1/config
  factory DoghreeMapConfig.fromConfigJson(Map<String, dynamic> json) {
    final pm = json['map_pmtiles'] as Map<String, dynamic>?;
    final tiles = (json['map_tiles'] as Map<String, dynamic>?) ?? const {};
    final centre =
        (json['map_default_centre'] as Map<String, dynamic>?) ?? const {};

    double toD(Object? v, double fallback) =>
        v == null ? fallback : double.tryParse(v.toString()) ?? fallback;

    String? nonEmpty(Object? v) {
      final s = v?.toString();
      return (s == null || s.isEmpty) ? null : s;
    }

    return DoghreeMapConfig(
      pmtilesUrl: nonEmpty(pm?['url']),
      flavor: pm?['flavor']?.toString() ?? 'light',
      styleLight: nonEmpty(pm?['style_light']),
      styleDark: nonEmpty(pm?['style_dark']),
      mapRenderer: nonEmpty(json['map_renderer']),
      tilesUrl: tiles['url']?.toString() ??
          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      subdomains: ((tiles['subdomains'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      maxZoom: int.tryParse('${tiles['max_zoom']}') ?? 19,
      // map_default_centre أدق من default_location (الأخير قد يكون إعداداً قديماً)
      defaultCentre: LatLng(
        toD(centre['lat'], 31.5017),
        toD(centre['lng'], 34.4668),
      ),
      defaultZoom: toD(centre['zoom'], 12),
      placesVersion: json['places_version']?.toString() ?? '',
    );
  }
}