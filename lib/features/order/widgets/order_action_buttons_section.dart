import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/features/order/widgets/cancel_confirm_row.dart';
import 'package:sixam_mart_delivery/features/order/widgets/complete_delivary_button.dart';
import 'package:sixam_mart_delivery/features/order/widgets/order_slider_button.dart';
import 'package:sixam_mart_delivery/features/order/widgets/order_status_info_container.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';

class OrderActionButtonsSection extends StatelessWidget {
  final dynamic order;
  final bool showDeliveryConfirmImage;
  final bool showBottomView;
  final bool showSlider;
  final bool accepted;
  final bool parcel;
  final bool processing;
  final bool confirmed;
  final bool cod;
  final bool partialPay;
  final bool selfDelivery;
  final bool pickedUp;
  final bool handover;
  final bool restConfModel;
  final bool orderVerificationActive;
  final bool cancelPermission;
  final bool fromLocationScreen;

  const OrderActionButtonsSection({
    super.key,
    required this.order,
    required this.showDeliveryConfirmImage,
    required this.showBottomView,
    required this.showSlider,
    required this.accepted,
    required this.parcel,
    required this.processing,
    required this.confirmed,
    required this.cod,
    required this.partialPay,
    required this.selfDelivery,
    required this.pickedUp,
    required this.handover,
    required this.restConfModel,
    required this.orderVerificationActive,
    required this.cancelPermission,
    required this.fromLocationScreen,
  });

  @override
  Widget build(BuildContext context) {
    if (showDeliveryConfirmImage &&
        order.orderStatus != 'delivered' &&
        !parcel) {
      return Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
        child: CompleteDeliveryButton(
          order: order,
          orderVerificationActive: orderVerificationActive,
          cod: cod,
          partialPay: partialPay,
        ),
      );
    }

    if (showBottomView) {
      if ((accepted && !parcel && (!cod || restConfModel || selfDelivery)) ||
          processing ||
          confirmed) {
        return Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
          child: OrderStatusInfoContainer(processing: processing),
        );
      }

      if (showSlider) {
        if ((cod &&
                accepted &&
                !restConfModel &&
                cancelPermission &&
                !selfDelivery) ||
            (parcel && accepted && cancelPermission)) {
          return Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
            child: CancelConfirmRow(
              order: order,
              parcel: parcel,
              orderVerificationActive: orderVerificationActive,
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
            child: OrderSliderButton(
              order: order,
              parcel: parcel,
              cod: cod,
              accepted: accepted,
              restConfModel: restConfModel,
              selfDelivery: selfDelivery,
              pickedUp: pickedUp,
              handover: handover,
              orderVerificationActive: orderVerificationActive,
              cancelPermission: cancelPermission,
              fromLocationScreen: fromLocationScreen,
            ),
          );
        }
      }
    }

    return const SizedBox();
  }
}
