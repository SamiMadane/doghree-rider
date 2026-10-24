import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';

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

  Widget _buildRow(
    BuildContext context,
    String label,
    String value, {
    TextStyle? style,
    Color? color,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final TextStyle base = style ?? textRegular();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: base.copyWith(
              color: style == null ? scheme.onSurfaceVariant : scheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: base.copyWith(color: color ?? scheme.onSurface),
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return CustomCard(
      padding: EdgeInsets.symmetric(
        vertical: Dimensions.h16,
        horizontal: Dimensions.w16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'payment_details'.tr,
            style: textSemiBold().copyWith(fontSize: Dimensions.fs16),
          ),
          SizedBox(height: Dimensions.h16),

          if (!parcel)
            _buildRow(
              context,
              addOns > 0 ? 'subtotal'.tr : 'product_price'.tr,
              PriceConverterHelper.convertPrice(itemsPrice),
            ),
          if (addOns > 0) ...[
            SizedBox(height: Dimensions.h10),
            _buildRow(
              context,
              'addons'.tr,
              PriceConverterHelper.convertPrice(addOns),
            ),
            Divider(thickness: 1, color: scheme.outline),
            SizedBox(height: Dimensions.h10),
            _buildRow(
              context,
              'subtotal'.tr,
              PriceConverterHelper.convertPrice(subTotal),
              style: textMedium(),
            ),
            SizedBox(height: Dimensions.h10),
          ],

          if (!parcel && discount > 0) ...[
            _buildRow(
              context,
              'discount'.tr,
              '(-) ${PriceConverterHelper.convertPrice(discount)}',
              color: scheme.tertiary,
            ),
            SizedBox(height: Dimensions.h10),
          ],

          if (couponDiscount > 0) ...[
            _buildRow(
              context,
              'coupon_discount'.tr,
              '(-) ${PriceConverterHelper.convertPrice(couponDiscount)}',
              color: scheme.tertiary,
            ),
            SizedBox(height: Dimensions.h10),
          ],

          if (referrerBonusAmount > 0) ...[
            _buildRow(
              context,
              'referral_discount'.tr,
              '(-) ${PriceConverterHelper.convertPrice(referrerBonusAmount)}',
              color: scheme.tertiary,
            ),
            SizedBox(height: Dimensions.h10),
          ],

          _buildRow(
            context,
            'delivery_fee'.tr,
            PriceConverterHelper.convertPrice(deliveryCharge),
          ),
          SizedBox(height: Dimensions.h10),

          if (!parcel && dmTips > 0) ...[
            _buildRow(
              context,
              'delivery_man_tips'.tr,
              '(+) ${PriceConverterHelper.convertPrice(dmTips)}',
            ),
            SizedBox(height: Dimensions.h10),
          ],

          if (extraPackagingAmount > 0) ...[
            _buildRow(
              context,
              'extra_packaging'.tr,
              '(+) ${PriceConverterHelper.convertPrice(extraPackagingAmount)}',
            ),
            SizedBox(height: Dimensions.h10),
          ],

          if (additionalCharge > 0) ...[
            _buildRow(
              context,
              'additional_charge'.tr,
              '(+) ${PriceConverterHelper.convertPrice(additionalCharge)}',
            ),
            SizedBox(height: Dimensions.h10),
          ],

          if (!taxIncluded && tax > 0) ...[
            _buildRow(
              context,
              'vat_tax'.tr,
              '(+) ${PriceConverterHelper.convertPrice(tax)}',
            ),
            SizedBox(height: Dimensions.h10),
          ],

          Divider(color: scheme.outline, thickness: 1),
          SizedBox(height: Dimensions.h10),

          _buildRow(
            context,
            partialPay ? 'due_payment'.tr : 'total'.tr,
            PriceConverterHelper.convertPrice(total),
            style: textSemiBold().copyWith(fontSize: Dimensions.fs16),
          ),
        ],
      ),
    );
  }
}