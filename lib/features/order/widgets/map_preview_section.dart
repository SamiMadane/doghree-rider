import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/doghree_map/doghree_map.dart';
import 'package:doghree_rider/doghree_map/map_safety.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';

/// واجهة فقط. المنطق كله في OrderController (initOrderMap).
class MapPreviewSection extends StatefulWidget {
  final String latitude;
  final String longitude;
  final bool showMap;

  const MapPreviewSection({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.showMap,
  });

  @override
  State<MapPreviewSection> createState() => _MapPreviewSectionState();
}

class _MapPreviewSectionState extends State<MapPreviewSection> {
  static const String _id = 'order_map';
  final MapController _mapController = MapController();
  final OrderController _c = Get.find<OrderController>();
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.showMap) _load();
  }

  @override
  void didUpdateWidget(covariant MapPreviewSection old) {
    super.didUpdateWidget(old);
    final changed = old.latitude != widget.latitude ||
        old.longitude != widget.longitude ||
        old.showMap != widget.showMap;
    if (widget.showMap && changed) _load();
  }

  Future<void> _load() async {
    await _c.initOrderMap(latitude: widget.latitude, longitude: widget.longitude);
    if (mounted) _fitBounds();
  }

  void _centerOnCurrentLocation() {
    final p = _c.mapMyPoint;
    if (p != null && _mapReady) _mapController.move(p, 17);
  }

  void _fitBounds() {
    if (!_mapReady) return;
    // بعد انتهاء الإطار الحالي حتى يكون حجم الخريطة نهائياً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pts = usablePoints(
        _c.mapRoute.length >= 2
            ? _c.mapRoute
            : [
                if (_c.mapMyPoint != null) _c.mapMyPoint!,
                if (_c.mapDestPoint != null) _c.mapDestPoint!,
              ],
      );
      if (pts.length >= 2) {
        _mapController.fitCamera(CameraFit.coordinates(
          coordinates: pts,
          padding: const EdgeInsets.fromLTRB(48, 56, 48, 48),
          maxZoom: 17,
        ));
      } else if (pts.length == 1) {
        _mapController.move(pts.first, 16);
      }
    });
  }

  Future<void> _openGoogleMaps() async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}&mode=d';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBar('${'could_not_launch'.tr} $url');
    }
  }

  Widget _placeholder() => Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ManagerAssets.mapPlaceholderImage),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
      );

  Widget _buildMap(OrderController c) {
    final config = Get.find<SplashController>().doghreeMapConfig;
    final dest = c.mapDestPoint;
    if (config == null || dest == null) return _placeholder();

    return DoghreeMap(
      config: config,
      controller: _mapController,
      initialCenter: dest,
      initialZoom: 15,
      onMapReady: () {
        _mapReady = true;
        _fitBounds();
      },
      children: [
        if (c.mapRoute.length >= 2)
          PolylineLayer(polylines: [
            Polyline(
              points: c.mapRoute,
              strokeWidth: 5,
              color: c.mapRouteIsApprox ? Colors.orange : Colors.blue,
              borderStrokeWidth: 2,
              borderColor: Colors.white,
            ),
          ]),
        MarkerLayer(markers: [
          if (c.mapMyPoint != null)
            Marker(
              point: c.mapMyPoint!,
              width: 22,
              height: 22,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
              ),
            ),
          Marker(
            point: dest,
            width: 40,
            height: 40,
            alignment: Alignment.topCenter, // رأس الدبوس على النقطة
            child: const Icon(Icons.location_on, size: 40, color: Colors.red),
          ),
        ]),
      ],
    );
  }

  Widget _roundButton({required String icon, required VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: SvgPicture.asset(icon, height: 20, width: 20),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showMap) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.h16),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.r16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.r16),
        child: GetBuilder<OrderController>(
          id: _id,
          builder: (c) => Stack(
            children: [
              c.mapIsLoadingLocation
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          SizedBox(height: Dimensions.h16),
                          Text(
                            'locating'.tr,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildMap(c),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    _roundButton(
                      icon: ManagerAssets.myLocationIcon,
                      onPressed: c.mapMyPoint != null ? _centerOnCurrentLocation : null,
                    ),
                    const SizedBox(width: 8),
                    _roundButton(
                      icon: ManagerAssets.openInFullIcon,
                      onPressed: c.mapDestPoint != null ? _openGoogleMaps : null,
                    ),
                  ],
                ),
              ),
              if (c.mapRouteIsApprox && c.mapRoute.isNotEmpty)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'approx_path'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    _c.clearOrderMap();
    super.dispose();
  }
}