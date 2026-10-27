import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/earning_report_model.dart';
import 'package:doghree_rider/helper/date_converter_helper.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.r16)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Container(
          height: 5, width: 50,
          margin: EdgeInsets.only(top: Dimensions.h10, bottom: Dimensions.h16),
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(Dimensions.r4),
          ),
        ),

        Text(
          'earning_details'.tr,
          style: textBold().copyWith(color: const Color(0xff313F38), fontSize: Dimensions.fs18)
        ),
        SizedBox(height: Dimensions.h16),

        Text(PriceConverterHelper.convertPrice(orderWiseTotalEarning), style: textBold().copyWith(fontSize: Dimensions.fs18 + 2, color: Theme.of(context).primaryColor)),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(text: 'order_id'.tr, style: textRegular().copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.5))),
              TextSpan(text: ': ', style: textRegular().copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.5))),
              TextSpan(text: data?.order?.id.toString(), style: textBold().copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
            ],
          ),
        ),

        Text(DateConverterHelper.utcToDateTime(data!.createAt!), style: textRegular().copyWith(color: Theme.of(context).hintColor)),

        Text('${'pay_by'.tr}: ${data?.order?.paymentMethod?.tr}'.replaceAll('_', ' '), style: textRegular().copyWith(color: Theme.of(context).hintColor)),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.w20, vertical: Dimensions.h20),
          child: Column(children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
              decoration: BoxDecoration(
                color: const Color(0xff313F38).withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(Dimensions.r10),
              ),
              child: Column(children: [

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('delivery_fee'.tr, style: textRegular().copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fs16)),

                  Text(PriceConverterHelper.convertPrice(deliveryFee), style: textRegular().copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fs16)),
                ]),
                SizedBox(height: Dimensions.h10),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('delivery_tips'.tr, style: textRegular().copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fs16)),

                  Text(PriceConverterHelper.convertPrice(deliveryTip), style: textRegular().copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fs16)),
                ]),
                SizedBox(height: Dimensions.h10),

                Container(
                  width: double.infinity, height: 1,
                  margin: EdgeInsets.symmetric(vertical: Dimensions.h10),
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                ),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('total'.tr, style: textBold().copyWith(color: const Color(0xff313F38), fontSize: Dimensions.fs16)),

                  Text(PriceConverterHelper.convertPrice(orderWiseTotalEarning), style: textBold().copyWith(color: const Color(0xff313F38), fontSize: Dimensions.fs16)),
                ]),

              ]),
            ),
          ]),
        ),

      ]),
    );
  }
}
