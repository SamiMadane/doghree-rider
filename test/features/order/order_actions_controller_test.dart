import 'dart:async';

import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/models/ignore_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_action_result.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/domain/models/update_status_body_model.dart';
import 'package:doghree_rider/features/order/domain/services/order_service_interface.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_result_model.dart';
import 'package:doghree_rider/features/profile/domain/services/profile_service_interface.dart';
import 'package:doghree_rider/helper/order_ringing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../helpers/fake_ringing_client.dart';

typedef _Accept = OrderActionResult<AcceptOutcome>;
typedef _Status = OrderActionResult<StatusOutcome>;

/// Queued results, call counters, no network.
class _FakeOrderService implements OrderServiceInterface {
  final List<OrderFetchResult> fetches = [];
  final List<_Status> statusResults = [];
  final List<_Accept> acceptResults = [];
  OrderDetailsResult details = const OrderDetailsResult([], 200);
  List<OrderModel>? latest;
  List<OrderModel>? current = [];
  Completer<_Accept>? acceptGate;
  Completer<_Status>? statusGate;
  Object? throwOnStatus;

  int fetchCalls = 0, statusCalls = 0, acceptCalls = 0;
  int currentCalls = 0, latestCalls = 0;
  final List<int> proofCounts = [];
  final List<UpdateStatusBodyModel> bodies = [];

  @override
  Future<OrderFetchResult> getOrderWithId(int? orderId) async {
    fetchCalls++;
    if (fetches.isEmpty) {
      return const OrderFetchResult(OrderFetch.failed, null, 1);
    }
    return fetches.removeAt(0);
  }

  @override
  Future<_Status> updateOrderStatus(
      UpdateStatusBodyModel body, List<MultipartBody> proof) async {
    statusCalls++;
    bodies.add(body);
    proofCounts.add(proof.length);
    if (throwOnStatus != null) throw throwOnStatus!;
    if (statusGate != null) return statusGate!.future;
    return statusResults.removeAt(0);
  }

  @override
  Future<_Accept> acceptOrder(int? orderID) async {
    acceptCalls++;
    if (acceptGate != null) return acceptGate!.future;
    return acceptResults.removeAt(0);
  }

  @override
  Future<OrderDetailsResult> getOrderDetails(int? orderID) async => details;

  @override
  Future<List<OrderModel>?> getCurrentOrders() async {
    currentCalls++;
    return current == null ? null : [...current!];
  }

  @override
  Future<List<OrderModel>?> getLatestOrders() async {
    latestCalls++;
    return latest == null ? null : [...latest!];
  }

  @override
  List<int?> prepareIgnoreIdList(List<IgnoreModel> ignoredRequests) => [];

  @override
  void setIgnoreList(List<IgnoreModel> ignoredRequests) {}

  @override
  List<OrderModel> processLatestOrders(
          List<OrderModel> latestOrderList, List<int?> ignoredIdList) =>
      latestOrderList;

  @override
  List<MultipartBody> prepareOrderProofImages(List<XFile> files) =>
      files.map((f) => MultipartBody('order_proof[]', f)).toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoProfileService implements ProfileServiceInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileController extends ProfileController {
  int profileCalls = 0;
  _FakeProfileController()
      : super(profileServiceInterface: _NoProfileService());

  @override
  Future<SessionStatus> getProfile({bool isFromSplash = false}) async {
    profileCalls++;
    return SessionStatus.valid;
  }
}

OrderModel _order(int id, {String? status, String type = 'delivery'}) =>
    OrderModel(id: id, orderStatus: status, orderType: type, detailsCount: 1);

OrderFetchResult _found(int id, String status) =>
    OrderFetchResult(OrderFetch.found, _order(id, status: status), 200);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  late _FakeOrderService service;
  late OrderController controller;
  late _FakeProfileController profile;
  late List<String?> toasts;

  setUp(() {
    service = _FakeOrderService();
    controller = OrderController(orderServiceInterface: service);
    toasts = [];
    controller.toast = (String? m, {bool isError = true}) => toasts.add(m);
    profile = _FakeProfileController();
    Get.put<ProfileController>(profile);
  });

  tearDown(Get.reset);

  /// Order Details is open on [id] with [status].
  Future<void> openOrder(int id, String status) async {
    service.fetches.add(_found(id, status));
    await controller.getOrderWithId(id);
  }

  group('accept (rows 19, 20)', () {
    test('T1 a poll reorders the list during accept: the accepted card leaves',
        () async {
      service.latest = [_order(1), _order(2), _order(3)];
      await controller.getLatestOrders();
      service.acceptGate = Completer<_Accept>();

      final pending = controller.acceptOrder(_order(2));
      service.latest = [_order(3), _order(1), _order(2)];
      await controller.getLatestOrders();
      service.acceptGate!
          .complete(const _Accept(AcceptOutcome.accepted, 'ok', 200));
      expect(await pending, AcceptOutcome.accepted);

      expect(controller.latestOrderList!.map((o) => o.id), [3, 1]);
      expect(controller.currentOrderList!.map((o) => o.id), [2]);
      expect(controller.isLoading, isFalse);
    });

    test('T2 accept with no running-orders list yet does not crash', () async {
      service.acceptResults
          .add(const _Accept(AcceptOutcome.accepted, 'ok', 200));
      expect(controller.currentOrderList, isNull);
      expect(await controller.acceptOrder(_order(4)), AcceptOutcome.accepted);
      expect(controller.currentOrderList!.map((o) => o.id), [4]);
    });

    test('G3 guard: accept 200 moves the order to running orders', () async {
      await controller.getCurrentOrders();
      service.acceptResults
          .add(const _Accept(AcceptOutcome.accepted, 'ok', 200));
      await controller.acceptOrder(_order(8));
      expect(controller.currentOrderList!.map((o) => o.id), [8]);
    });

    test(
        'T9 taken (404 order / 409): card removed by id, list refreshed, '
        'one message', () async {
      for (final r in const [
        _Accept(AcceptOutcome.taken, 'x', 404),
        _Accept(AcceptOutcome.taken, 'x', 409),
      ]) {
        service.latest = [_order(1), _order(2)];
        await controller.getLatestOrders();
        service.latest = [_order(1)];
        final before = service.latestCalls;
        toasts.clear();
        service.acceptResults.add(r);

        expect(await controller.acceptOrder(_order(2)), AcceptOutcome.taken);
        expect(controller.latestOrderList!.map((o) => o.id), [1]);
        expect(service.latestCalls, before + 1);
        expect(toasts, ['order_no_longer_available']);
        expect(controller.isLoading, isFalse);
      }
    });

    test('T10 405 keeps the card and shows the server message once', () async {
      service.latest = [_order(1), _order(2)];
      await controller.getLatestOrders();
      service.acceptResults
          .add(const _Accept(AcceptOutcome.refused, 'max orders text', 405));

      expect(await controller.acceptOrder(_order(2)), AcceptOutcome.refused);
      expect(controller.latestOrderList!.map((o) => o.id), [1, 2]);
      expect(toasts, ['max orders text']);
      expect(controller.isLoading, isFalse);
    });

    test('T11 offline (404 active_status): no toast, the card stays', () async {
      service.latest = [_order(2)];
      await controller.getLatestOrders();
      service.acceptResults
          .add(const _Accept(AcceptOutcome.offline, 'offline text', 404));

      expect(await controller.acceptOrder(_order(2)), AcceptOutcome.offline);
      expect(toasts, isEmpty);
      expect(controller.latestOrderList!.map((o) => o.id), [2]);
    });

    test('accept offline (statusCode 1): one no-internet message', () async {
      service.acceptResults
          .add(const _Accept(AcceptOutcome.noInternet, 'x', 1));
      expect(await controller.acceptOrder(_order(2)), AcceptOutcome.noInternet);
      expect(toasts, hasLength(1));
      expect(controller.isLoading, isFalse);
    });

    test('T16a a double tap on accept sends one request', () async {
      service.acceptGate = Completer<_Accept>();
      final first = controller.acceptOrder(_order(2));
      final second = controller.acceptOrder(_order(2));
      service.acceptGate!
          .complete(const _Accept(AcceptOutcome.accepted, 'ok', 200));
      await first;
      await second;
      expect(service.acceptCalls, 1);
    });
  });

  group('GET order (row 21)', () {
    test('T3 an offline poll keeps the order and does not navigate', () async {
      await openOrder(5, 'picked_up');
      service.fetches.add(const OrderFetchResult(OrderFetch.failed, null, 1));

      expect(await controller.getOrderWithId(5), OrderFetch.failed);
      expect(controller.orderModel?.id, 5);
      expect(toasts, isEmpty);
    });

    test('T4 404 and 204 return notFound', () async {
      service.fetches
        ..add(const OrderFetchResult(OrderFetch.notFound, null, 404))
        ..add(const OrderFetchResult(OrderFetch.notFound, null, 204));
      expect(await controller.getOrderWithId(5), OrderFetch.notFound);
      expect(await controller.getOrderWithId(5), OrderFetch.notFound);
      expect(toasts, isEmpty);
    });
  });

  group('status change (rows 22, 23, 24)', () {
    test('T5 an exception stops the loader, one message', () async {
      service.throwOnStatus = Exception('boom');
      final ok = await controller.updateOrderStatus(
          _order(5, status: 'accepted'), 'picked_up');
      expect(ok, isFalse);
      expect(controller.isLoading, isFalse);
      expect(toasts, ['error_occurred']);
    });

    test('T6 photos go only with delivered of their own order', () async {
      controller.prepareProofFor(1);
      controller.addProofImage(XFile('a.jpg'));
      controller.addProofImage(XFile('b.jpg'));
      service.statusResults.addAll(const [
        _Status(StatusOutcome.updated, 'ok', 200),
        _Status(StatusOutcome.updated, 'ok', 200),
        _Status(StatusOutcome.updated, 'ok', 200),
      ]);

      await controller.updateOrderStatus(
          _order(1, status: 'handover'), 'picked_up');
      await controller.updateOrderStatus(
          _order(2, status: 'picked_up'), 'delivered');
      await controller.updateOrderStatus(
          _order(1, status: 'picked_up'), 'delivered');

      expect(service.proofCounts, [0, 0, 2]);
      expect(controller.pickedPrescriptions, isEmpty);
    });

    test('T20 reopening the same order keeps the photos, another clears them',
        () {
      controller.prepareProofFor(1);
      controller.addProofImage(XFile('a.jpg'));
      controller.prepareProofFor(1);
      expect(controller.pickedPrescriptions, hasLength(1));
      controller.prepareProofFor(2);
      expect(controller.pickedPrescriptions, isEmpty);
    });

    test(
        'T12 403 invalid_status_transition: one message, running orders and '
        'the open order refreshed', () async {
      await openOrder(5, 'picked_up');
      service.statusResults.add(const _Status(
          StatusOutcome.orderChanged, 'Invalid status transition', 403));
      service.fetches.add(_found(5, 'canceled'));
      final fetchesBefore = service.fetchCalls;

      final ok = await controller.updateOrderStatus(
          controller.orderModel!, 'delivered');

      expect(ok, isFalse);
      expect(toasts, ['order_status_changed']);
      expect(service.currentCalls, 1);
      expect(service.fetchCalls, fetchesBefore + 1);
      expect(controller.orderModel!.orderStatus, 'canceled');
      expect(controller.isLoading, isFalse);
    });

    test('T13 406 error: not delivered, status and photos kept, retry allowed',
        () async {
      await openOrder(5, 'picked_up');
      controller.prepareProofFor(5);
      controller.addProofImage(XFile('a.jpg'));
      service.statusResults
        ..add(const _Status(StatusOutcome.notDelivered, 'wallet error', 406))
        ..add(const _Status(StatusOutcome.updated, 'ok', 200));

      final order = controller.orderModel!;
      expect(await controller.updateOrderStatus(order, 'delivered'), isFalse);
      expect(order.orderStatus, 'picked_up');
      expect(controller.pickedPrescriptions, hasLength(1));
      expect(controller.isLoading, isFalse);
      expect(toasts, ['wallet error']);

      expect(await controller.updateOrderStatus(order, 'delivered'), isTrue);
      expect(service.proofCounts, [1, 1]);
      expect(order.orderStatus, 'delivered');
    });

    test('T14 406 otp keeps the status, own message', () async {
      final order = _order(5, status: 'picked_up');
      service.statusResults.add(
          const _Status(StatusOutcome.otpMismatch, 'Otp Not matched', 406));
      expect(await controller.updateOrderStatus(order, 'delivered'), isFalse);
      expect(order.orderStatus, 'picked_up');
      expect(toasts, ['otp_not_matched']);
    });

    test('T15 an illegal move that the fresh status also refuses sends nothing',
        () async {
      service.fetches.add(_found(5, 'accepted'));
      final ok = await controller.updateOrderStatus(
          _order(5, status: 'accepted'), 'delivered');
      expect(ok, isFalse);
      expect(service.statusCalls, 0);
      expect(toasts, ['order_status_changed']);
      expect(controller.isLoading, isFalse);
    });

    test('T19 a stale local status: the fresh status allows, so it is sent',
        () async {
      service.fetches.add(_found(5, 'picked_up'));
      service.statusResults
          .add(const _Status(StatusOutcome.updated, 'ok', 200));
      final ok = await controller.updateOrderStatus(
          _order(5, status: 'accepted'), 'delivered');
      expect(ok, isTrue);
      expect(service.statusCalls, 1);
      expect(service.bodies.single.status, 'delivered');
    });

    test(
        'T18 delivered response lost, the retry gets 403: refreshed, one '
        'message per tap, loader stops', () async {
      await openOrder(5, 'picked_up');
      service.statusResults
        ..add(const _Status(StatusOutcome.noInternet, 'x', 1))
        ..add(const _Status(StatusOutcome.orderChanged, 'x', 403));
      final order = controller.orderModel!;

      expect(await controller.updateOrderStatus(order, 'delivered'), isFalse);
      expect(toasts, hasLength(1));
      expect(controller.isLoading, isFalse);

      toasts.clear();
      service.fetches.add(_found(5, 'delivered'));
      expect(await controller.updateOrderStatus(order, 'delivered'), isFalse);
      expect(toasts, ['order_status_changed']);
      expect(controller.orderModel!.orderStatus, 'delivered');
      expect(controller.isLoading, isFalse);
    });

    test('T16b a double tap on a status change sends one request', () async {
      service.statusGate = Completer<_Status>();
      final order = _order(5, status: 'accepted');
      final first = controller.updateOrderStatus(order, 'picked_up');
      final second = controller.updateOrderStatus(order, 'picked_up');
      service.statusGate!
          .complete(const _Status(StatusOutcome.updated, 'ok', 200));
      await first;
      await second;
      expect(service.statusCalls, 1);
    });

    test('G1 guard: a delivery refreshes profile and running orders once',
        () async {
      service.statusResults
          .add(const _Status(StatusOutcome.updated, 'ok', 200));
      await controller.updateOrderStatus(
          _order(5, status: 'picked_up'), 'delivered');
      await Future<void>.delayed(Duration.zero);
      expect(profile.profileCalls, 1);
      expect(service.currentCalls, 1);
      expect(toasts, ['ok']);
    });
  });

  group('order details (rows 25, 28)', () {
    test('T7 a failure shows exactly one message', () async {
      service.details = const OrderDetailsResult(null, 500);
      await controller.getOrderDetails(5, false);
      expect(toasts, ['failed_to_load_order_details']);

      toasts.clear();
      service.details = const OrderDetailsResult(null, 404);
      await controller.getOrderDetails(5, false);
      expect(toasts, ['order_details_not_found']);
    });

    test('T8 the parcel branch rebuilds the screen', () async {
      int rebuilds = 0;
      controller.addListener(() => rebuilds++);
      await controller.getOrderDetails(5, true);
      expect(rebuilds, 1);
      expect(controller.orderDetailsModel, isEmpty);
    });
  });

  group('ringing stops (row 36)', () {
    late FakeRingingClient ringing;

    setUp(() {
      ringing = FakeRingingClient();
      OrderRinging.client = ringing;
    });

    tearDown(() => OrderRinging.client = const RingingClient());

    Future<void> settle() => Future<void>.delayed(Duration.zero);

    test('R4 accepted stops the ringing', () async {
      service.acceptResults
          .add(const _Accept(AcceptOutcome.accepted, 'ok', 200));
      await controller.acceptOrder(_order(2));
      await settle();
      expect(ringing.stopCalls, 1);
    });

    test('R4b taken by another rider stops the ringing', () async {
      service.latest = [_order(2)];
      service.acceptResults.add(const _Accept(AcceptOutcome.taken, 'x', 409));
      await controller.acceptOrder(_order(2));
      await settle();
      expect(ringing.stopCalls, 1);
    });

    test('R5 ignoring a request stops the ringing', () async {
      service.latest = [_order(1), _order(2)];
      await controller.getLatestOrders();
      ringing.running = true;
      controller.ignoreOrder(0);
      await settle();
      expect(ringing.stopCalls, 1);
    });

    test('R6 an empty pending list stops it, a non-empty one does not',
        () async {
      service.latest = [_order(1)];
      await controller.getLatestOrders();
      await settle();
      expect(ringing.stopCalls, 0);

      service.latest = [];
      await controller.getLatestOrders();
      await settle();
      expect(ringing.stopCalls, 1);
    });

    test('G6 guard: a failed refresh (null list) does not stop the ringing',
        () async {
      service.latest = null;
      await controller.getLatestOrders();
      await settle();
      expect(ringing.stopCalls, 0);
    });
  });
}
