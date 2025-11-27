import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/common/widgets/custom_image_widget.dart';
import 'package:wefrh_rider/features/order/controllers/order_controller.dart';
import 'package:wefrh_rider/features/order/domain/models/order_model.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/styles.dart';

class OrderSummaryWidget extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onShowItems;
  final int itemCount;

  const OrderSummaryWidget({
    super.key,
    required this.order,
    required this.onShowItems,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    bool parcel = order.orderType == 'parcel';

    return GetBuilder<OrderController>(builder: (orderController) {
      return CustomCard(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(Dimensions.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ID + حالة الدفع
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${'id_label'.tr}: ',
                          style: robotoSemiBold.copyWith(
                            fontSize: Dimensions.fs14,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        TextSpan(
                          text: '#${order.id}',
                          style: robotoSemiBold.copyWith(
                            fontSize: Dimensions.fs14,
                            color: ManagerColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  isBorder: false,
                  autoWidth: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  fillColor: order.paymentStatus == 'paid'
                      ? ManagerColors.greenLightMode
                      : Theme.of(context).colorScheme.error,
                  borderRadius: Dimensions.r20,
                  child: Text(
                    order.paymentStatus == 'paid' ? 'paid'.tr : 'unpaid'.tr,
                    style: robotoMedium.copyWith(
                      color: ManagerColors.white,
                      fontSize: Dimensions.fs14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.p16),

            // أيقونات + خطوط
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    ClipOval(
                      child: CustomImageWidget(
                        image:
                            order.storeLogoFullUrl ?? ManagerAssets.storeImage,
                        width: 28,
                        height: 28,
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: DottedLine(
                        direction: Axis.vertical,
                        lineLength: double.infinity,
                        dashLength: 6,
                        dashColor: Theme.of(context).disabledColor,
                      ),
                    ),
                    SvgPicture.asset(
                      ManagerAssets.locationIcon,
                      width: 24,
                      height: 24,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.storeName!,
                        style:
                            robotoSemiBold.copyWith(fontSize: Dimensions.fs14),
                      ),
                      Text(
                        order.storeAddress!,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fs14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(height: Dimensions.p4),
                      if (parcel)
                        Container(
                          padding: const EdgeInsets.all(Dimensions.p4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.r4),
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                          child: Text(
                            'parcel'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fs10,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      const SizedBox(height: Dimensions.p10),
                      Text(
                        parcel
                            ? order.deliveryAddress.toString()
                            : order.storeAddress!,
                        style:
                            robotoSemiBold.copyWith(fontSize: Dimensions.fs14),
                      ),
                      Text(
                        parcel ? 'delivery_location'.tr : 'store_location'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fs14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),

            // Delivery Instructions
            if (order.deliveryInstruction != null &&
                order.deliveryInstruction!.isNotEmpty) ...[
              const SizedBox(height: Dimensions.p16),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${'delivery_instruction'.tr}: ',
                      style: robotoSemiBold.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                    TextSpan(
                      text: order.deliveryInstruction!,
                      style: robotoMedium.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (orderController.orderDetailsModel!.isNotEmpty &&
                orderController.orderDetailsModel![0].itemDetails != null &&
                orderController.orderDetailsModel![0].itemDetails!.moduleType ==
                    'food') ...[
              const SizedBox(height: Dimensions.p16),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${'cutlery'.tr}: ',
                      style: robotoSemiBold.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                    TextSpan(
                      text: order.cutlery! ? 'yes'.tr : 'no'.tr,
                      style: robotoMedium.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (order.unavailableItemNote != null) ...[
              const SizedBox(height: Dimensions.p16),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${'unavailable_item_note'.tr}: ',
                      style: robotoSemiBold.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                    TextSpan(
                      text: order.unavailableItemNote!,
                      style: robotoMedium.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: Dimensions.p16),

            // Show Items Button
            CustomButtonWidget(
              onPressed: onShowItems,
              isBorder: true,
              transparent: true,
              textColor: Theme.of(context).textTheme.bodyMedium?.color,
              borderColor: Theme.of(context).textTheme.bodyMedium?.color,
              buttonText: '${'show_items'.tr} (${itemCount})',
            ),
          ],
        ),
      );
    });
  }
}
