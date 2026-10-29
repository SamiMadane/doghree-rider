import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class OrderIdSection extends StatelessWidget {
  final String orderId;

  const OrderIdSection({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w16,
        vertical: Dimensions.h16,
      ),
      borderRadius: Dimensions.r16,
      child: RichText(
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
    );
  }
}
