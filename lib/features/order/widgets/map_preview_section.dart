import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wefrh_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();

    if (widget.showMap) {
      _initializeMap();
    }
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _createMarkersAndRoute();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _createMarkersAndRoute() async {
    if (_currentPosition == null) return;

    double destLat = double.parse(widget.latitude);
    double destLng = double.parse(widget.longitude);
    print(
        ' destLat = $destLat , destLng = $destLng , _currentPosition.latitude = ${_currentPosition!.latitude} , _currentPosition!.longitude = ${_currentPosition!.longitude} ');

    // إضافة العلامات
    _markers = {
      Marker(
        markerId: const MarkerId('current_location'),
        position:
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        infoWindow: InfoWindow(title: 'current_location'.tr),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(destLat, destLng),
        infoWindow: InfoWindow(title: 'destination'.tr),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    // الحصول على المسار الحقيقي من Google Directions API
    List<LatLng> routePoints = await _getDirectionsRoute(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          LatLng(destLat, destLng),
        ) ??
        [
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          LatLng(destLat, destLng),
        ];

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: routePoints,
        color: Colors.blue,
        width: 5,
        patterns: [PatternItem.dash(15), PatternItem.gap(10)],
      ),
    };

    setState(() {});
  }

  // دالة للحصول على المسار الحقيقي
  Future<List<LatLng>?> _getDirectionsRoute(
      LatLng origin, LatLng destination) async {
    try {
      // للآن، سنعيد خط مستقيم مع نقاط إضافية لمحاكاة المسار
      return _generateCurvedRoute(origin, destination);
    } catch (e) {
      debugPrint('Error getting directions: $e');
      return null;
    }
  }

  // إنشاء مسار منحني بسيط (محاكاة للمسار الحقيقي)
  List<LatLng> _generateCurvedRoute(LatLng start, LatLng end) {
    List<LatLng> points = [];
    int segments = 10;

    for (int i = 0; i <= segments; i++) {
      double ratio = i / segments;
      double lat = start.latitude + (end.latitude - start.latitude) * ratio;
      double lng = start.longitude + (end.longitude - start.longitude) * ratio;

      // إضافة انحناء بسيط لمحاكاة الطريق الطبيعي
      double curve = 0.002 * (4 * ratio * (1 - ratio)); // منحنى بسيط
      lat += curve;

      points.add(LatLng(lat, lng));
    }

    return points;
  }

  Future<void> _centerOnCurrentLocation() async {
    if (_currentPosition != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          17, // زوم أقرب للموقع الحالي
        ),
      );
    }
  }

  Future<void> _fitBounds() async {
    if (_currentPosition == null || _mapController == null) return;

    double destLat = double.parse(widget.latitude);
    double destLng = double.parse(widget.longitude);

    LatLng start =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    LatLng end = LatLng(destLat, destLng);

    // حساب المسافة بين النقطتين
    double distance = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );

    // حساب الحدود (bounds) للنقطتين
    double minLat =
        start.latitude < end.latitude ? start.latitude : end.latitude;
    double maxLat =
        start.latitude > end.latitude ? start.latitude : end.latitude;
    double minLng =
        start.longitude < end.longitude ? start.longitude : end.longitude;
    double maxLng =
        start.longitude > end.longitude ? start.longitude : end.longitude;

    double latPadding, lngPadding;

    if (distance < 200) {
      // مسافات قصيرة جداً - padding قليل جداً
      latPadding = (maxLat - minLat) * 0.15 + 0.001;
      lngPadding = (maxLng - minLng) * 0.15 + 0.001;
    } else if (distance < 1000) {
      // مسافات قصيرة - padding قليل
      latPadding = (maxLat - minLat) * 0.2 + 0.002;
      lngPadding = (maxLng - minLng) * 0.2 + 0.002;
    } else if (distance < 3000) {
      // مسافات متوسطة - padding معتدل
      latPadding = (maxLat - minLat) * 0.25 + 0.003;
      lngPadding = (maxLng - minLng) * 0.25 + 0.003;
    } else {
      // مسافات طويلة - padding عادي
      latPadding = (maxLat - minLat) * 0.3 + 0.005;
      lngPadding = (maxLng - minLng) * 0.3 + 0.005;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat - latPadding, minLng - lngPadding),
      northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
    );

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        bounds,
        50.0, 
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        double currentZoom = await _mapController!.getZoomLevel();

        double targetZoom;
        if (distance < 100) {
          targetZoom = 18; 
        } else if (distance < 300) {
          targetZoom = 17; 
        } else if (distance < 500) {
          targetZoom = 16;
        } else if (distance < 1000) {
          targetZoom = 15;
        } else if (distance < 2000) {
          targetZoom = 14;
        } else if (distance < 3000) {
          targetZoom = 13;
        } else if (distance < 5000) {
          targetZoom = 12;
        } else if (distance < 8000) {
          targetZoom = 11;
        } else if (distance < 15000) {
          targetZoom = 10;
        } else {
          targetZoom = 9; 
        }

        // التحقق من أن الزوم المطلوب مناسب (تساهل أقل في التغيير)
        if (currentZoom > targetZoom + 1.5 || currentZoom < targetZoom - 1.5) {
          await _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(
                (start.latitude + end.latitude) / 2,
                (start.longitude + end.longitude) / 2,
              ),
              targetZoom,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error adjusting zoom: $e');
      }
    });
  }

  Future<void> _openGoogleMaps() async {
    String url =
        'https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}&mode=d';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBar('${'could_not_launch'.tr} $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.showMap
        ? Container(
            margin: EdgeInsets.only(bottom: Dimensions.h16),
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.r16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.r16),
              child: Stack(
                children: [
                  // الخريطة الحقيقية
                  _isLoadingLocation
                      ? Center(
                          child: Container(
                            color: Theme.of(context).shadowColor,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                  ),
                                  SizedBox(
                                      height: Dimensions.h16),
                                  Text(
                                    'locating'.tr,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : _currentPosition == null
                          ? Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      ManagerAssets.mapPlaceholderImage),
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
                              ),
                            )
                          : GoogleMap(
                              onMapCreated: (GoogleMapController controller) {
                                _mapController = controller;
                                Future.delayed(
                                    const Duration(milliseconds: 300), () {
                                  _fitBounds();
                                });
                              },
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  (_currentPosition!.latitude +
                                          double.parse(widget.latitude)) /
                                      2,
                                  (_currentPosition!.longitude +
                                          double.parse(widget.longitude)) /
                                      2,
                                ),
                                zoom: 15, 
                              ),
                              markers: _markers,
                              polylines: _polylines,
                              mapType: MapType.normal,
                              myLocationEnabled: false,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                              zoomGesturesEnabled: true,
                              scrollGesturesEnabled: true,
                              tiltGesturesEnabled: true,
                              rotateGesturesEnabled: true,
                              // إضافة padding للخريطة لتجنب تداخل الأزرار
                              padding:
                                  EdgeInsets.only(bottom: 60, right: 10),

                              gestureRecognizers: <Factory<
                                  OneSequenceGestureRecognizer>>{
                                Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer(),
                                ),
                              },
                            ),

                  // الأزرار
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Row(
                      children: [
                        Container(
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
                            icon: SvgPicture.asset(
                              ManagerAssets.myLocationIcon,
                              height: 20,
                              width: 20,
                            ),
                            onPressed: _currentPosition != null
                                ? _centerOnCurrentLocation
                                : null,
                          ),
                        ),
                        SizedBox(width: 8),
                        // زر فتح في الخريطة الكاملة
                        Container(
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
                            icon: SvgPicture.asset(
                              ManagerAssets.openInFullIcon,
                              height: 20,
                              width: 20,
                            ),
                            onPressed: _openGoogleMaps,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'approx_path'.tr,
                        style: TextStyle(
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
          )
        : const SizedBox.shrink();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
