import 'package:wefrh_rider/helper/price_converter_helper.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderFeeReceiveDialogWidget extends StatelessWidget {
  final double totalAmount;
  const OrderFeeReceiveDialogWidget({super.key, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.r4)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.w20, vertical: Dimensions.h20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Image.asset(ManagerAssets.money, height: 100, width: 100),
          SizedBox(height: Dimensions.h20),

          Text(
            'collect_money_from_customer'.tr, textAlign: TextAlign.center,
            style: textMedium().copyWith(fontSize: Dimensions.fs16),
          ),
          SizedBox(height: Dimensions.h20),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              '${'order_amount'.tr}:', textAlign: TextAlign.center,
              style: textBold().copyWith(fontSize: Dimensions.fs16),
            ),
            SizedBox(width: Dimensions.w4),
            Text(
              PriceConverterHelper.convertPrice(totalAmount), textAlign: TextAlign.center,
              style: textBold().copyWith(fontSize: Dimensions.fs16, color: Theme.of(context).primaryColor),
            ),
          ]),
          SizedBox(height: Dimensions.h20),

          CustomButtonWidget(
            buttonText: 'ok'.tr,
            onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
          ),

        ]),
      ),
    );
  }
}
