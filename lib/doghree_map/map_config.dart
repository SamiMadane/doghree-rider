// إعدادات الخريطة كما يرسلها السيرفر في GET /api/v1/config
// لا تكتب رابط الخريطة في الكود أبداً — اقرأه من هنا.

import 'package:latlong2/latlong.dart';

class DoghreeMapConfig {
  /// رابط ملف الخريطة (PMTiles). إذا كان null استخدم الخريطة البديلة (raster).
  final String? pmtilesUrl;
  final String flavor;

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
  });

  /// [json] هو جسم الرد الكامل من /api/v1/config
  factory DoghreeMapConfig.fromConfigJson(Map<String, dynamic> json) {
    final pm = json['map_pmtiles'] as Map<String, dynamic>?;
    final tiles = (json['map_tiles'] as Map<String, dynamic>?) ?? const {};
    final centre = (json['map_default_centre'] as Map<String, dynamic>?) ?? const {};

    double toD(Object? v, double fallback) =>
        v == null ? fallback : double.tryParse(v.toString()) ?? fallback;

    final pmUrl = pm?['url']?.toString();

    return DoghreeMapConfig(
      pmtilesUrl: (pmUrl == null || pmUrl.isEmpty) ? null : pmUrl,
      flavor: pm?['flavor']?.toString() ?? 'light',
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
