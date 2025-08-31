import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
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
        padding: const EdgeInsets.all(Dimensions.p20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Image.asset(ManagerAssets.money, height: 100, width: 100),
          const SizedBox(height: Dimensions.p20),

          Text(
            'collect_money_from_customer'.tr, textAlign: TextAlign.center,
            style: robotoMedium.copyWith(fontSize: Dimensions.fs16),
          ),
          const SizedBox(height: Dimensions.p20),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              '${'order_amount'.tr}:', textAlign: TextAlign.center,
              style: robotoBold.copyWith(fontSize: Dimensions.fs16),
            ),
            const SizedBox(width: Dimensions.p5),
            Text(
              PriceConverterHelper.convertPrice(totalAmount), textAlign: TextAlign.center,
              style: robotoBold.copyWith(fontSize: Dimensions.fs16, color: Theme.of(context).primaryColor),
            ),
          ]),
          const SizedBox(height: Dimensions.p20),

          CustomButtonWidget(
            buttonText: 'ok'.tr,
            onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
          ),

        ]),
      ),
    );
  }
}
