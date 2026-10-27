import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/order/domain/models/ignore_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_cancellation_body.dart';
import 'package:doghree_rider/features/order/domain/models/order_details_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/domain/models/update_status_body_model.dart';
import 'package:doghree_rider/features/order/domain/repositories/order_repository_interface.dart';
import 'package:doghree_rider/features/order/domain/services/order_service_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:doghree_rider/doghree_map/map_safety.dart';
import 'package:latlong2/latlong.dart' show LatLng, Distance;

class OrderService implements OrderServiceInterface {
  final OrderRepositoryInterface orderRepositoryInterface;
  OrderService({required this.orderRepositoryInterface});

  @override
  Future<List<CancellationData>?> getCancelReasons() async {
    return await orderRepositoryInterface.getCancelReasons();
  }

  @override
  Future<Response> getOrderWithId(int? orderId) async {
    return await orderRepositoryInterface.get(orderId);
  }

  @override
  Future<PaginatedOrderModel?> getCompletedOrderList(int offset) async {
    return await orderRepositoryInterface.getCompletedOrderList(offset);
  }

  @override
  Future<List<OrderModel>?> getCurrentOrders() async {
    return await orderRepositoryInterface.getList();
  }

  @override
  Future<List<OrderModel>?> getLatestOrders() async {
    return await orderRepositoryInterface.getLatestOrders();
  }

  @override
  Future<ResponseModel> updateOrderStatus(
      UpdateStatusBodyModel updateStatusBody,
      List<MultipartBody> proofAttachment) async {
    return await orderRepositoryInterface.updateOrderStatus(
        updateStatusBody, proofAttachment);
  }

  @override
  Future<List<OrderDetailsModel>?> getOrderDetails(int? orderID) async {
    return await orderRepositoryInterface.getOrderDetails(orderID);
  }

  @override
  Future<ResponseModel> acceptOrder(int? orderID) async {
    return await orderRepositoryInterface.acceptOrder(orderID);
  }

  @override
  List<IgnoreModel> getIgnoreList() {
    return orderRepositoryInterface.getIgnoreList();
  }

  @override
  void setIgnoreList(List<IgnoreModel> ignoreList) {
    orderRepositoryInterface.setIgnoreList(ignoreList);
  }

  @override
  List<OrderModel> processLatestOrders(
      List<OrderModel> latestOrderList, List<int?> ignoredIdList) {
    List<OrderModel> latestOrderList0 = [];
    for (var order in latestOrderList) {
      if (!ignoredIdList.contains(order.id)) {
        latestOrderList0.add(order);
      }
    }
    return latestOrderList0;
  }

  @override
  List<int?> prepareIgnoreIdList(List<IgnoreModel> ignoredRequests) {
    List<int?> ignoredIdList = [];
    for (var ignore in ignoredRequests) {
      ignoredIdList.add(ignore.id);
    }
    return ignoredIdList;
  }

  @override
  List<IgnoreModel> tempList(
      DateTime currentTime, List<IgnoreModel> ignoredRequests) {
    List<IgnoreModel> tempList = [];
    tempList.addAll(ignoredRequests);
    for (int index = 0; index < tempList.length; index++) {
      if (currentTime.difference(tempList[index].time!).inMinutes > 10) {
        tempList.removeAt(index);
      }
    }
    return tempList;
  }

  @override
  List<MultipartBody> prepareOrderProofImages(List<XFile> pickedPrescriptions) {
    List<MultipartBody> multiParts = [];
    for (XFile file in pickedPrescriptions) {
      multiParts.add(MultipartBody('order_proof[]', file));
    }
    return multiParts;
  }

  @override
  Future<List<LatLng>?> getRoute(LatLng origin, LatLng destination) async {
    return await orderRepositoryInterface.getRoute(origin, destination);
  }

  /// موقع الجهاز الحالي (null إذا غير متاح أو خارج غزة)
  @override
  Future<LatLng?> getCurrentPoint() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      Position? pos;
      try {
        // مهلة 8 ثوانٍ حتى لا تعلق الشاشة على «جاري تحديد الموقع»
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 8));
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }
      return pos == null ? null : parsePoint(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// السيرفر يرجع نقطتين فقط (أو لا يرجع شيئاً) = خط مستقيم تقريبي
  @override
  bool isApproxRoute(List<LatLng>? route) => route == null || route.length <= 2;

  @override
  List<LatLng> buildRoute(
      LatLng origin, LatLng destination, List<LatLng>? route) {
    if (route == null || route.length < 2) return [origin, destination];

    const dist = Distance();
    final double endGap = dist(route.last, destination); // بالمتر
    List<LatLng> r = route;

    if (endGap > 80) {
      int best = 0;
      double bestD = double.infinity;

      for (int i = 0; i < route.length; i++) {
        final m = dist(route[i], destination);
        if (m < bestD) {
          bestD = m;
          best = i;
        }
      }
      // نقصّ فقط إذا كان أقرب رأس أقرب للوجهة بوضوح من آخر نقطة
      if (bestD < endGap * 0.5) r = route.sublist(0, best + 1);
      debugPrint(
          'buildRoute endGap=${endGap.toStringAsFixed(0)}m bestD=${bestD.toStringAsFixed(0)}m best=$best/${route.length}');
    }
    return [origin, ...r, destination];
  }
}
