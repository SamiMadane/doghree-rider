import 'package:doghree_rider/util/manager_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/features/order/domain/models/order_details_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';

class OrderItemWidget extends StatelessWidget {
  final OrderModel order;
  final OrderDetailsModel orderDetails;

  const OrderItemWidget({
    super.key,
    required this.order,
    required this.orderDetails,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    String addOnText = '';
    for (var addOn in orderDetails.addOns ?? []) {
      addOnText =
          '$addOnText${(addOnText.isEmpty) ? '' : ', '}${addOn.name} (${addOn.quantity})';
    }

    String variationText = '';
    if (orderDetails.variation!.isNotEmpty) {
      List<String> types = orderDetails.variation![0].type!.split('-');
      if (types.length == orderDetails.itemDetails!.choiceOptions!.length) {
        for (int i = 0; i < types.length; i++) {
          variationText +=
              '${i == 0 ? '' : ' ,'}${orderDetails.itemDetails!.choiceOptions![i].title} - ${types[i]}';
        }
      } else {
        variationText = orderDetails.itemDetails!.variations![0].type!;
      }
    } else if (orderDetails.foodVariation!.isNotEmpty) {
      for (var varObj in orderDetails.foodVariation!) {
        variationText += '${variationText.isEmpty ? '' : ' ,'}${varObj.name}(';
        for (int i = 0; i < varObj.variationValues!.length; i++) {
          variationText +=
              '${i == 0 ? '' : ' ,'}${varObj.variationValues![i].level}';
        }
        variationText += ')';
      }
    }

    final EdgeInsetsGeometry extrasPadding = EdgeInsetsDirectional.only(
      start: Dimensions.w60,
      top: Dimensions.h4,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (orderDetails.itemDetails!.imageFullUrl != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.r8),
                  border: Border.all(color: scheme.outline),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.r8),
                  child: CustomImageWidget(
                    height: Dimensions.w70,
                    width: Dimensions.w70,
                    fit: BoxFit.cover,
                    image: '${orderDetails.itemDetails!.imageFullUrl}',
                  ),
                ),
              ),
            SizedBox(
                width: orderDetails.itemDetails!.imageFullUrl != null
                    ? Dimensions.w12
                    : 0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderDetails.itemDetails!.name!,
                    style: textSemiBold().copyWith(
                        fontSize: Dimensions.fs14, color: scheme.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Dimensions.h4),
                  if (((Get.find<SplashController>()
                              .getModule(order.moduleType)
                              .unit! &&
                          orderDetails.itemDetails!.unitType != null) ||
                      (Get.find<SplashController>()
                              .configModel!
                              .toggleVegNonVeg! &&
                          Get.find<SplashController>()
                              .getModule(order.moduleType)
                              .vegNonVeg!))) ...[
                    _MetaTag(
                      label: Get.find<SplashController>()
                              .getModule(order.moduleType)
                              .unit!
                          ? orderDetails.itemDetails!.unitType ?? ''
                          : orderDetails.itemDetails!.veg == 0
                              ? 'non_veg'.tr
                              : 'veg'.tr,
                      dotColor: Get.find<SplashController>()
                              .getModule(order.moduleType)
                              .unit!
                          ? null
                          : (orderDetails.itemDetails!.veg == 0
                              ? scheme.error
                              : ManagerColors.success),
                    ),
                    SizedBox(height: Dimensions.h4),
                  ],
                  Row(
                    children: [
                      Text(
                        PriceConverterHelper.convertPrice(orderDetails.price! -
                            (orderDetails.discountOnItem!)),
                        style: textSemiBold().copyWith(
                          fontSize: Dimensions.fs14,
                        ),
                      ),
                      if (orderDetails.discountOnItem! > 0) ...[
                        SizedBox(width: Dimensions.w8),
                        Text(
                          PriceConverterHelper.convertPrice(orderDetails.price),
                          style: textMedium().copyWith(
                            decoration: TextDecoration.lineThrough,
                            fontSize: Dimensions.fs12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.w8, vertical: Dimensions.h2),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(Dimensions.r50),
                        ),
                        child: Text(
                          '${orderDetails.quantity} ${orderDetails.quantity! > 1 ? 'items'.tr : 'item'.tr}',
                          style: textBold().copyWith(
                              fontSize: Dimensions.fs12,
                              color: scheme.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (addOnText.isNotEmpty)
          Padding(
            padding: extrasPadding,
            child: Text(
              '${'addons'.tr}: $addOnText',
              style: textRegular().copyWith(
                fontSize: Dimensions.fs12,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        if (variationText.isNotEmpty)
          Padding(
            padding: extrasPadding,
            child: Text(
              '${'variations'.tr}: $variationText',
              style: textRegular().copyWith(
                fontSize: Dimensions.fs12,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

/// وسم صغير للوحدة (لتر، كغم...) أو veg / non-veg مع نقطة لونية.
class _MetaTag extends StatelessWidget {
  final String label;
  final Color? dotColor;
  const _MetaTag({required this.label, this.dotColor});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w8,
        vertical: Dimensions.h2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.r50),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: Dimensions.w8,
              height: Dimensions.w8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
            SizedBox(width: Dimensions.w6),
          ],
          Text(
            label,
            style: textMedium().copyWith(
              fontSize: Dimensions.fs12,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}