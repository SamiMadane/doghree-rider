import 'dart:async';
import 'package:doghree_rider/features/notification/controllers/notification_controller.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/theme_extension.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyDeliverySheetWidget extends StatefulWidget {
  final OrderModel currentOrderModel;
  const VerifyDeliverySheetWidget({super.key, required this.currentOrderModel});

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
    Get.find<OrderController>().setOtp('');
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
                onChanged: (String text) => orderController.setOtp(text),
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
            !orderController.isLoading
                ? CustomButtonWidget(
                    buttonText: 'submit'.tr,
                    radius: Dimensions.r10,
                    margin: EdgeInsets.only(bottom: Dimensions.h10),
                    onPressed: orderController.otp.length != 4
                        ? null
                        : () {
                            Get.find<OrderController>()
                                .updateOrderStatus(
                                    widget.currentOrderModel, 'delivered',
                                    parcel: false)
                                .then((success) {
                              if (success) {
                                Get.find<ProfileController>().getProfile();
                                Get.find<OrderController>().getCurrentOrders();
                                Get.offAllNamed(RouteHelper.getInitialRoute());
                              }
                            });
                          },
                  )
                : const Center(child: CircularProgressIndicator()),
            Row(
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
                  Get.find<NotificationController>().hideNotificationButton
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
                ]),
            SizedBox(height: Dimensions.h10),
          ]),
        );
      }),
    );
  }
}