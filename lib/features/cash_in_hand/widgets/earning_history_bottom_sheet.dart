import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/cash_in_hand/domain/models/earning_report_model.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class EarningHistoryBottomSheet extends StatelessWidget {
  final Data? data;
  const EarningHistoryBottomSheet({super.key, this.data});

  @override
  Widget build(BuildContext context) {

    final orderWiseTotalEarning = (data?.dmTips ?? 0) + (data?.originalDeliveryCharge ?? 0);
    final deliveryFee = data?.originalDeliveryCharge ?? 0;
    final deliveryTip = data?.dmTips ?? 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.r16)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Container(
          height: 5, width: 50,
          margin: const EdgeInsets.only(top: Dimensions.p10, bottom: Dimensions.p16),
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(Dimensions.r4),
          ),
        ),

        Text(
          'earning_details'.tr,
          style: robotoBold.copyWith(color: const Color(0xff313F38), fontSize: Dimensions.fs18)
        ),
        const SizedBox(height: Dimensions.p16),

        Text(PriceConverterHelper.convertPrice(orderWiseTotalEarning), style: robotoBold.copyWith(fontSize: Dimensions.fs18 + 2, color: Theme.of(context).primaryColor)),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(text: 'order_id'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.5))),
              TextSpan(text: ': ', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.5))),
              TextSpan(text: data?.order?.id.toString(), style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
            ],
          ),
        ),

        Text(DateConverterHelper.utcToDateTime(data!.createAt!), style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),

        Text('${'pay_by'.tr}: ${data?.order?.paymentMethod?.tr}'.replaceAll('_', ' '), style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),

        Padding(
          padding: const EdgeInsets.all(Dimensions.p20),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.p16),
              decoration: BoxDecoration(
                color: const Color(0xff313F38).withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(Dimensions.r10),
              ),
              child: Column(children: [

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('delivery_fee'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fs16)),

                  Text(PriceConverterHelper.convertPrice(deliveryFee), style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fs16)),
                ]),
                const SizedBox(height: Dimensions.p10),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('delivery_tips'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fs16)),

                  Text(PriceConverterHelper.convertPrice(deliveryTip), style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fs16)),
                ]),
                const SizedBox(height: Dimensions.p10),

                Container(
                  width: double.infinity, height: 1,
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.p10),
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                ),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('total'.tr, style: robotoBold.copyWith(color: const Color(0xff313F38), fontSize: Dimensions.fs16)),

                  Text(PriceConverterHelper.convertPrice(orderWiseTotalEarning), style: robotoBold.copyWith(color: const Color(0xff313F38), fontSize: Dimensions.fs16)),
                ]),

              ]),
            ),
          ]),
        ),

      ]),
    );
  }
}
