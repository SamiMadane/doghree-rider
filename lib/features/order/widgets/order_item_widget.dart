import 'package:doghree_rider/util/manager_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/models/config_model.dart' show Module;
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
    // A null or unknown module_type gives an empty Module (audit row 30).
    final SplashController splash = Get.find<SplashController>();
    final Module moduleConfig = splash.getModule(order.moduleType);

    String addOnText = '';
    for (var addOn in orderDetails.addOns ?? []) {
      addOnText =
          '$addOnText${(addOnText.isEmpty) ? '' : ', '}${addOn.name} (${addOn.quantity})';
    }

    // Null-safe throughout (audit row 98, D-16): a line whose item was
    // deleted (item_details null) or with missing fields still shows its
    // price and quantity, so the list matches the billed total.
    final ItemDetails? item = orderDetails.itemDetails;
    final List<Variations> variations = orderDetails.variation ?? [];
    final List<FoodVariation> foodVariations = orderDetails.foodVariation ?? [];
    final List<ChoiceOptions> choiceOptions = item?.choiceOptions ?? [];
    final List<Variations> itemVariations = item?.variations ?? [];

    String variationText = '';
    if (variations.isNotEmpty) {
      final List<String> types = (variations[0].type ?? '').split('-');
      if (types.length == choiceOptions.length) {
        for (int i = 0; i < types.length; i++) {
          variationText +=
              '${i == 0 ? '' : ' ,'}${choiceOptions[i].title} - ${types[i]}';
        }
      } else {
        variationText =
            itemVariations.isNotEmpty ? itemVariations[0].type ?? '' : '';
      }
    } else if (foodVariations.isNotEmpty) {
      for (var varObj in foodVariations) {
        final values = varObj.variationValues ?? [];
        variationText += '${variationText.isEmpty ? '' : ' ,'}${varObj.name}(';
        for (int i = 0; i < values.length; i++) {
          variationText += '${i == 0 ? '' : ' ,'}${values[i].level}';
        }
        variationText += ')';
      }
    }

    final String? imageUrl = item?.imageFullUrl;
    final double? price = orderDetails.price;
    final double discount = orderDetails.discountOnItem ?? 0;
    final int quantity = orderDetails.quantity ?? 0;

    final EdgeInsetsGeometry extrasPadding = EdgeInsetsDirectional.only(
      start: Dimensions.w60,
      top: Dimensions.h4,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (imageUrl != null)
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
                    image: imageUrl,
                  ),
                ),
              ),
            SizedBox(width: imageUrl != null ? Dimensions.w12 : 0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item?.name ?? 'item_no_longer_available'.tr,
                    style: textSemiBold().copyWith(
                        fontSize: Dimensions.fs14, color: scheme.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Dimensions.h4),
                  if (item != null &&
                      (((moduleConfig.unit ?? false) &&
                              item.unitType != null) ||
                          ((splash.configModel?.toggleVegNonVeg ?? false) &&
                              (moduleConfig.vegNonVeg ?? false)))) ...[
                    _MetaTag(
                      label: (moduleConfig.unit ?? false)
                          ? item.unitType ?? ''
                          : item.veg == 0
                              ? 'non_veg'.tr
                              : 'veg'.tr,
                      dotColor: (moduleConfig.unit ?? false)
                          ? null
                          : (item.veg == 0
                              ? scheme.error
                              : ManagerColors.success),
                    ),
                    SizedBox(height: Dimensions.h4),
                  ],
                  Row(
                    children: [
                      if (price != null)
                        Text(
                          PriceConverterHelper.convertPrice(price - discount),
                          style: textSemiBold().copyWith(
                            fontSize: Dimensions.fs14,
                          ),
                        ),
                      if (price != null && discount > 0) ...[
                        SizedBox(width: Dimensions.w8),
                        Text(
                          PriceConverterHelper.convertPrice(price),
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
                          '$quantity ${quantity > 1 ? 'items'.tr : 'item'.tr}',
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