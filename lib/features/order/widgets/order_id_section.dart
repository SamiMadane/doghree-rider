import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';

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
    final scheme = Theme.of(context).colorScheme;

    return CustomCard(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w16,
        vertical: Dimensions.h16,
      ),
      borderRadius: Dimensions.r16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${'id_label'.tr}: ',
                  style: textRegular().copyWith(
                    fontSize: Dimensions.fs14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                TextSpan(
                  text: '#${orderId}',
                  style: textBold().copyWith(
                    fontSize: Dimensions.fs14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          CustomCard(
            isBorder: false,
            autoWidth: true,
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.w12,
              vertical: Dimensions.h6,
            ),
            borderRadius: Dimensions.r20,
            fillColor: isPaid ? ManagerColors.success : ManagerColors.error,
            child: Center(
              child: Text(
                isPaid ? 'paid'.tr : 'unpaid'.tr,
                style: textBold().copyWith(
                  color: ManagerColors.onPrimary,
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
