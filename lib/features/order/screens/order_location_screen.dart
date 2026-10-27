import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/doghree_map/doghree_map_view.dart';
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
  DoghreeMapHandle? _map;

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

  List<DoghreeMarker> get _markers => [
        if (_deliveryP != null)
          DoghreeMarker(
              id: 'delivery',
              point: _deliveryP!,
              asset: ManagerAssets.customerMarker),
        if (_pickupP != null)
          DoghreeMarker(
              id: 'pickup',
              point: _pickupP!,
              asset: _parcel
                  ? ManagerAssets.userMarker
                  : ManagerAssets.restaurantMarker),
        if (_riderP != null)
          DoghreeMarker(
              id: 'rider', point: _riderP!, asset: ManagerAssets.yourMarker),
      ];

  void _fit() {
    final pts = usablePoints([
      if (_deliveryP != null) _deliveryP!,
      if (_pickupP != null) _pickupP!,
      if (_riderP != null) _riderP!,
    ]);
    // الكارد صار تحت الخريطة (Column) فلا حاجة لمساحة إضافية في الأسفل
    _map?.fitPoints(pts, padding: const EdgeInsets.all(56));
  }

  @override
  Widget build(BuildContext context) {
    // إذا الـ config لسا ما وصل: {} بيعطي الخريطة الاحتياطية بالمركز الافتراضي
    final mapConfig = Get.find<SplashController>().doghreeMapConfig ??
        DoghreeMapConfig.fromConfigJson(const {});

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'order_location'.tr),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: DoghreeMapView(
                config: mapConfig,
                initialCenter: _deliveryP, // null → مركز غزة تلقائيًا
                initialZoom: 14,
                markers: _markers,
                onReady: (h) {
                  _map = h;
                  _fit();
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: LocationCardWidget(
                orderModel: widget.orderModel,
                orderController: widget.orderController,
                onTap: widget.onTap,
                index: widget.index,
              ),
            ),
          ],
        ),
      ),
    );
  }
}