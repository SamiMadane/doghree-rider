import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/helper/price_converter_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';

class EarningTile extends StatelessWidget {
  final String title;
  final double? amount;
  final bool showAmount;
  final VoidCallback? onEyeTap;

  const EarningTile({
    super.key,
    required this.title,
    this.amount,
    this.showAmount = true,
    this.onEyeTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(Dimensions.p16),
      fillColor: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: Dimensions.r10,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fs16,
                ),
              ),
              if (title == 'total_earnings'.tr) ...[
                const Spacer(),
                GestureDetector(
                  onTap: onEyeTap,
                  child: Icon(
                    showAmount ? Icons.visibility : Icons.visibility_off,
                    size: 18,
                  ),
                ),
              ]
            ],
          ),
          const SizedBox(height: Dimensions.p10),
          // الصف الثاني: المبلغ أو *****
          Text(
            (amount != null && showAmount)
                ? PriceConverterHelper.convertPrice(amount)
                : '*****',
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fs18,
            ),
          ),
        ],
      ),
    );
  }
}
