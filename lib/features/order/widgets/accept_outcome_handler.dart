import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_alert_dialog_widget.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/models/order_action_result.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/screens/order_details_screen.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/helper/route_helper.dart';

/// Accept from a request card (list or map). The confirm sheet is closed
/// first, while it is surely the top route (audit row 20). `Navigator.pop`
/// is used because `Get.back` would close an open snackbar instead, and GetX
/// does not track sheets opened with showModalBottomSheet.
///
/// The controller has already shown the one message for every outcome
/// except [AcceptOutcome.offline], which gets the online prompt here.
Future<void> acceptFromCard(
    OrderModel orderModel, VoidCallback onAccepted) async {
  Navigator.of(Get.context!).pop();
  final OrderController orderController = Get.find<OrderController>();
  final AcceptOutcome outcome = await orderController.acceptOrder(orderModel);
  switch (outcome) {
    case AcceptOutcome.accepted:
      onAccepted();
      orderModel.orderStatus = 'accepted';
      final int index = orderController.currentOrderList
              ?.indexWhere((o) => o.id == orderModel.id) ??
          -1;
      Get.toNamed(
        RouteHelper.getOrderDetailsRoute(orderModel.id),
        arguments: OrderDetailsScreen(
          orderId: orderModel.id,
          isRunningOrder: true,
          orderIndex: index < 0 ? null : index,
        ),
      );
      break;
    case AcceptOutcome.offline:
      // The server says offline: refresh the profile silently so the Home
      // toggle shows it, and prompt the rider to go online.
      Get.find<ProfileController>().getProfile();
      Get.dialog(CustomAlertDialogWidget(
        description: 'go_online_to_accept_orders'.tr,
        onOkPressed: () => Get.back(),
      ));
      break;
    case AcceptOutcome.taken:
    case AcceptOutcome.refused:
    case AcceptOutcome.noInternet:
    case AcceptOutcome.failed:
      break;
  }
}
