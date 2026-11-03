import 'package:doghree_rider/features/wallet/domain/models/earning_report_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/dashed_line_widget.dart';
import 'package:doghree_rider/helper/date_converter_helper.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

/// Shown inside showCustomBottomSheet, which already adds the handle,
/// background and close button, so the content only shrinks to fit.
class EarningHistoryBottomSheet extends StatelessWidget {
  final Data data;

  const EarningHistoryBottomSheet({super.key, required this.data});

  double get _fee => data.originalDeliveryCharge ?? 0;
  double get _tip => data.dmTips ?? 0;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Flexible(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          Dimensions.w20,
          Dimensions.h4,
          Dimensions.w20,
          Dimensions.h20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'earning_details'.tr,
              textAlign: TextAlign.center,
              style: textBold().copyWith(
                fontSize: Dimensions.fs16,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: Dimensions.h16),
            _Hero(
              total: _fee + _tip,
              orderId: data.order?.id,
              createdAt: data.createAt,
            ),
            SizedBox(height: Dimensions.h16),
            DashedLine(color: cs.onSurfaceVariant.withValues(alpha: 0.35)),
            SizedBox(height: Dimensions.h8),
            _AmountRow(label: 'delivery_fee'.tr, value: _fee),
            _AmountRow(label: 'delivery_tips'.tr, value: _tip),
            SizedBox(height: Dimensions.h8),
            Divider(height: 1, thickness: 1, color: cs.outline),
            SizedBox(height: Dimensions.h8),
            _AmountRow(label: 'total'.tr, value: _fee + _tip, isTotal: true),
          ],
        ),
      ),
    );
  }
}

/// Big total, then the order number and date under it.
class _Hero extends StatelessWidget {
  final double total;
  final int? orderId;
  final String? createdAt;

  const _Hero({
    required this.total,
    required this.orderId,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            PriceConverterHelper.convertPrice(total),
            textDirection: TextDirection.ltr,
            style: textBold().copyWith(
              fontSize: Dimensions.fs32,
              height: 1.2,
              color: cs.onSurface,
            ),
          ),
        ),
        SizedBox(height: Dimensions.h4),
        Wrap(
          spacing: Dimensions.w12,
          runSpacing: Dimensions.h2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${'order'.tr} #$orderId',
              style: textMedium().copyWith(
                fontSize: Dimensions.fs14,
                color: cs.onSurface,
              ),
            ),
            if (createdAt != null)
              Text(
                DateConverterHelper.utcToDateTime(createdAt!),
                textDirection: TextDirection.ltr,
                style: textRegular().copyWith(
                  fontSize: Dimensions.fs12,
                  color: cs.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Label at the start, amount at the end. [isTotal] makes it the bold line.
class _AmountRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;

  const _AmountRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.h6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: (isTotal ? textBold() : textRegular()).copyWith(
                fontSize: isTotal ? Dimensions.fs16 : Dimensions.fs14,
                color: isTotal ? cs.onSurface : cs.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(width: Dimensions.w16),
          Text(
            PriceConverterHelper.convertPrice(value),
            textDirection: TextDirection.ltr,
            style: (isTotal ? textBold() : textMedium()).copyWith(
              fontSize: isTotal ? Dimensions.fs16 : Dimensions.fs14,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}