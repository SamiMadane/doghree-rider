import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/confirmation_bottom_sheet.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/common/widgets/slider_button_widget.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/features/order/widgets/verify_delivery_sheet_widget.dart';
import 'package:doghree_rider/util/app_constants.dart';

class OrderSliderButton extends StatelessWidget {
  final dynamic order;
  final bool parcel;
  final bool accepted;
  final bool pickedUp;
  final bool handover;
  final bool orderVerificationActive;
  final bool cancelPermission;
  final bool fromLocationScreen;

  const OrderSliderButton({
    super.key,
    required this.order,
    required this.parcel,
    required this.accepted,
    required this.pickedUp,
    required this.handover,
    required this.orderVerificationActive,
    required this.cancelPermission,
    required this.fromLocationScreen,
  });

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<OrderController>();

    return SliderButton(
      action: () async {
        // Case 1: Parcel accepted -> confirm delivery
        if (parcel && accepted) {
          if (orderController.isLoading) {
            orderController.initLoading();
          }

          showCustomBottomSheet(
            child: ConfirmationBottomSheet(
              icon: ManagerAssets.confirmationOrderImage,
              iconSize: Dimensions.fs150,
              title: 'are_you_sure_to_confirm'.tr,
              description: 'you_want_to_confirm_this_delivery'.tr,
              onAccept: () {
                orderController.updateOrderStatus(
                  order,
                  AppConstants.handover,
                  back: fromLocationScreen ? false : true,
                  gotoDashboard: fromLocationScreen ? true : false,
                );
              },
              acceptText: 'yes'.tr,
              acceptColor: Theme.of(context).primaryColor,
              cancelText: 'no'.tr,
            ),
          );
        }
        // Case 2: Handover -> picked up
        else if (handover) {
          if (Get.find<ProfileController>().profileModel!.active == 1) {
            orderController.updateOrderStatus(
              order,
              AppConstants.pickedUp,
              back: false,
              gotoDashboard: false,
            );
          } else {
            showCustomSnackBar('make_yourself_online_first'.tr);
          }
        }
        // Case 3: Picked up -> deliver (parcel and non-parcel)
        else if (pickedUp) {
          if (orderVerificationActive) {
            Get.bottomSheet(
              VerifyDeliverySheetWidget(currentOrderModel: order),
              isScrollControlled: true,
            );
          } else {
            orderController.updateOrderStatus(
              order,
              AppConstants.delivered,
              back: fromLocationScreen ? false : true,
              gotoDashboard: fromLocationScreen ? true : false,
            );
          }
        }
      },
      label: Text(
        (parcel && accepted)
            ? 'swipe_to_confirm_delivery'.tr
            : pickedUp
                ? parcel
                    ? 'swipe_to_deliver_parcel'.tr
                    : 'swipe_to_deliver_order'.tr
                : handover
                    ? parcel
                        ? 'swipe_to_pick_up_parcel'.tr
                        : 'swipe_to_pick_up_order'.tr
                    : '',
        style: textBold().copyWith(
          fontSize: Dimensions.fs16,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      dismissThresholds: 0.5,
      dismissible: false,
      shimmer: true,
      width: 1170,
      height: 60,
      buttonSize: 50,
      radius: 14,
      icon: Center(
        child: Icon(
          Icons.double_arrow_rounded, 
          color: Theme.of(context).colorScheme.onPrimary,
          size: Dimensions.w20,
        ),
      ),
      isLtr: true, // دائماً LTR: المربع على اليسار والسحب لليمين
      boxShadow: const BoxShadow(blurRadius: 0),
    );
  }
}
