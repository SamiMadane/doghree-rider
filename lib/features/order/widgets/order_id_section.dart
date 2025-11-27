import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/styles.dart';

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
      padding: EdgeInsets.all(Dimensions.p16),
      borderRadius: Dimensions.r16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${'id_label'.tr}: ', // ترجم الكلمة ID
                  style: robotoSemiBold.copyWith(
                    fontSize: Dimensions.fs14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                TextSpan(
                  text: '#$orderId',
                  style: robotoSemiBold.copyWith(
                    fontSize: Dimensions.fs14,
                    color: ManagerColors.darkGreen,
                  ),
                ),
              ],
            ),
          ),
          CustomCard(
            isBorder: false,
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.p10, vertical: Dimensions.p10),
            fillColor: isPaid
                ? ManagerColors.darkGreen
                : Theme.of(context).colorScheme.error,
            autoWidth: true,
            child: Center(
              child: Text(
                isPaid ? 'paid'.tr : 'unpaid'.tr,
                style: robotoBold.copyWith(
                  color: ManagerColors.white,
                  fontSize: Dimensions.fs14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
