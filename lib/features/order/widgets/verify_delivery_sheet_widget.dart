import 'dart:async';
import 'package:doghree_rider/common/widgets/replay_image.dart';
import 'package:doghree_rider/features/notification/controllers/notification_controller.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/theme_extension.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyDeliverySheetWidget extends StatefulWidget {
  final OrderModel currentOrderModel;
  final bool? verify;
  final bool? cod;
  final double? orderAmount;
  final bool isSenderPay;
  final bool? isParcel;
  final bool? isSetOtp;
  const VerifyDeliverySheetWidget(
      {super.key,
      required this.currentOrderModel,
      required this.verify,
      required this.orderAmount,
      required this.cod,
      this.isSenderPay = false,
      this.isParcel = false,
      this.isSetOtp = true});

  @override
  State<VerifyDeliverySheetWidget> createState() =>
      _VerifyDeliverySheetWidgetState();
}

class _VerifyDeliverySheetWidgetState extends State<VerifyDeliverySheetWidget> {
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isSetOtp!) {
      Get.find<OrderController>().setOtp('');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds - 1;
      if (_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final CustomColorsExtension colors =
        theme.extension<CustomColorsExtension>()!;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: GetBuilder<OrderController>(builder: (orderController) {
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.w20, vertical: Dimensions.h16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // المقبض
            Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.r16),
                color: colors.strock1,
              ),
            ),
            SizedBox(height: Dimensions.h16),
            widget.verify!
                ? Column(children: [
                    Text(
                      'otp_verification'.tr,
                      textAlign: TextAlign.center,
                      style: textBold().copyWith(
                        fontSize: Dimensions.fs18,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: Dimensions.h10),
                    Text(
                      'enter_otp_number'.tr,
                      textAlign: TextAlign.center,
                      style: textRegular().copyWith(
                        fontSize: Dimensions.fs14,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: Dimensions.h20),
                    SizedBox(
                      width: 200,
                      child: PinCodeTextField(
                        length: 4,
                        appContext: context,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.slide,
                        textStyle: textBold().copyWith(
                          fontSize: Dimensions.fs16,
                          color: cs.onSurface,
                        ),
                        cursorColor: cs.onSurface,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.underline,
                          fieldHeight: 30,
                          fieldWidth: 30,
                          borderWidth: 2,
                          borderRadius: BorderRadius.circular(Dimensions.r4),
                          selectedColor: cs.onSurface,
                          activeColor: cs.onSurface,
                          inactiveColor: cs.outline,
                          selectedFillColor: theme.cardColor,
                          activeFillColor: theme.cardColor,
                          inactiveFillColor: theme.cardColor,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        backgroundColor: Colors.transparent,
                        enableActiveFill: true,
                        onChanged: (String text) =>
                            orderController.setOtp(text),
                        beforeTextPaste: (text) => true,
                      ),
                    ),
                    SizedBox(height: Dimensions.h10),
                    Text(
                      'collect_otp_from_customer'.tr,
                      textAlign: TextAlign.center,
                      style: textRegular().copyWith(
                        fontSize: Dimensions.fs14,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: Dimensions.h20),
                  ])
                : Column(children: [
                    const ReplayImage(
                      asset: ManagerAssets.deliveredSuccessAnim,
                      size: 200,
                    ),
                    SizedBox(height: Dimensions.h8),
                    Text(
                      widget.isSenderPay
                          ? 'want_to_collect_order_amount'.tr
                          : 'want_to_complete_the_order'.tr,
                      textAlign: TextAlign.center,
                      style: textMedium().copyWith(
                        fontSize: Dimensions.fs16,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: Dimensions.h16),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        '${'order_amount'.tr}:',
                        textAlign: TextAlign.center,
                        style: textBold().copyWith(
                          fontSize: Dimensions.fs16,
                          color: cs.onSurface,
                        ),
                      ),
                      SizedBox(width: Dimensions.w4),
                      Text(
                        PriceConverterHelper.convertPrice(widget.orderAmount),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.ltr,
                        style: textBold().copyWith(
                          fontSize: Dimensions.fs16,
                          color: cs.onSurface,
                        ),
                      ),
                    ]),
                    SizedBox(height: Dimensions.h24),
                  ]),
            !orderController.isLoading
                ? CustomButtonWidget(
                    buttonText: widget.verify! ? 'submit'.tr : 'ok'.tr,
                    radius: Dimensions.r10,
                    margin: EdgeInsets.only(bottom: Dimensions.h10),
                    onPressed: (widget.verify! &&
                            orderController.otp.length != 4)
                        ? null
                        : () {
                            if (widget.cod!) {
                              if (widget.verify! && widget.isParcel!) {
                                Get.back(result: 'show_price_view');
                              } else {
                                Get.find<OrderController>()
                                    .updateOrderStatus(
                                        widget.currentOrderModel,
                                        widget.currentOrderModel.orderStatus ==
                                                'handover'
                                            ? 'picked_up'
                                            : 'delivered',
                                        parcel: widget.isParcel)
                                    .then((success) {
                                  if (success) {
                                    Get.find<OrderController>().getOrderWithId(
                                        widget.currentOrderModel.id);
                                    Get.find<ProfileController>().getProfile();
                                    Get.find<OrderController>()
                                        .getCurrentOrders();
                                  }
                                });
                              }
                            } else {
                              Get.find<OrderController>()
                                  .updateOrderStatus(
                                      widget.currentOrderModel,
                                      widget.currentOrderModel.orderStatus ==
                                              'handover'
                                          ? 'picked_up'
                                          : 'delivered',
                                      parcel: widget.isParcel)
                                  .then((success) {
                                if (success) {
                                  Get.find<ProfileController>().getProfile();
                                  Get.find<OrderController>()
                                      .getCurrentOrders();
                                  if (!widget.isSenderPay) {
                                    Get.offAllNamed(
                                        RouteHelper.getInitialRoute());
                                  }
                                }
                              });
                            }
                          },
                  )
                : const Center(child: CircularProgressIndicator()),
            widget.verify!
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Expanded(
                          child: Text(
                            'did_not_receive_user_notification'.tr,
                            style: textRegular().copyWith(
                              fontSize: Dimensions.fs12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Get.find<NotificationController>()
                                .hideNotificationButton
                            ? const SizedBox()
                            : InkWell(
                                onTap: _seconds < 1
                                    ? () {
                                        Get.find<NotificationController>()
                                            .sendDeliveredNotification(
                                                widget.currentOrderModel.id);
                                        _startTimer();
                                      }
                                    : null,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Dimensions.w8,
                                    vertical: Dimensions.h4,
                                  ),
                                  child: Text(
                                    '${'resend_it'.tr}${_seconds > 0 ? ' (${_seconds}s)' : ''}',
                                    style: textBold().copyWith(
                                      fontSize: Dimensions.fs12,
                                      color: _seconds > 0
                                          ? cs.onSurfaceVariant
                                          : cs.tertiary,
                                    ),
                                  ),
                                ),
                              )
                      ])
                : const SizedBox(),
            SizedBox(height: Dimensions.h10),
          ]),
        );
      }),
    );
  }
}