import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/common/widgets/custom_image_widget.dart';
import 'package:wefrh_rider/common/widgets/title_widget.dart';
import 'package:wefrh_rider/features/order/controllers/order_controller.dart';
import 'package:wefrh_rider/features/order/widgets/order_item_widget.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/util/theme_extension.dart';

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
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Column(
      children: [
        CustomCard(
          padding: const EdgeInsets.all(Dimensions.p16),
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
                      fontSize: Dimensions.fs16,
                    ),
                  ),
                  showPaymentType
                      ? CustomCard(
                          width: 50,
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.p10,
                              vertical: Dimensions.p4),
                          fillColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: Dimensions.r8,
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
                                fontSize: Dimensions.fs10,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink()
                ],
              ),

              const SizedBox(height: Dimensions.p20),

              /// --- Parcel section ---
              parcel
                  ? _buildParcelCategory(context)
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orderController.orderDetailsModel!.length,
                      itemBuilder: (context, index) {
                        final item = orderController.orderDetailsModel![index];
                        return Column(
                          children: [
                            OrderItemWidget(
                              order: controllerOrderModel,
                              orderDetails: item,
                            ),
                            if (index !=
                                orderController.orderDetailsModel!.length -
                                    1) ...[
                              const SizedBox(height: Dimensions.p16),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final dashCount =
                                      (constraints.maxWidth / 9).floor();
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(
                                      dashCount,
                                      (_) => Container(
                                          width: 5,
                                          height: 2,
                                          color: customColor.strock2),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: Dimensions.p16),
                            ]
                          ],
                        );
                      },
                    )
            ],
          ),
        ),

        /// --- Cutlery ---
        if (orderController.orderDetailsModel!.isNotEmpty &&
            orderController.orderDetailsModel![0].itemDetails != null &&
            orderController.orderDetailsModel![0].itemDetails!.moduleType ==
                'food') ...[
          const SizedBox(height: Dimensions.p16),
          CustomCard(
            padding: const EdgeInsets.all(Dimensions.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'cutlery'.tr,
                  style: robotoSemiBold.copyWith(
                    fontSize: Dimensions.fs16,
                  ),
                ),
                const SizedBox(height: Dimensions.p8),

                // Note Content
                Text(
                  controllerOrderModel.cutlery! ? 'yes'.tr : 'no'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fs13,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],

        /// --- Unavailable item note ---
        if (controllerOrderModel.unavailableItemNote != null) ...[
          const SizedBox(height: Dimensions.p16),
          CustomCard(
            padding: const EdgeInsets.all(Dimensions.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'unavailable_item_note'.tr,
                  style: robotoSemiBold.copyWith(
                    fontSize: Dimensions.fs16,
                  ),
                ),
                const SizedBox(height: Dimensions.p8),

                // Note Content
                Text(
                  controllerOrderModel.unavailableItemNote!,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fs13,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          )
        ],
      ],
    );
  }

  /// --- Widget Parcel Category ---
  Widget _buildParcelCategory(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.p10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.r4),
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
                const SizedBox(width: Dimensions.p10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(controllerOrderModel.parcelCategory!.name!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fs12,
                          )),
                      Text(
                        controllerOrderModel.parcelCategory!.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fs12,
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
