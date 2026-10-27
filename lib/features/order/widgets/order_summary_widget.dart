import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';

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
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.w16,
          vertical: Dimensions.h16,
        ),
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
                          style: textRegular().copyWith(
                            // was textSemiBold
                            fontSize: Dimensions.fs14,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        TextSpan(
                          text: '#${order.id}',
                          style: textBold().copyWith(
                            // was textSemiBold
                            fontSize: Dimensions.fs14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  isBorder: false,
                  autoWidth: true,
                  padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.w12, vertical: Dimensions.h4),
                  fillColor: order.paymentStatus == 'paid'
                      ? ManagerColors.greenLightMode
                      : Theme.of(context).colorScheme.error,
                  borderRadius: Dimensions.r20,
                  child: Text(
                    order.paymentStatus == 'paid' ? 'paid'.tr : 'unpaid'.tr,
                    style: textMedium().copyWith(
                      color: ManagerColors.onPrimary,
                      fontSize: Dimensions.fs14,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.h16),

            // أيقونات + خطوط
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    ClipOval(
                      child: CustomImageWidget(
                        image: order.storeLogoFullUrl,
                        width: Dimensions.w28,
                        height: Dimensions.h28,
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.h40,
                      child: DottedLine(
                        direction: Axis.vertical,
                        lineLength: double.infinity,
                        dashLength: 6,
                        dashColor: Theme.of(context).disabledColor,
                      ),
                    ),
                    SvgPicture.asset(
                      ManagerAssets.locationIcon,
                      width: Dimensions.w24,
                      height: Dimensions.h24,
                    ),
                  ],
                ),
                SizedBox(width: Dimensions.w8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.storeName!,
                        style:
                            textSemiBold().copyWith(fontSize: Dimensions.fs14),
                      ),
                      Text(
                        order.storeAddress!,
                        style: textRegular().copyWith(
                          fontSize: Dimensions.fs14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      SizedBox(height: Dimensions.h4),
                      if (parcel)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.w4,
                            vertical: Dimensions.h4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.r4),
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                          child: Text(
                            'parcel'.tr,
                            style: textMedium().copyWith(
                              fontSize: Dimensions.fs10,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      SizedBox(height: Dimensions.h10),
                      Text(
                        parcel
                            ? order.deliveryAddress.toString()
                            : order.storeAddress!,
                        style:
                            textSemiBold().copyWith(fontSize: Dimensions.fs14),
                      ),
                      Text(
                        parcel ? 'delivery_location'.tr : 'store_location'.tr,
                        style: textRegular().copyWith(
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
              SizedBox(height: Dimensions.h16),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${'delivery_instruction'.tr}: ',
                      style: textSemiBold().copyWith(
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                    TextSpan(
                      text: order.deliveryInstruction!,
                      style: textMedium().copyWith(
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
              SizedBox(height: Dimensions.h16),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${'cutlery'.tr}: ',
                      style: textSemiBold().copyWith(
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                    TextSpan(
                      text: order.cutlery! ? 'yes'.tr : 'no'.tr,
                      style: textMedium().copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (order.unavailableItemNote != null) ...[
              SizedBox(height: Dimensions.h16),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${'unavailable_item_note'.tr}: ',
                      style: textSemiBold().copyWith(
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                    TextSpan(
                      text: order.unavailableItemNote!,
                      style: textMedium().copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: Dimensions.h16),

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
