import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class OrderIdSection extends StatelessWidget {
  final String orderId;
  final bool isPaid;

  const OrderIdSection({
    super.key,
    required this.orderId,
    required this.isPaid,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
      borderRadius: Dimensions.radiusLarge,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${'id_label'.tr}: ', // ترجم الكلمة ID
                  style: robotoSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                TextSpan(
                  text: '#$orderId',
                  style: robotoSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: ManagerColors.darkGreen,
                  ),
                ),
              ],
            ),
          ),
          CustomCard(
            isBorder: false,
            width: isPaid ? 60 : 80,
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeSmall),
            fillColor: isPaid
                ? ManagerColors.darkGreen
                : Theme.of(context).colorScheme.error,
            child: Center(
              child: Text(
                isPaid ? 'paid'.tr : 'unpaid'.tr,
                style: robotoBold.copyWith(
                  color: ManagerColors.white,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
