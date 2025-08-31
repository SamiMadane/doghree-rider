import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:get/get.dart';

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
      {TextStyle? style, required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: style ??
                  robotoRegular.copyWith(
                    fontSize: Dimensions.fs14,
                    color: Theme.of(context).hintColor,
                  )),
          Text(value,
              style: style ??
                  robotoRegular.copyWith(
                    fontSize: Dimensions.fs14,
                    color: Theme.of(context).hintColor,
                  )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(Dimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'payment_details'.tr,
            style: robotoSemiBold.copyWith(
              fontSize: Dimensions.fs16,
            ),
          ),
          const SizedBox(height: Dimensions.p10),

          // Item price
          if (!parcel)
            _buildRow(
                'product_price'.tr, PriceConverterHelper.convertPrice(itemsPrice),
                context: context),

          // Addons
          if (addOns > 0)
            _buildRow(
                'addons'.tr, '${PriceConverterHelper.convertPrice(addOns)}',
                context: context),

          if (addOns > 0)
            Divider(
              thickness: 1,
              color: Theme.of(context).hintColor.withOpacity(0.5),
            ),

          // Subtotal
          if (addOns > 0)
            _buildRow(
                'subtotal'.tr, PriceConverterHelper.convertPrice(subTotal),
                style: robotoMedium, context: context),

          // Discount
          if (!parcel)
            _buildRow(
                'discount'.tr, '${PriceConverterHelper.convertPrice(discount)}',
                style: robotoRegular.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                context: context),

          // Coupon discount
          if (couponDiscount > 0)
            _buildRow('coupon_discount'.tr,
                '${PriceConverterHelper.convertPrice(couponDiscount)}',
                style: robotoRegular.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                context: context),

          // Referrer bonus
          if (referrerBonusAmount > 0)
            _buildRow('referral_discount'.tr,
                '${PriceConverterHelper.convertPrice(referrerBonusAmount)}',
                style: robotoRegular.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                context: context),

          // Delivery fee
          _buildRow('delivery_fee'.tr,
              '${PriceConverterHelper.convertPrice(deliveryCharge)}',
              context: context),

          // Delivery man tips
          _buildRow('delivery_man_tips'.tr,
              '${PriceConverterHelper.convertPrice(dmTips)}',
              context: context),

          // Extra packaging
          if (extraPackagingAmount > 0)
            _buildRow('extra_packaging'.tr,
                '${PriceConverterHelper.convertPrice(extraPackagingAmount)}',
                context: context),

          // Additional charge
          if (additionalCharge > 0)
            _buildRow('additional_charge'.tr,
                '${PriceConverterHelper.convertPrice(additionalCharge)}',
                context: context),

          // Tax
          if (tax > 0 && !taxIncluded)
            _buildRow('vat_tax'.tr, '${PriceConverterHelper.convertPrice(tax)}',
                context: context),

          const SizedBox(height: Dimensions.p10),

          _buildRow(
            'total'.tr,
            PriceConverterHelper.convertPrice(total),
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fs16,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
            context: context,
          ),
        ],
      ),
    );
  }
}
