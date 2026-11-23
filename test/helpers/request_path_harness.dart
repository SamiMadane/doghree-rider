import 'dart:async';
import 'dart:convert';

import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/common/widgets/custom_toast.dart';
import 'package:doghree_rider/features/address/controllers/address_controller.dart';
import 'package:doghree_rider/features/address/domain/services/address_service_interface.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/domain/repositories/order_repository.dart';
import 'package:doghree_rider/features/order/domain/services/order_service.dart';
import 'package:doghree_rider/features/order/screens/order_details_screen.dart';
import 'package:doghree_rider/features/order/widgets/order_requset_widget.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_result_model.dart';
import 'package:doghree_rider/features/profile/domain/services/profile_service_interface.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/features/splash/domain/services/splash_service_interface.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Test harness for the request card and Order Details paths (D-16).
///
/// The real repository, service and controller run. Only the HTTP transport
/// is faked: each reply goes through the real [ApiClient.handleResponse], so
/// `handleError: true` behaves exactly as in the app (ApiChecker toast).
/// Every toast is recorded by [toasts] through a counting ScaffoldMessenger.
class Reply {
  final int status;
  final Object? body;
  final bool offline;
  const Reply(this.status, this.body) : offline = false;
  const Reply.offline()
      : status = 1,
        body = null,
        offline = true;
}

/// A recorded request.
class Hit {
  final String method;
  final String path;
  final Object? body;
  const Hit(this.method, this.path, this.body);
}

class FakeTransportApi extends ApiClient {
  final Map<String, List<Reply>> _replies = {};
  final List<Hit> hits = [];

  FakeTransportApi(SharedPreferences prefs)
      : super(appBaseUrl: 'http://fake.local', sharedPreferences: prefs);

  /// Queue replies for a path; the last one repeats.
  void on(String uri, List<Reply> replies) =>
      _replies[uri.split('?').first] = [...replies];

  int count(String uri) =>
      hits.where((h) => h.path == uri.split('?').first).length;

  Response _answer(String method, String uri, Object? body, bool handleError) {
    final String path = uri.split('?').first;
    hits.add(Hit(method, path, body));
    final List<Reply>? q = _replies[path];
    final Reply r = (q == null || q.isEmpty)
        ? const Reply(404, {
            'errors': [
              {'code': 'unstubbed', 'message': 'unstubbed'}
            ]
          })
        : (q.length > 1 ? q.removeAt(0) : q.first);
    if (r.offline) {
      return const Response(
          statusCode: 1, statusText: ApiClient.noInternetMessage);
    }
    final String text =
        r.body is String ? r.body as String : jsonEncode(r.body);
    return handleResponse(
        http.Response.bytes(utf8.encode(text), r.status,
            headers: {'content-type': 'application/json; charset=utf-8'}),
        uri,
        handleError);
  }

  /// While a path has a gate, its GET requests wait there: a request in
  /// flight. [started] counts them when they are sent, before the gate.
  final Map<String, Completer<void>> gates = {};
  final Map<String, int> started = {};

  void hold(String uri) => gates[uri.split('?').first] = Completer<void>();

  void release(String uri) => gates.remove(uri.split('?').first)?.complete();

  int sent(String uri) => started[uri.split('?').first] ?? 0;

  @override
  Future<Response> getData(String uri,
      {Map<String, dynamic>? query,
      Map<String, String>? headers,
      bool handleError = true}) async {
    final String path = uri.split('?').first;
    started[path] = (started[path] ?? 0) + 1;
    final Completer<void>? gate = gates[path];
    if (gate != null) await gate.future;
    return _answer('GET', uri, query, handleError);
  }

  @override
  Future<Response> postData(String uri, dynamic body,
          {Map<String, String>? headers, bool handleError = true}) async =>
      _answer('POST', uri, body, handleError);

  @override
  Future<Response> postMultipartData(
          String uri, Map<String, String> body, List<MultipartBody> multipartBody,
          {Map<String, String>? headers, bool handleError = true}) async =>
      _answer('MULTIPART', uri, body, handleError);
}

class _ConfigService implements SplashServiceInterface {
  @override
  Future<Response> getConfigData() async =>
      const Response(statusCode: 200, body: {
        'currency_symbol': r'$',
        'module_config': {
          'module_type': ['grocery'],
          'grocery': {
            'unit': true,
            'veg_non_veg': false,
            'order_attachment': false
          },
        },
      });
  @override
  Future<bool> initSharedData() async => true;
  @override
  Future<bool> removeSharedData() async => true;
}

class _NoProfileService implements ProfileServiceInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoAddressService implements AddressServiceInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Profile refreshes are counted, never sent.
class FakeProfileController extends ProfileController {
  int profileCalls = 0;
  FakeProfileController()
      : super(profileServiceInterface: _NoProfileService());

  @override
  Future<SessionStatus> getProfile({bool isFromSplash = false}) async {
    profileCalls++;
    return SessionStatus.valid;
  }
}

/// Every toast text, in order.
final List<String> toasts = [];

class _CountingMessenger extends ScaffoldMessenger {
  const _CountingMessenger({required super.child});
  @override
  ScaffoldMessengerState createState() => _CountingState();
}

class _CountingState extends ScaffoldMessengerState {
  @override
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
      SnackBar snackBar,
      {AnimationStyle? snackBarAnimationStyle}) {
    final Widget c = snackBar.content;
    toasts.add(c is CustomToast ? c.text : c.toString());
    return super.showSnackBar(snackBar,
        snackBarAnimationStyle: snackBarAnimationStyle);
  }
}

/// An order as latest-orders, GET order and current-orders send it.
Map<String, dynamic> orderJson(int id,
        {String status = 'confirmed',
        String type = 'delivery',
        Object? moduleType = 'grocery',
        Object? createdAt}) =>
    {
      'id': id,
      'order_status': status,
      'order_type': type,
      'details_count': 1,
      'module_type': moduleType,
      'store_name': 'Store $id',
      'store_lat': null,
      'store_lng': null,
      if (createdAt != null) 'created_at': createdAt,
    };

const Reply okMessage = Reply(200, {'message': 'ok'});

/// The request list as the Requests tab shows it.
class RequestsHost extends StatelessWidget {
  const RequestsHost({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: GetBuilder<OrderController>(builder: (c) {
          final List<OrderModel> list = c.latestOrderList ?? <OrderModel>[];
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) =>
                OrderRequestWidget(orderModel: list[i], index: i, onTap: () {}),
          );
        }),
      );
}

class Harness {
  late FakeTransportApi api;
  late OrderController orders;
  late FakeProfileController profile;

  /// Registers the controllers on a phone-sized view. Cleanup always runs,
  /// also when an expectation fails.
  Future<void> setUp(WidgetTester t) async {
    Get.reset();
    addTearDown(Get.reset);
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    Get.testMode = true;
    toasts.clear();
    t.view.physicalSize = const Size(376 * 3, 812 * 3);
    t.view.devicePixelRatio = 3;
    SharedPreferences.setMockInitialValues({});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    api = FakeTransportApi(prefs);
    final SplashController splash =
        SplashController(navigationHandlerServiceInterface: _ConfigService());
    await splash.getConfigData();
    Get.put<SplashController>(splash);
    profile = FakeProfileController();
    Get.put<ProfileController>(profile);
    Get.put<AddressController>(
        AddressController(addressServiceInterface: _NoAddressService()));
    orders = OrderController(
        orderServiceInterface: OrderService(
            orderRepositoryInterface:
                OrderRepository(apiClient: api, sharedPreferences: prefs)));
    Get.put<OrderController>(orders);
  }

  Future<void> pumpApp(WidgetTester t, {Widget home = const RequestsHost()}) async {
    await t.pumpWidget(ScreenUtilInit(
      designSize: const Size(376, 812),
      builder: (_, __) => GetMaterialApp(
        theme: light,
        builder: (_, child) => _CountingMessenger(child: child!),
        getPages: [
          GetPage(
              name: RouteHelper.orderDetails,
              page: () => Get.arguments as OrderDetailsScreen),
        ],
        home: home,
      ),
    ));
    await t.pump();
  }

  Future<void> loadList(List<Map<String, dynamic>> items) async {
    api.on('/api/v1/delivery-man/latest-orders', [Reply(200, items)]);
    await orders.getLatestOrders();
  }

  /// Disposes every screen so its timers stop.
  Future<void> tearDown(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 3));
    drain(t);
  }
}

Future<void> settle(WidgetTester t, [int steps = 8]) async {
  for (int i = 0; i < steps; i++) {
    await t.pump(const Duration(milliseconds: 250));
  }
}

/// Every exception reported so far, as short texts.
List<String> drain(WidgetTester t) {
  final List<String> errors = [];
  Object? e;
  while ((e = t.takeException()) != null) {
    errors.add(e.toString().split('\n').first);
  }
  return errors;
}
