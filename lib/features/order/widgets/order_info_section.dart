import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';
import 'package:doghree_rider/common/widgets/title_widget.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/widgets/order_item_widget.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/theme_extension.dart';

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

  String get _paymentLabel {
    if (cod == true) return 'cod'.tr;
    if (wallet == true) return 'wallet'.tr;
    if (partialPay == true) return 'partially_pay'.tr;
    if (offlinePay == true) return 'offline_payment'.tr;
    return 'digitally_paid'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final customColor = theme.extension<CustomColorsExtension>()!;

    return Column(
      children: [
        CustomCard(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.w16,
            vertical: Dimensions.h16,
          ),
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
                    titleStyle: textSemiBold().copyWith(
                      fontSize: Dimensions.fs16,
                    ),
                  ),
                  if (showPaymentType)
                    CustomCard(
                      isBorder: false,
                      autoWidth: true,
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.w10,
                        vertical: Dimensions.h4,
                      ),
                      fillColor: scheme.primaryContainer,
                      borderRadius: Dimensions.r8,
                      child: Center(
                        child: Text(
                          _paymentLabel,
                          style: textMedium().copyWith(
                            fontSize: Dimensions.fs11,
                            color: scheme.tertiary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: Dimensions.h20),
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
                              SizedBox(height: Dimensions.h16),
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
                                        width: Dimensions.w5,
                                        height: Dimensions.h2,
                                        color: customColor.strock2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: Dimensions.h16),
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
          SizedBox(height: Dimensions.h16),
          _noteCard(
            context,
            title: 'cutlery'.tr,
            text: controllerOrderModel.cutlery! ? 'yes'.tr : 'no'.tr,
          ),
        ],

        /// --- Unavailable item note ---
        if (controllerOrderModel.unavailableItemNote != null) ...[
          SizedBox(height: Dimensions.h16),
          _noteCard(
            context,
            title: 'unavailable_item_note'.tr,
            text: controllerOrderModel.unavailableItemNote!,
          ),
        ],
      ],
    );
  }

  Widget _noteCard(BuildContext context,
      {required String title, required String text}) {
    return CustomCard(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w16,
        vertical: Dimensions.h16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textSemiBold().copyWith(fontSize: Dimensions.fs16)),
          SizedBox(height: Dimensions.h8),
          Text(
            text,
            style: textRegular().copyWith(
              fontSize: Dimensions.fs13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelCategory(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w10,
        vertical: Dimensions.h10,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.r10),
        border: Border.all(color: scheme.outline),
      ),
      child: controllerOrderModel.parcelCategory != null
          ? Row(
              children: [
                ClipOval(
                  child: CustomImageWidget(
                    image: controllerOrderModel.parcelCategory!.imageFullUrl,
                    height: Dimensions.w35,
                    width: Dimensions.w35,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: Dimensions.w10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controllerOrderModel.parcelCategory!.name!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textMedium().copyWith(fontSize: Dimensions.fs12),
                      ),
                      Text(
                        controllerOrderModel.parcelCategory!.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textRegular().copyWith(
                          fontSize: Dimensions.fs12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Text('no_parcel_category_data_found'.tr, style: textMedium()),
    );
  }
}