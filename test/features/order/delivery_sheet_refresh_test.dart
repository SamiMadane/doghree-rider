import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/models/order_action_result.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/domain/models/update_status_body_model.dart';
import 'package:doghree_rider/features/order/domain/services/order_service_interface.dart';
import 'package:doghree_rider/features/order/widgets/confirm_delivery_sheet_widget.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_result_model.dart';
import 'package:doghree_rider/features/profile/domain/services/profile_service_interface.dart';
import 'package:doghree_rider/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class _FakeOrderService implements OrderServiceInterface {
  int currentCalls = 0;

  @override
  Future<OrderActionResult<StatusOutcome>> updateOrderStatus(
          UpdateStatusBodyModel body, List<MultipartBody> proof) async =>
      const OrderActionResult(StatusOutcome.updated, 'ok', 200);

  @override
  Future<List<OrderModel>?> getCurrentOrders() async {
    currentCalls++;
    return [];
  }

  @override
  List<MultipartBody> prepareOrderProofImages(List<XFile> files) => [];

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

void main() {
  tearDown(Get.reset);

  testWidgets(
      'T17 confirming a delivery refreshes profile and running orders once '
      '(audit row 29)', (tester) async {
    final service = _FakeOrderService();
    final controller = OrderController(orderServiceInterface: service);
    controller.toast = (String? m, {bool isError = true}) {};
    final profile = _FakeProfileController();
    Get.put<OrderController>(controller);
    Get.put<ProfileController>(profile);

    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(376, 812),
      builder: (_, __) => GetMaterialApp(
        theme: light,
        // The sheet goes to the dashboard after success; any route will do.
        onGenerateRoute: (settings) => MaterialPageRoute(
            settings: settings, builder: (_) => const SizedBox.shrink()),
        home: Scaffold(
          body: ConfirmDeliverySheetWidget(
            currentOrderModel:
                OrderModel(id: 5, orderStatus: 'picked_up', detailsCount: 1),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('ok'));
    await tester.pumpAndSettle();

    expect(profile.profileCalls, 1);
    expect(service.currentCalls, 1);

    // Dispose the sheet (and its replay timer) before the test ends.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
