import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/helper/price_converter_helper.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/util/theme_extension.dart';

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Column(
      children: [
        Row(
          children: [
            Text(
              'statistics'.tr,
              style: robotoBold.copyWith(fontSize: Dimensions.fs20),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                Get.toNamed(RouteHelper.getDetailsStatisticsRoute());
              },
              child: Row(
                children: [
                  Text(
                    'detailed_statistics'.tr,
                    style: robotoRegular.copyWith(
                      color: customColor.naturalBlue,
                      decoration: TextDecoration.underline,
                      decorationColor: customColor.naturalBlue,
                    ),
                  ),
                  Icon(
                    Icons.arrow_right,
                    color: customColor.naturalBlue,
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: Dimensions.p16),
        Row(
          children: [
            Expanded(
              child: _StatisticsCard(
                amount: 0,
                title: 'expected_amount'.tr,
                color: ManagerColors.greenLightMode,
              ),
            ),
            SizedBox(width: Dimensions.p16),
            Expanded(
              child: _StatisticsCard(
                amount: 0,
                title: 'expected_amount'.tr,
                color: ManagerColors.orangeLightMode,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ويدجت للكرت الواحد
class _StatisticsCard extends StatelessWidget {
  final double amount;
  final String title;
  final Color color;

  const _StatisticsCard({
    required this.amount,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      fillColor: Theme.of(context).scaffoldBackgroundColor,
      isBorder: false,
      padding: EdgeInsets.all(Dimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PriceConverterHelper.convertPrice(amount),
            style: robotoSemiBold.copyWith(
              fontSize: Dimensions.fs22,
              color: color,
            ),
          ),
          SizedBox(height: Dimensions.p4),
          Text(
            title,
            style: robotoMedium.copyWith(
            ),
          ),
        ],
      ),
    );
  }
}
