import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/earning_report_model.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/animated_amount_text.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/wallet_common_widgets.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';

/// Hero card: total earning, then delivery fees and tips side by side.
class EarningSummaryCard extends StatelessWidget {
  final EarningReportModel? report;

  const EarningSummaryCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final double fees = report?.totalDeliveryCharge ?? 0;
    final double tips = report?.totalDmTips ?? 0;

    return WalletCard(
      child: Stack(
        children: [
          PositionedDirectional(
            end: Dimensions.w8,
            top: Dimensions.h8,
            width: Dimensions.w95,
            height: Dimensions.h95,
            child: IgnorePointer(
              child: Image.asset(
                ManagerAssets.doghreeCoins,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  Dimensions.w20,
                  Dimensions.h18,
                  Dimensions.w20,
                  0,
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: Dimensions.w108),
                  child: _TotalAmount(value: fees + tips),
                ),
              ),
              SizedBox(height: Dimensions.h25),
              const WalletDashedDivider(),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  Dimensions.w20,
                  Dimensions.h4,
                  Dimensions.w20,
                  Dimensions.h18,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _BreakdownCell(
                        label: 'delivery_fee_earned'.tr,
                        value: fees,
                      ),
                    ),
                    const _VerticalHairline(),
                    Expanded(
                      child: _BreakdownCell(
                        label: 'delivery_tips_earned'.tr,
                        value: tips,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Label + big animated number.
class _TotalAmount extends StatelessWidget {
  final double value;

  const _TotalAmount({required this.value});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'total_earning'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textMedium().copyWith(
            fontSize: Dimensions.fs13,
            color: cs.onSurfaceVariant,
          ),
        ),
        SizedBox(height: Dimensions.h4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: AnimatedAmountText(
            value: value,
            style: textBold().copyWith(
              fontSize: Dimensions.fs34,
              height: 1.2,
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _BreakdownCell extends StatelessWidget {
  final String label;
  final double value;

  const _BreakdownCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Dot(),
            SizedBox(width: Dimensions.w8),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textMedium().copyWith(
                  fontSize: Dimensions.fs13,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Dimensions.h4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            PriceConverterHelper.convertPrice(value),
            style: textBold().copyWith(
              fontSize: Dimensions.fs20,
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// Same yellow dot used on the home and balance cards.
class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: Dimensions.h2),
      child: Container(
        width: Dimensions.w14,
        height: Dimensions.w14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.primaryColor,
          border: Border.all(color: theme.colorScheme.onPrimary, width: 1),
        ),
      ),
    );
  }
}

class _VerticalHairline extends StatelessWidget {
  const _VerticalHairline();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: Dimensions.h40,
      margin: EdgeInsets.symmetric(horizontal: Dimensions.w16),
      color: Theme.of(context).colorScheme.outline,
    );
  }
}