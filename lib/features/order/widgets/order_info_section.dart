import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/title_widget.dart';
import 'package:sixam_mart_delivery/features/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/order/widgets/order_item_widget.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class OrderInfoSection extends StatelessWidget {
  final OrderController orderController;
  final dynamic controllerOrderModel;
  final bool parcel;
  final bool? cod, wallet, partialPay, offlinePay;
  final bool showPaymentType;
  final bool showOrderCount;

  const OrderInfoSection({
    super.key,
    required this.orderController,
    required this.controllerOrderModel,
    required this.parcel,
    this.cod,
    this.wallet,
    this.partialPay,
    this.offlinePay,
    this.showPaymentType = true,
    this.showOrderCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TitleWidget(
                title: parcel ? 'charge_payer'.tr : 'order_items'.tr,
                showOrderCount: showOrderCount,
                orderCount: parcel
                    ? controllerOrderModel.chargePayer!.tr
                    : orderController.orderDetailsModel!.length,
                    titleStyle: robotoSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
              ),
              showPaymentType?
              CustomCard(
                width: 50,
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingSizeExtraSmall),
                fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: Dimensions.radiusMedium,
                child: Center(
                  child: Text(
                    cod == true
                        ? 'cod'.tr
                        : wallet == true
                            ? 'wallet'.tr
                            : partialPay == true
                                ? 'partially_pay'.tr
                                : offlinePay == true
                                    ? 'offline_payment'.tr
                                    : 'digitally_paid'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ):SizedBox.shrink()
            ],
          ),

          /// --- Cutlery ---
          if (orderController.orderDetailsModel!.isNotEmpty &&
              orderController.orderDetailsModel![0].itemDetails != null &&
              orderController.orderDetailsModel![0].itemDetails!.moduleType ==
                  'food')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${'cutlery'.tr}: ', style: robotoRegular),
                Text(
                  controllerOrderModel.cutlery! ? 'yes'.tr : 'no'.tr,
                  style: robotoRegular,
                ),
              ],
            ),

          /// --- Unavailable item note ---
          if (controllerOrderModel.unavailableItemNote != null) ...[
            const Divider(height: Dimensions.paddingSizeLarge),
            Text('${'unavailable_item_note'.tr}: ', style: robotoMedium),
            Text(controllerOrderModel.unavailableItemNote!,
                style: robotoRegular),
          ],

          /// --- Delivery instruction ---
          if (controllerOrderModel.deliveryInstruction != null) ...[
            const Divider(height: Dimensions.paddingSizeLarge),
            Text('${'delivery_instruction'.tr}: ',
                style: robotoMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                )),
            Text(controllerOrderModel.deliveryInstruction!,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                )),
          ],

          const SizedBox(height: Dimensions.paddingSizeLarge),

          /// --- Parcel section ---
          parcel
              ? _buildParcelCategory(context)
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderController.orderDetailsModel!.length,
                  itemBuilder: (context, index) {
                    return OrderItemWidget(
                      order: controllerOrderModel,
                      orderDetails: orderController.orderDetailsModel![index],
                      showImage: false,
                      showUnitOrVeg: false,
                    );
                  },
                ),
        ],
      ),
    );
  }

  /// --- Widget Parcel Category ---
  Widget _buildParcelCategory(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: Get.isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.grey[200]!,
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
      ),
      child: controllerOrderModel.parcelCategory != null
          ? Row(
              children: [
                ClipOval(
                  child: CustomImageWidget(
                    image: controllerOrderModel.parcelCategory!.imageFullUrl,
                    height: 35,
                    width: 35,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(controllerOrderModel.parcelCategory!.name!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                          )),
                      Text(
                        controllerOrderModel.parcelCategory!.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Text('no_parcel_category_data_found'.tr, style: robotoMedium),
    );
  }
}
