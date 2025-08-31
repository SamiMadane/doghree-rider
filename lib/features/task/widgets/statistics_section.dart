import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'statistics'.tr,
              style: robotoBold.copyWith(fontSize: Dimensions.fs20),
            ),
            const Spacer(),
            Text(
              'detailed_statistics'.tr,
              style: robotoRegular.copyWith(
                color: ManagerColors.textBlue,
                decoration: TextDecoration.underline,
                decorationColor: ManagerColors.textBlue,
              ),
            ),
            Icon(
              Icons.arrow_right,
              color: ManagerColors.textBlue,
            )
          ],
        ),
        SizedBox(
          height: Dimensions.p16,
        ),
        Row(
          children: [
            Expanded(
              child: CustomCard(
                fillColor: Theme.of(context).cardColor,
                isBorder: false,
                padding: EdgeInsets.all(Dimensions.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PriceConverterHelper.convertPrice(0),
                      style: robotoSemiBold.copyWith(
                        fontSize: Dimensions.fs20,
                        color: ManagerColors.darkGreen,
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.p5,
                    ),
                    Text(
                      'expected_amount'.tr,
                      style: robotoSemiBold.copyWith(
                        color: ManagerColors.disabledDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: Dimensions.p16,
            ),
            Expanded(
              child: CustomCard(
                fillColor: Theme.of(context).cardColor,
                isBorder: false,
                padding: EdgeInsets.all(Dimensions.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PriceConverterHelper.convertPrice(0),
                      style: robotoSemiBold.copyWith(
                        fontSize: Dimensions.fs20,
                        color: ManagerColors.orange,
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.p5,
                    ),
                    Text(
                      'expected_amount'.tr,
                      style: robotoSemiBold.copyWith(
                        color: ManagerColors.disabledDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
