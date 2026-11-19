import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/api/api_error_handler.dart';
import 'package:doghree_rider/features/order/domain/models/ignore_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_action_result.dart';
import 'package:doghree_rider/features/order/domain/models/order_cancellation_body.dart';
import 'package:doghree_rider/features/order/domain/models/order_details_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/domain/models/update_status_body_model.dart';
import 'package:doghree_rider/features/order/domain/repositories/order_repository_interface.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:doghree_rider/doghree_map/polyline.dart';

class OrderRepository implements OrderRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  OrderRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<List<CancellationData>?> getCancelReasons() async {
    List<CancellationData>? orderCancelReasons;
    Response response = await apiClient.getData(
        '${AppConstants.orderCancellationUri}?offset=1&limit=30&type=deliveryman');
    if (response.statusCode == 200) {
      OrderCancellationBody orderCancellationBody =
          OrderCancellationBody.fromJson(response.body);
      orderCancelReasons = [];
      for (var element in orderCancellationBody.reasons!) {
        orderCancelReasons.add(element);
      }
    }
    return orderCancelReasons;
  }

  /// Polled every 10s by Order Details: silent (audit row 21). A 401 still
  /// ends the session. 404 and 204 mean not found (backend R4 step 4).
  @override
  Future<OrderFetchResult> get(int? id) async {
    final Response response = await apiClient.getData(
        AppConstants.currentOrderUri,
        query: {'order_id': id},
        handleError: false);
    ApiChecker.checkSession(response);
    final OrderFetch outcome =
        classifyFetch(response.statusCode, response.body);
    if (outcome != OrderFetch.found) {
      return OrderFetchResult(outcome, null, response.statusCode);
    }
    try {
      return OrderFetchResult(
          OrderFetch.found,
          OrderModel.fromJson(Map<String, dynamic>.from(response.body)),
          response.statusCode);
    } catch (e) {
      if (kDebugMode) debugPrint('order parse failed: ${e.runtimeType}');
      return OrderFetchResult(OrderFetch.failed, null, response.statusCode);
    }
  }

  /// Page 1 is silent: My Orders shows NoInternetScreen with Retry on failure
  /// (audit row 13), so ApiChecker must not add a toast. A 401 still ends the
  /// session. Later pages keep the old behaviour (pagination is D-05).
  @override
  Future<PaginatedOrderModel?> getCompletedOrderList(int offset) async {
    PaginatedOrderModel? paginatedOrderModel;
    final bool firstPage = offset == 1;
    Response response = await apiClient.getData(
      AppConstants.allOrdersUri,
      query: {'offset': offset, 'limit': 10},
      handleError: !firstPage,
    );
    if (response.statusCode == 200) {
      paginatedOrderModel = PaginatedOrderModel.fromJson(response.body);
    } else if (firstPage) {
      ApiChecker.checkSession(response);
    }
    return paginatedOrderModel;
  }

  @override
  Future<List<OrderModel>?> getList() async {
    List<OrderModel>? currentOrderList;
    Response response = await apiClient.getData(AppConstants.currentOrdersUri);
    if (response.statusCode == 200) {
      currentOrderList = [];
      response.body.forEach(
          (order) => currentOrderList!.add(OrderModel.fromJson(order)));
    }
    return currentOrderList;
  }

  @override
  Future<List<OrderModel>?> getLatestOrders() async {
    List<OrderModel>? latestOrderList;
    // Polled every 10s: silent on failure (audit row 10). The old list stays.
    Response response = await apiClient.getData(AppConstants.latestOrdersUri,
        handleError: false);
    ApiChecker.checkSession(response);

    if (response.statusCode == 200) {
      latestOrderList = [];
      response.body
          .forEach((order) => latestOrderList!.add(OrderModel.fromJson(order)));
    }
    return latestOrderList;
  }

  /// The caller shows the one message, so the call is silent here. The
  /// outcome comes from the status and errors[0].code only (backend R4).
  @override
  Future<OrderActionResult<StatusOutcome>> updateOrderStatus(
      UpdateStatusBodyModel updateStatusBody,
      List<MultipartBody> proofAttachment) async {
    final Response response = await apiClient.postMultipartData(
        AppConstants.updateOrderStatusUri,
        updateStatusBody.toJson(),
        proofAttachment,
        handleError: false);
    ApiChecker.checkSession(response);
    return OrderActionResult(
        classifyStatus(
            response.statusCode, ApiErrorHandler.extractCode(response.body)),
        _messageOf(response),
        response.statusCode);
  }

  /// Silent: the controller shows one message on failure (audit row 25).
  @override
  Future<OrderDetailsResult> getOrderDetails(int? orderID) async {
    final Response response = await apiClient.getData(
        AppConstants.orderDetailsUri,
        query: {'order_id': orderID},
        handleError: false);
    ApiChecker.checkSession(response);
    if (response.statusCode != 200) {
      return OrderDetailsResult(null, response.statusCode);
    }
    try {
      final List<OrderDetailsModel> details = [];
      final dynamic body = response.body;
      if (body is List) {
        for (final dynamic line in body) {
          details.add(OrderDetailsModel.fromJson(line));
        }
      }
      return OrderDetailsResult(details, 200);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('order details parse failed: ${e.runtimeType}');
      }
      return OrderDetailsResult(null, 200);
    }
  }

  /// The caller shows the one message. The outcome comes from the status
  /// and errors[0].code only (backend R3).
  @override
  Future<OrderActionResult<AcceptOutcome>> acceptOrder(int? orderID) async {
    final Response response = await apiClient.postData(
        AppConstants.acceptOrderUri, {'_method': 'put', 'order_id': orderID},
        handleError: false);
    ApiChecker.checkSession(response);
    return OrderActionResult(
        classifyAccept(
            response.statusCode, ApiErrorHandler.extractCode(response.body)),
        _messageOf(response),
        response.statusCode);
  }

  /// The server message on success (only from a Map body) or the error text
  /// ApiClient built. Never throws on a non-Map body (audit row 22).
  String? _messageOf(Response response) {
    if (response.statusCode == 200) {
      final dynamic body = response.body;
      return body is Map && body['message'] is String
          ? body['message'] as String
          : null;
    }
    return response.statusText;
  }

  @override
  List<IgnoreModel> getIgnoreList() {
    List<IgnoreModel> ignoreList = [];
    List<String> stringList =
        sharedPreferences.getStringList(AppConstants.ignoreList) ?? [];
    for (var ignore in stringList) {
      ignoreList.add(IgnoreModel.fromJson(jsonDecode(ignore)));
    }
    return ignoreList;
  }

  @override
  void setIgnoreList(List<IgnoreModel> ignoreList) {
    List<String> stringList = [];
    for (var ignore in ignoreList) {
      stringList.add(jsonEncode(ignore.toJson()));
    }
    sharedPreferences.setStringList(AppConstants.ignoreList, stringList);
  }

  @override
  Future<List<LatLng>?> getRoute(LatLng origin, LatLng destination) async {
    try {
      Response response = await apiClient.getData(
        AppConstants.directionUri,
        query: {
          'origin_lat': '${origin.latitude}',
          'origin_lng': '${origin.longitude}',
          'destination_lat': '${destination.latitude}',
          'destination_lng': '${destination.longitude}',
        },
      );
      if (response.statusCode == 200 && response.body is Map) {
        final routes = response.body['routes'];
        if (routes is List && routes.isNotEmpty) {
          final encoded = routes[0]['polyline']?['encodedPolyline'];
          if (encoded is String && encoded.isNotEmpty) {
            final pts = decodePolyline(encoded);
            if (pts.isNotEmpty) {
              return pts;
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('getRoute failed: $e');
      return null;
    }
    return null;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }
}
