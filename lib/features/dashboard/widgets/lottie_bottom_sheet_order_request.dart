import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/features/order/controllers/order_controller.dart';
import 'package:wefrh_rider/features/order/widgets/order_info_section.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LottieBottomSheetOrderRequest extends StatefulWidget {
  final bool isRequest;
  final Function onAccept;
  final Function onReject;
  final int orderId;
  final bool isParcel;
  final OrderRequestType requestType;

  const LottieBottomSheetOrderRequest({
    super.key,
    required this.isRequest,
    required this.onAccept,
    required this.onReject,
    required this.orderId,
    required this.isParcel,
    this.requestType = OrderRequestType.newOrder,
  });

  @override
  State<LottieBottomSheetOrderRequest> createState() =>
      _LottieBottomSheetOrderRequestState();
}

enum OrderRequestType { newOrder, nearbyOrder, assignedOrder }

class _LottieBottomSheetOrderRequestState
    extends State<LottieBottomSheetOrderRequest>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Get.find<OrderController>().getOrderWithId(widget.orderId);
    });
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _startAlarm();
    _slideController.forward();
    Get.find<OrderController>()
        .getOrderDetails(widget.orderId, widget.isParcel);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  void _startAlarm() async {
    AudioPlayer audio = AudioPlayer();
    await audio.play(AssetSource('notification.mp3'));
  }

  void _handleAccept() {
    _timer?.cancel();
    _slideController.reverse().then((_) {
      Navigator.pop(context);
      widget.onAccept();
    });
  }

  void _closeBottomSheet() {
    _timer?.cancel();
    _slideController.reverse().then((_) {
      Navigator.pop(context);
    });
  }

  String _getTitle() {
    switch (widget.requestType) {
      case OrderRequestType.newOrder:
        return 'new_order_request_from_customer'.tr;
      case OrderRequestType.nearbyOrder:
        return 'new_order_nearby'.tr;
      case OrderRequestType.assignedOrder:
        return 'order_assigned_to_you'.tr;
    }
  }

  String _getSubtitle() {
    switch (widget.requestType) {
      case OrderRequestType.newOrder:
        return 'new_order_opportunity'.tr;
      case OrderRequestType.nearbyOrder:
        return 'nearby_order_opportunity'.tr;
      case OrderRequestType.assignedOrder:
        return 'assigned_order_waiting'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      color: Theme.of(context).cardColor,
      child: GetBuilder<OrderController>(builder: (orderController) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.p20),
                child: Column(
                  children: [
                    // Lottie Animation
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.1),
                            Theme.of(context).primaryColor.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: Lottie.asset(
                        ManagerAssets.deliveryBusLottie,
                        width: 200,
                        height: 200,
                      ),
                    ),

                    const SizedBox(height: Dimensions.p30),

                    // Title
                    Text(
                      _getTitle(),
                      style: robotoSemiBold.copyWith(
                        fontSize: Dimensions.fs22,
                        color: Theme.of(context).primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      _getSubtitle(),
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fs16,
                        color: Theme.of(context).disabledColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),
                    orderController.orderDetailsModel != null &&
                            orderController.orderModel != null
                        ? OrderInfoSection(
                            orderController: orderController,
                            controllerOrderModel: orderController.orderModel,
                            parcel: widget.isParcel,
                            showPaymentType: false,
                          )
                        : Shimmer(
                            enabled: true,
                            color: ManagerColors.shimmer,
                            child: Container(
                              width: double.infinity,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(Dimensions.r16),
                              ),
                            ),
                          ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Buttons Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: // للطلبات الجديدة (new_order):
                  widget.isRequest == true
                      ? Row(
                          children: [
                            // زر الرفض
                            Expanded(
                              child: CustomButtonWidget(
                                onPressed: _closeBottomSheet,
                                buttonText: 'not_now'.tr, 
                                isBorder: true,
                                transparent: true,
                              ),
                            ),
                            SizedBox(width: Dimensions.p16),
                            // زر القبول
                            Expanded(
                              flex: 2,
                              child: CustomButtonWidget(
                                onPressed: _handleAccept,
                                buttonText:
                                    'accept_order'.tr, 
                              ),
                            ),
                          ],
                        )

                      : CustomButtonWidget(
                          onPressed: _handleAccept,
                          buttonText: 'view_details'.tr, 
                        ),
            ),
          ],
        );
      }),
    );
  }
}
