import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/disbursement/domain/models/disbursement_report_model.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class PaymentInformationDialogWidget extends StatelessWidget {
  final Disbursements disbursement;
  const PaymentInformationDialogWidget({super.key, required this.disbursement,});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width * 0.9,
      padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () => Get.back(),
            hoverColor: Colors.transparent,
            child: Container(
              height: 30, width: 30,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
              ),
              child: const Icon(Icons.close, size: 20),
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
          child: Column(children: [

            disbursement.status == 'completed' ? Column(children: [
              Text("payment_information".tr, style: textBold().copyWith(fontSize: Dimensions.fs18)),
              SizedBox(height: Dimensions.h16),

              Text(
                "you_payment_has_been_completed_your_will_receive_the_amount_within_7_day_please_wait_till_then".tr,
                textAlign: TextAlign.center,
                style: textRegular().copyWith(color: Colors.green),
              ),
            ]) : const SizedBox(),

            SizedBox(height: Dimensions.h16),

            Align(
              alignment: Alignment.centerLeft,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("payment_information".tr, style: textBold().copyWith(fontSize: Dimensions.fs18)),
                SizedBox(height: Dimensions.h16),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('payment_method'.tr, style: textMedium().copyWith(fontSize: Dimensions.fs12)),

                  Text(disbursement.withdrawMethod!.methodName!, style: textBold()),
                ]),
                SizedBox(height: Dimensions.h16),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('amount'.tr, style: textMedium().copyWith(fontSize: Dimensions.fs12)),

                  Text(PriceConverterHelper.convertPrice(disbursement.disbursementAmount), style: textBold()),
                ]),
                SizedBox(height: Dimensions.h16),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('disbursement_id'.tr, style: textMedium().copyWith(fontSize: Dimensions.fs12)),

                  Text(disbursement.disbursementId.toString(), style: textBold()),
                ]),
                SizedBox(height: Dimensions.h16),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('status'.tr, style: textMedium().copyWith(fontSize: Dimensions.fs12)),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.w16, vertical: Dimensions.h4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.r4),
                      color: disbursement.status == 'pending' ? Colors.blue.withValues(alpha: 0.1) : disbursement.status == 'completed' ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    ),
                    child: Text(disbursement.status!.tr, style: textMedium().copyWith(fontSize: Dimensions.fs12, color: disbursement.status == 'pending' ? Colors.blue : disbursement.status == 'completed' ? Colors.green : Colors.red)),
                  ),
                ]),

              ]),
            ),

          ]),
        ),

      ]),
    );
  }
}