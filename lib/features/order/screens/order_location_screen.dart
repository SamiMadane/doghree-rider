import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/doghree_map/doghree_map.dart';
import 'package:doghree_rider/doghree_map/map_config.dart';
import 'package:doghree_rider/doghree_map/map_safety.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/widgets/location_card_widget.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/util/manager_assets.dart';

class OrderLocationScreen extends StatefulWidget {
  final OrderModel orderModel;
  final OrderController orderController;
  final int index;
  final Function onTap;
  const OrderLocationScreen({
    super.key,
    required this.orderModel,
    required this.orderController,
    required this.index,
    required this.onTap,
  });

  @override
  State<OrderLocationScreen> createState() => _OrderLocationScreenState();
}

class _OrderLocationScreenState extends State<OrderLocationScreen> {
  final MapController _controller = MapController();

  bool get _parcel => widget.orderModel.orderType == 'parcel';

  LatLng? get _deliveryP => parsePoint(
      widget.orderModel.deliveryAddress?.latitude,
      widget.orderModel.deliveryAddress?.longitude);

  // للطرد: المستلم، وللطلب العادي: المتجر
  LatLng? get _pickupP => _parcel
      ? parsePoint(widget.orderModel.receiverDetails?.latitude,
          widget.orderModel.receiverDetails?.longitude)
      : parsePoint(widget.orderModel.storeLat, widget.orderModel.storeLng);

  LatLng? get _riderP {
    final loc = Get.find<ProfileController>().recordLocationBody;
    return parsePoint(loc?.latitude, loc?.longitude);
  }

  void _fit() {
    final pts = usablePoints([
      if (_deliveryP != null) _deliveryP!,
      if (_pickupP != null) _pickupP!,
      if (_riderP != null) _riderP!,
    ]);
    if (pts.length >= 2) {
      _controller.fitCamera(CameraFit.coordinates(
        coordinates: pts,
        padding: const EdgeInsets.fromLTRB(48, 48, 48, 220), // مساحة للكارد
      ));
    } else if (pts.length == 1) {
      _controller.move(pts.first, 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    // إذا الـ config لسا ما وصل: {} بيعطي خريطة raster بالمركز الافتراضي
    final mapConfig = Get.find<SplashController>().doghreeMapConfig ??
        DoghreeMapConfig.fromConfigJson(const {});

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'order_location'.tr),
      body: SafeArea(
        child: Stack(children: [
          DoghreeMap(
            config: mapConfig,
            controller: _controller,
            initialCenter: _deliveryP, // null → مركز غزة تلقائيًا
            initialZoom: 14,
            onMapReady: _fit,
            children: [
              MarkerLayer(markers: [
                if (_deliveryP != null)
                  Marker(
                    point: _deliveryP!,
                    width: 40,
                    height: 40,
                    child: Image.asset(ManagerAssets.customerMarker),
                  ),
                if (_pickupP != null)
                  Marker(
                    point: _pickupP!,
                    width: 40,
                    height: 40,
                    child: Image.asset(_parcel
                        ? ManagerAssets.userMarker
                        : ManagerAssets.restaurantMarker),
                  ),
                if (_riderP != null)
                  Marker(
                    point: _riderP!,
                    width: 40,
                    height: 40,
                    child: Image.asset(ManagerAssets.yourMarker),
                  ),
              ]),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LocationCardWidget(
              orderModel: widget.orderModel,
              orderController: widget.orderController,
              onTap: widget.onTap,
              index: widget.index,
            ),
          ),
        ]),
      ),
    );
  }
}