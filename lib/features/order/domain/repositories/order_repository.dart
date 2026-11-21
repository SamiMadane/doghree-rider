import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/common/models/list_load.dart';
import 'package:doghree_rider/api/api_error_handler.dart';
import 'package:doghree_rider/features/order/domain/models/ignore_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_action_result.dart';
import 'package:doghree_rider/features/order/domain/models/order_cancellation_body.dart';
import 'package:doghree_rider/features/order/domain/models/order_details_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/domain/models/update_status_body_model.dart';
import 'package:doghree_rider/features/order/domain/repositories/order_repository_interface.dart';
import 'package:doghree_rider/helper/json_helper.dart';
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
    // Only a JSON object is parsed. An HTML 200 or a body without reasons
    // gives no list (null), never a TypeError (D-12, C8).
    if (response.statusCode == 200 && response.body is Map<String, dynamic>) {
      try {
        OrderCancellationBody orderCancellationBody =
            OrderCancellationBody.fromJson(response.body);
        final List<CancellationData>? reasons = orderCancellationBody.reasons;
        if (reasons != null) orderCancelReasons = [...reasons];
      } catch (e) {
        if (kDebugMode) debugPrint('cancel reasons parse failed: ${e.runtimeType}');
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

  /// Every history page is silent: My Orders shows NoInternetScreen with
  /// Retry on page 1 (audit row 13) and a footer with Retry on later pages
  /// (audit row 26), so ApiChecker must not add a toast. A 401 still ends the
  /// session. A 200 whose body is not a Map is a failure (null), audit row 52.
  @override
  Future<PaginatedOrderModel?> getCompletedOrderList(int offset) async {
    final Response response = await apiClient.getData(
      AppConstants.allOrdersUri,
      query: {'offset': offset, 'limit': AppConstants.historyPageLimit},
      handleError: false,
    );
    if (response.statusCode != 200) {
      ApiChecker.checkSession(response);
      return null;
    }
    final dynamic body = response.body;
    if (body is! Map) return null;
    try {
      return PaginatedOrderModel.fromJson(Map<String, dynamic>.from(body));
    } catch (e) {
      if (kDebugMode) debugPrint('history parse failed: ${e.runtimeType}');
      return null;
    }
  }

  /// A 200 that is not a List is a failure (null) and the old list stays. A
  /// bad item is skipped (audit row 52). Note that a skipped running order is
  /// hidden from the rider (see progress.md, D-05 notes).
  @override
  Future<List<OrderModel>?> getList() async => (await loadCurrentOrders()).list;

  /// Silent (D-12): the screen decides whether to show one message
  /// (FirstLoadNotice). A 401 still ends the session.
  @override
  Future<ListLoad<OrderModel>> loadCurrentOrders() async {
    final Response response = await apiClient
        .getData(AppConstants.currentOrdersUri, handleError: false);
    ApiChecker.checkSession(response);
    if (response.statusCode != 200) return ListLoad.failed(response);
    final List<OrderModel>? list = JsonHelper.mapList(
        response.body, OrderModel.fromJson,
        name: 'current-orders');
    return list == null
        ? ListLoad<OrderModel>(null, statusCode: 0)
        : ListLoad<OrderModel>(list, statusCode: 200);
  }

  @override
  Future<List<OrderModel>?> getLatestOrders() async {
    // Polled every 10s: silent on failure (audit row 10). The old list stays.
    final Response response = await apiClient
        .getData(AppConstants.latestOrdersUri, handleError: false);
    ApiChecker.checkSession(response);
    if (response.statusCode != 200) return null;
    return JsonHelper.mapList(response.body, OrderModel.fromJson,
        name: 'latest-orders');
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
        response.statusCode,
        codes: ApiErrorHandler.extractErrors(response.body)
            .map((e) => e.key)
            .toList());
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
    // A list gives the lines; a parcel object or anything else gives no lines
    // (R3 step 1). A bad line is skipped.
    final List<OrderDetailsModel> details = response.body is List
        ? JsonHelper.mapList(response.body, OrderDetailsModel.fromJson,
                name: 'order-details') ??
            <OrderDetailsModel>[]
        : <OrderDetailsModel>[];
    return OrderDetailsResult(details, 200);
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
    // One corrupt entry is skipped; it used to throw on every launch
    // (D-12, C10).
    for (var ignore in stringList) {
      try {
        ignoreList.add(IgnoreModel.fromJson(jsonDecode(ignore)));
      } catch (e) {
        if (kDebugMode) debugPrint('ignore entry skipped: ${e.runtimeType}');
      }
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
