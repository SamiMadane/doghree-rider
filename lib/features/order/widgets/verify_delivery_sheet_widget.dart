import 'dart:async';
import 'package:wefrh_rider/features/notification/controllers/notification_controller.dart';
import 'package:wefrh_rider/features/order/controllers/order_controller.dart';
import 'package:wefrh_rider/features/order/domain/models/order_model.dart';
import 'package:wefrh_rider/features/profile/controllers/profile_controller.dart';
import 'package:wefrh_rider/helper/price_converter_helper.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
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
  const VerifyDeliverySheetWidget({super.key, required this.currentOrderModel, required this.verify, required this.orderAmount,
    required this.cod, this.isSenderPay = false, this.isParcel = false, this.isSetOtp = true});

  @override
  State<VerifyDeliverySheetWidget> createState() => _VerifyDeliverySheetWidgetState();
}

class _VerifyDeliverySheetWidgetState extends State<VerifyDeliverySheetWidget> {

  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    if(widget.isSetOtp!) {
      Get.find<OrderController>().setOtp('');
    }
  }

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
  }

  void _startTimer() {
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds - 1;
      if(_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.grey.shade900 : Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: GetBuilder<OrderController>(builder: (orderController) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.w20, vertical: Dimensions.h20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            Container(
              height: 5, width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.r16),
                color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
              ),
            ),

            widget.verify! ? Column(children: [
              SizedBox(height: Dimensions.h20),

              Text('otp_verification'.tr, style: textBold(), textAlign: TextAlign.center),
              SizedBox(height: Dimensions.h20),

              Text('enter_otp_number'.tr, style: textRegular().copyWith(color: Theme.of(context).disabledColor), textAlign: TextAlign.center),
              SizedBox(height: Dimensions.h20),

              SizedBox(
                width: 200,
                child: PinCodeTextField(
                  length: 4,
                  appContext: context,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.slide,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.underline,
                    fieldHeight: 30,
                    fieldWidth: 30,
                    borderWidth: 2,
                    borderRadius: BorderRadius.circular(Dimensions.r4),
                    selectedColor: Theme.of(context).primaryColor,
                    selectedFillColor: Get.isDarkMode ? Colors.grey.shade900 : Colors.white,
                    inactiveFillColor: Get.isDarkMode ? Colors.grey.shade900 : Theme.of(context).cardColor,
                    inactiveColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    activeColor: Theme.of(context).primaryColor.withValues(alpha: 0.7),
                    activeFillColor: Get.isDarkMode ? Colors.grey.shade900 : Theme.of(context).cardColor,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  backgroundColor: Colors.transparent,
                  enableActiveFill: true,
                  onChanged: (String text) => orderController.setOtp(text),
                  beforeTextPaste: (text) => true,
                ),
              ),
              SizedBox(height: Dimensions.h10),

              Text('collect_otp_from_customer'.tr, style: textRegular(), textAlign: TextAlign.center),
              SizedBox(height: Dimensions.h20),

            ]) : Column(children: [
              SizedBox(height: Dimensions.h20),

              Image.asset(ManagerAssets.deliveredSuccess, height: 100, width: 100),
              SizedBox(height: Dimensions.h10),

              Text(
                widget.isSenderPay ? 'want_to_collect_order_amount'.tr : 'want_to_complete_the_order'.tr, textAlign: TextAlign.center,
                style: textMedium().copyWith(fontSize: Dimensions.fs16),
              ),
              SizedBox(height: Dimensions.h20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  '${'order_amount'.tr}:', textAlign: TextAlign.center,
                  style: textBold().copyWith(fontSize: Dimensions.fs16),
                ),
                SizedBox(width: Dimensions.w4),
                Text(
                  PriceConverterHelper.convertPrice(widget.orderAmount), textAlign: TextAlign.center,
                  style: textBold().copyWith(fontSize: Dimensions.fs16, color: Theme.of(context).primaryColor),
                ),
              ]),

              const SizedBox(height: 40),
            ]),

           !orderController.isLoading ? CustomButtonWidget(
              buttonText: widget.verify! ? 'submit'.tr : 'ok'.tr,
              radius: Dimensions.r10,
              margin: EdgeInsets.only(bottom: Dimensions.h10),
              onPressed: (widget.verify! && orderController.otp.length != 4) ? null : () {

                 if(widget.cod!){
                   if(widget.verify! && widget.isParcel!) {
                     Get.back(result: 'show_price_view');
                   } else {
                     Get.find<OrderController>().updateOrderStatus(widget.currentOrderModel, widget.currentOrderModel.orderStatus == 'handover' ? 'picked_up' : 'delivered', parcel: widget.isParcel).then((success) {
                       if(success) {
                         Get.find<OrderController>().getOrderWithId(widget.currentOrderModel.id);
                         Get.find<ProfileController>().getProfile();
                         Get.find<OrderController>().getCurrentOrders();
                       }
                     });
                   }
                } else{
                  Get.find<OrderController>().updateOrderStatus(widget.currentOrderModel, widget.currentOrderModel.orderStatus == 'handover' ? 'picked_up' : 'delivered', parcel: widget.isParcel).then((success) {
                    if(success) {
                      Get.find<ProfileController>().getProfile();
                      Get.find<OrderController>().getCurrentOrders();
                      if(!widget.isSenderPay) {
                        Get.offAllNamed(RouteHelper.getInitialRoute());
                      }
                    }
                  });
                }

              },
            ) : const Center(child: CircularProgressIndicator()),

            widget.verify! ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                'did_not_receive_user_notification'.tr,
                style: textRegular().copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fs12),
              ),

              Get.find<NotificationController>().hideNotificationButton ? const SizedBox() : InkWell(
                onTap: _seconds < 1 ? () {
                  Get.find<NotificationController>().sendDeliveredNotification(widget.currentOrderModel.id);
                  _startTimer();
                } : null,
                child: Text('${'resend_it'.tr}${_seconds > 0 ? ' (${_seconds}s)' : ''}', style: TextStyle(color: Theme.of(context).primaryColor),),
              )
            ]) : const SizedBox(),
            SizedBox(height: Dimensions.h20),
          ]),
        );
      }),
    );
  }
}
