import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/helper/price_converter_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/util/manager_colors.dart';

class PaymentDetailsSection extends StatelessWidget {
  final bool parcel;
  final double itemsPrice;
  final double addOns;
  final double subTotal;
  final double discount;
  final double couponDiscount;
  final double referrerBonusAmount;
  final double deliveryCharge;
  final double dmTips;
  final double extraPackagingAmount;
  final double additionalCharge;
  final double tax;
  final bool taxIncluded;
  final bool partialPay;
  final double total;
  final bool restConfModel;

  const PaymentDetailsSection({
    super.key,
    required this.parcel,
    required this.itemsPrice,
    required this.addOns,
    required this.subTotal,
    required this.discount,
    required this.couponDiscount,
    required this.referrerBonusAmount,
    required this.deliveryCharge,
    required this.dmTips,
    required this.extraPackagingAmount,
    required this.additionalCharge,
    required this.tax,
    required this.taxIncluded,
    required this.partialPay,
    required this.total,
    required this.restConfModel,
  });

  Widget _buildRow(String label, String value,
      {TextStyle? style, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: style ?? textRegular(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: style ?? textRegular().copyWith(color: color ?? Colors.black),
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.symmetric(
          vertical: Dimensions.h16, horizontal: Dimensions.w16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Text(
            'payment_details'.tr,
            style: textSemiBold().copyWith(fontSize: Dimensions.fs16),
          ),
          SizedBox(height: Dimensions.h16),

          // Item price / Subtotal
          if (!parcel)
            _buildRow(
              addOns > 0 ? 'subtotal'.tr : 'product_price'.tr,
              PriceConverterHelper.convertPrice(itemsPrice),
            ),
          if (addOns > 0) ...[
            SizedBox(height: Dimensions.h10),
            _buildRow(
              'addons'.tr,
              PriceConverterHelper.convertPrice(addOns),
            ),
            Divider(
              thickness: 1,
              color: Theme.of(context).hintColor.withOpacity(0.5),
            ),
            SizedBox(height: Dimensions.h10),
            _buildRow(
              'subtotal'.tr,
              PriceConverterHelper.convertPrice(subTotal),
              style: textMedium(),
            ),
            SizedBox(height: Dimensions.h10),
          ],

          // Discount
          if (!parcel && discount > 0) ...[
            _buildRow(
              'discount'.tr,
              '(-) ${PriceConverterHelper.convertPrice(discount)}',
              color: ManagerColors.darkGreen,
            ),
            SizedBox(height: Dimensions.h10),
          ],

          // Coupon discount
          if (couponDiscount > 0) ...[
            _buildRow(
              'coupon_discount'.tr,
              '(-) ${PriceConverterHelper.convertPrice(couponDiscount)}',
              color: ManagerColors.darkGreen,
            ),
            SizedBox(height: Dimensions.h10),
          ],

          // Referrer bonus
          if (referrerBonusAmount > 0) ...[
            _buildRow(
              'referral_discount'.tr,
              '(-) ${PriceConverterHelper.convertPrice(referrerBonusAmount)}',
              color: ManagerColors.darkGreen,
            ),
            SizedBox(height: Dimensions.h10),
          ],

          // Delivery Fee
          _buildRow(
            'delivery_fee'.tr,
            PriceConverterHelper.convertPrice(deliveryCharge),
          ),
          SizedBox(height: Dimensions.h10),

          // Delivery Man Tips (مع الحفاظ على شرط parcel و config)
          if (!parcel && dmTips > 0) ...[
            _buildRow(
              'delivery_man_tips'.tr,
              '(+) ${PriceConverterHelper.convertPrice(dmTips)}',
            ),
            SizedBox(height: Dimensions.h10),
          ],

          // Extra Packaging
          if (extraPackagingAmount > 0) ...[
            _buildRow(
              'extra_packaging'.tr,
              '(+) ${PriceConverterHelper.convertPrice(extraPackagingAmount)}',
            ),
            SizedBox(height: Dimensions.h10),
          ],

          // Additional Charge
          if (additionalCharge > 0) ...[
            _buildRow(
              'additional_charge'.tr,
              '(+) ${PriceConverterHelper.convertPrice(additionalCharge)}',
            ),
            SizedBox(height: Dimensions.h10),
          ],

          // Tax
          if (!taxIncluded && tax > 0) ...[
            _buildRow(
              'vat_tax'.tr,
              '(+) ${PriceConverterHelper.convertPrice(tax)}',
            ),
            SizedBox(height: Dimensions.h10),
          ],

          // Divider قبل Total
          Divider(
            color: Theme.of(context).disabledColor.withOpacity(0.3),
            thickness: 1,
          ),
          SizedBox(height: Dimensions.h10),

          // Total / Due Payment
          _buildRow(
            partialPay ? 'due_payment'.tr : 'total'.tr,
            PriceConverterHelper.convertPrice(total),
            style: textSemiBold().copyWith(fontSize: Dimensions.fs16),
          ),
        ],
      ),
    );
  }
}
