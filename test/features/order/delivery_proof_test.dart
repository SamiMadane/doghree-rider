import 'dart:io';

import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/models/ignore_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_action_result.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/domain/models/update_status_body_model.dart';
import 'package:doghree_rider/features/order/domain/services/order_service_interface.dart';
import 'package:doghree_rider/features/order/widgets/deliver_without_photos_dialog.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_result_model.dart';
import 'package:doghree_rider/features/profile/domain/services/profile_service_interface.dart';
import 'package:doghree_rider/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

typedef _Status = OrderActionResult<StatusOutcome>;

class _FakeOrderService implements OrderServiceInterface {
  final List<OrderFetchResult> fetches = [];
  final List<_Status> statusResults = [];
  int fetchCalls = 0, statusCalls = 0;
  final List<List<String>> sentPaths = [];
  final List<UpdateStatusBodyModel> bodies = [];

  @override
  Future<OrderFetchResult> getOrderWithId(int? orderId) async {
    fetchCalls++;
    if (fetches.isEmpty) return const OrderFetchResult(OrderFetch.failed, null, 1);
    return fetches.removeAt(0);
  }

  @override
  Future<_Status> updateOrderStatus(
      UpdateStatusBodyModel body, List<MultipartBody> proof) async {
    statusCalls++;
    bodies.add(body);
    sentPaths.add(proof.map((p) => p.file!.path).toList());
    return statusResults.removeAt(0);
  }

  @override
  Future<List<OrderModel>?> getCurrentOrders() async => [];

  @override
  Future<List<OrderModel>?> getLatestOrders() async => [];

  @override
  List<int?> prepareIgnoreIdList(List<IgnoreModel> ignoredRequests) => [];

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
  _FakeProfileController() : super(profileServiceInterface: _NoProfileService());
  @override
  Future<SessionStatus> getProfile({bool isFromSplash = false}) async =>
      SessionStatus.valid;
}

const _Status _ok = _Status(StatusOutcome.updated, 'Status updated', 200);
_Status _fail(int code, [List<String> codes = const []]) =>
    _Status(StatusOutcome.failed, 'server text', code, codes: codes);

OrderModel _order(int id, String status, {List<String>? proof}) => OrderModel(
    id: id,
    orderStatus: status,
    orderType: 'delivery',
    detailsCount: 1,
    orderProofFullUrl: proof);

OrderFetchResult _found(int id, String status, {List<String>? proof}) =>
    OrderFetchResult(OrderFetch.found, _order(id, status, proof: proof), 200);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  late Directory dir;
  late _FakeOrderService service;
  late OrderController controller;
  late List<String?> toasts;
  late int confirms;
  late bool confirmAnswer;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('d09o_');
    service = _FakeOrderService();
    controller = OrderController(orderServiceInterface: service);
    toasts = [];
    confirms = 0;
    confirmAnswer = true;
    controller.toast = (String? m, {bool isError = true}) => toasts.add(m);
    controller.confirmDeliverWithoutPhotos = () async {
      confirms++;
      return confirmAnswer;
    };
    Get.put<ProfileController>(_FakeProfileController());
  });

  tearDown(() async {
    Get.reset();
    await dir.delete(recursive: true);
  });

  XFile jpeg(String name) {
    final File f = File('${dir.path}/$name')
      ..writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0, ...List<int>.filled(500, 1)]);
    return XFile(f.path);
  }

  /// Order 5 is open, picked up, with [n] proof photos bound to it.
  OrderModel withPhotos(int n) {
    controller.prepareProofFor(5);
    for (int i = 0; i < n; i++) {
      controller.addProofImage(jpeg('p$i.jpg'));
    }
    return _order(5, 'picked_up');
  }

  group('delivery proof never blocks delivery (row 49, B-02)', () {
    test('D1 a missing photo is dropped and the delivery is sent', () async {
      final order = withPhotos(1);
      controller.addProofImage(XFile('${dir.path}/gone.jpg'));
      service.statusResults.add(_ok);
      expect(await controller.updateOrderStatus(order, 'delivered'), isTrue);
      expect(service.sentPaths.single, ['${dir.path}/p0.jpg']);
      expect(service.statusCalls, 1);
    });

    test('D9 dropped photos give the "some photos skipped" message', () async {
      final order = withPhotos(1);
      controller.addProofImage(XFile('${dir.path}/gone.jpg'));
      service.statusResults.add(_ok);
      await controller.updateOrderStatus(order, 'delivered');
      expect(toasts, ['delivered_some_photos_skipped']);
      expect(controller.pickedPrescriptions, isEmpty);
    });

    test('D3 timeout, but the order is delivered with photos: success, '
        'one status call, proof cleared', () async {
      final order = withPhotos(2);
      service.statusResults.add(_fail(1));
      service.fetches.add(_found(5, 'delivered', proof: ['https://x/1.jpg']));
      expect(await controller.updateOrderStatus(order, 'delivered'), isTrue);
      expect(service.statusCalls, 1);
      expect(controller.pickedPrescriptions, isEmpty);
      expect(toasts, ['order_delivered']);
      expect(controller.isLoading, isFalse);
    });

    test('D4 delivered but no proof saved: one honest message', () async {
      final order = withPhotos(1);
      service.statusResults.add(_fail(500));
      service.fetches.add(_found(5, 'delivered', proof: []));
      expect(await controller.updateOrderStatus(order, 'delivered'), isTrue);
      expect(toasts, ['delivered_photos_not_saved']);
      expect(service.statusCalls, 1);
    });

    test('D5 timeout and the check fails: unconfirmed, nothing resent',
        () async {
      final order = withPhotos(1);
      service.statusResults.add(_fail(1));
      expect(await controller.updateOrderStatus(order, 'delivered'), isFalse);
      expect(service.statusCalls, 1);
      expect(service.fetchCalls, 1);
      expect(toasts, ['delivery_unconfirmed']);
      expect(controller.pickedPrescriptions, hasLength(1));
      expect(controller.isLoading, isFalse);
    });

    test('D6 a clear 5xx and still picked up: not delivered, retry', () async {
      final order = withPhotos(1);
      service.statusResults.add(_fail(502));
      service.fetches.add(_found(5, 'picked_up'));
      expect(await controller.updateOrderStatus(order, 'delivered'), isFalse);
      expect(toasts, ['order_not_delivered_retry']);
      expect(service.statusCalls, 1);
      expect(controller.pickedPrescriptions, hasLength(1));
    });

    test('D7 offline (1) and still picked up: unconfirmed, never resent',
        () async {
      final order = withPhotos(1);
      service.statusResults.add(_fail(1));
      service.fetches.add(_found(5, 'picked_up'));
      expect(await controller.updateOrderStatus(order, 'delivered'), isFalse);
      expect(toasts, ['delivery_unconfirmed']);
      expect(service.statusCalls, 1);
      expect(confirms, 0);
    });

    test('D8 unknown failure (0) and still picked up: unconfirmed', () async {
      final order = withPhotos(1);
      service.statusResults.add(_fail(0));
      service.fetches.add(_found(5, 'picked_up'));
      expect(await controller.updateOrderStatus(order, 'delivered'), isFalse);
      expect(toasts, ['delivery_unconfirmed']);
      expect(service.statusCalls, 1);
    });

    test('D2 413 and still picked up, Yes: one resend with identical fields '
        'and no files', () async {
      final order = withPhotos(2);
      controller.setOtp('1234');
      service.statusResults.addAll([_fail(413), _ok]);
      service.fetches.add(_found(5, 'picked_up'));
      expect(await controller.updateOrderStatus(order, 'delivered'), isTrue);
      expect(confirms, 1);
      expect(service.statusCalls, 2);
      expect(service.sentPaths.map((p) => p.length), [2, 0]);
      expect(service.bodies[1].toJson(), service.bodies[0].toJson());
      expect(service.bodies[1].toJson()['otp'], '1234');
      expect(controller.pickedPrescriptions, isEmpty);
      expect(toasts, ['Status updated']);
      expect(controller.isLoading, isFalse);
    });

    test('D2b 413, No: one call, photos kept, no extra message', () async {
      final order = withPhotos(1);
      confirmAnswer = false;
      service.statusResults.add(_fail(413));
      service.fetches.add(_found(5, 'picked_up'));
      expect(await controller.updateOrderStatus(order, 'delivered'), isFalse);
      expect(service.statusCalls, 1);
      expect(controller.pickedPrescriptions, hasLength(1));
      expect(toasts, isEmpty);
      expect(controller.isLoading, isFalse);
    });

    test('D2d the confirm throws: one message, the loader stops', () async {
      final order = withPhotos(1);
      controller.confirmDeliverWithoutPhotos =
          () async => throw StateError('screen gone');
      service.statusResults.add(_fail(413));
      service.fetches.add(_found(5, 'picked_up'));
      expect(await controller.updateOrderStatus(order, 'delivered'), isFalse);
      expect(service.statusCalls, 1);
      expect(toasts, ['error_occurred']);
      expect(controller.isLoading, isFalse);
      // The guard is released: a later tap can act again.
      service.statusResults.add(_ok);
      expect(await controller.updateOrderStatus(order, 'delivered'), isTrue);
    });

    test('D10 a 403 order_id/status code (body dropped by PHP) is treated '
        'like a 413', () async {
      final order = withPhotos(1);
      service.statusResults
          .addAll([_fail(403, const ['order_id', 'status']), _ok]);
      service.fetches.add(_found(5, 'picked_up'));
      expect(await controller.updateOrderStatus(order, 'delivered'), isTrue);
      expect(confirms, 1);
      expect(service.sentPaths.map((p) => p.length), [1, 0]);
    });
  });

  group('guards', () {
    test('G1 delivered without photos: no check request', () async {
      service.statusResults.add(_ok);
      expect(
          await controller.updateOrderStatus(_order(5, 'picked_up'), 'delivered'),
          isTrue);
      expect(service.fetchCalls, 0);
      expect(toasts, ['Status updated']);
    });

    test('G2 picked_up never carries photos or checks', () async {
      controller.prepareProofFor(5);
      controller.addProofImage(jpeg('a.jpg'));
      service.statusResults.add(_fail(1));
      await controller.updateOrderStatus(_order(5, 'accepted'), 'picked_up');
      expect(service.sentPaths.single, isEmpty);
      expect(service.fetchCalls, 0);
    });

    test('G3 a 406 error with photos keeps its D-04 outcome, no check',
        () async {
      final order = withPhotos(1);
      service.statusResults
          .add(const _Status(StatusOutcome.notDelivered, 'wallet', 406, codes: ['error']));
      expect(await controller.updateOrderStatus(order, 'delivered'), isFalse);
      expect(service.fetchCalls, 0);
      expect(toasts, ['wallet']);
      expect(controller.pickedPrescriptions, hasLength(1));
    });

    test('G6 a 403 invalid_status_transition with photos is not a photo '
        'problem', () async {
      final order = withPhotos(1);
      expect(classifyProofFailure(403, const ['invalid_status_transition']),
          ProofFailure.none);
      service.statusResults.add(const _Status(
          StatusOutcome.orderChanged, 'x', 403,
          codes: ['invalid_status_transition']));
      service.fetches.add(_found(5, 'delivered'));
      await controller.updateOrderStatus(order, 'delivered');
      expect(confirms, 0);
      expect(toasts, ['order_status_changed']);
    });
  });

  group('classifyProofFailure', () {
    test('C1 413', () => expect(classifyProofFailure(413, const []), ProofFailure.tooLarge));
    test('C2 403 with a required-field code', () {
      expect(classifyProofFailure(403, const ['order_id']), ProofFailure.tooLarge);
      expect(classifyProofFailure(403, const ['x', 'status']), ProofFailure.tooLarge);
      expect(classifyProofFailure(403, const ['otp']), ProofFailure.none);
    });
    test('C3 5xx', () {
      expect(classifyProofFailure(500, const []), ProofFailure.serverError);
      expect(classifyProofFailure(599, const []), ProofFailure.serverError);
    });
    test('C4 0 and 1', () {
      expect(classifyProofFailure(0, const []), ProofFailure.unknown);
      expect(classifyProofFailure(1, const []), ProofFailure.unknown);
    });
    test('C5 server decisions and success', () {
      for (final s in [200, 404, 405, 406, 409, 401, null]) {
        expect(classifyProofFailure(s, const ['error']), ProofFailure.none);
      }
    });
  });

  group('order_proof_full_url read defensively', () {
    OrderModel parse(Map<String, dynamic> extra) =>
        OrderModel.fromJson({'id': 1, ...extra});
    test('J1 missing', () => expect(parse({}).hasProofImages, isFalse));
    test('J2 null', () =>
        expect(parse({'order_proof_full_url': null}).hasProofImages, isFalse));
    test('J3 empty string', () =>
        expect(parse({'order_proof_full_url': ''}).hasProofImages, isFalse));
    test('J4 empty list', () =>
        expect(parse({'order_proof_full_url': []}).hasProofImages, isFalse));
    test('J5 list of strings', () => expect(
        parse({'order_proof_full_url': ['https://x/1.jpg']}).hasProofImages,
        isTrue));
    test('J6 only null and blank items', () => expect(
        parse({'order_proof_full_url': [null, '', ' ']}).hasProofImages,
        isFalse));
  });

  group('proof picker (rows 46, 49)', () {
    test('K1 camera permission denied: one message, nothing escapes',
        () async {
      controller.pickImageFn =
          (_) async => throw PlatformException(code: 'camera_access_denied');
      await controller.pickPrescriptionImage(isRemove: false, isCamera: true);
      expect(toasts, ['camera_permission_denied']);
      expect(controller.pickedPrescriptions, isEmpty);
    });

    test('K2 a cancel is silent', () async {
      controller.pickImageFn = (_) async => null;
      await controller.pickPrescriptionImage(isRemove: false, isCamera: false);
      expect(toasts, isEmpty);
    });

    test('K3 a HEIC photo is refused', () async {
      final File f = File('${dir.path}/a.heic')
        ..writeAsBytesSync(
            [0, 0, 0, 24, ...'ftyp'.codeUnits, ...'heic'.codeUnits, 0, 0, 0, 0]);
      controller.pickImageFn = (_) async => XFile(f.path);
      await controller.pickPrescriptionImage(isRemove: false, isCamera: false);
      expect(toasts, ['photo_format_not_supported']);
      expect(controller.pickedPrescriptions, isEmpty);
    });

    test('K4 a double tap opens the picker once', () async {
      int opened = 0;
      controller.pickImageFn = (_) async {
        opened++;
        return jpeg('k4.jpg');
      };
      final a = controller.pickPrescriptionImage(isRemove: false, isCamera: false);
      final b = controller.pickPrescriptionImage(isRemove: false, isCamera: false);
      await Future.wait([a, b]);
      expect(opened, 1);
      expect(controller.pickedPrescriptions, hasLength(1));
    });

    test('G5 guard: a 6th photo is refused', () async {
      withPhotos(5);
      controller.pickImageFn = (_) async => jpeg('six.jpg');
      await controller.pickPrescriptionImage(isRemove: false, isCamera: false);
      expect(controller.pickedPrescriptions, hasLength(5));
      expect(toasts, ['maximum_proof_images_5']);
    });
  });

  group('DeliverWithoutPhotosDialog', () {
    testWidgets('D2c a double Yes answers once and never pops the screen',
        (tester) async {
      Get.testMode = false;
      addTearDown(() => Get.testMode = true);
      await tester.pumpWidget(ScreenUtilInit(
        designSize: const Size(376, 812),
        builder: (_, __) => GetMaterialApp(
            theme: light, home: const Scaffold(body: Text('order details'))),
      ));
      final List<bool?> answers = [];
      Get.dialog<bool>(const DeliverWithoutPhotosDialog()).then(answers.add);
      await tester.pumpAndSettle();

      final yes = find.byKey(const ValueKey('deliver_without_photos_yes'));
      await tester.tap(yes);
      await tester.pump();
      await tester.tap(yes, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(answers, [true]);
      expect(find.text('order details'), findsOneWidget);
      expect(find.byType(DeliverWithoutPhotosDialog), findsNothing);
    });
  });
}
