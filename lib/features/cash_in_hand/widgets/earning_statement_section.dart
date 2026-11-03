import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/common/widgets/title_widget.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/earning_report_model.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/earning_history_bottom_sheet.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/wallet_common_widgets.dart';
import 'package:doghree_rider/helper/date_converter_helper.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';

/// Header + one row per earning, straight on the page with hairlines.
class EarningStatementSection extends StatelessWidget {
  final List<Data> earnings;
  final int total;
  final String? type;

  const EarningStatementSection({
    super.key,
    required this.earnings,
    required this.total,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleWidget(
          title: 'earning_statement'.tr,
          showOrderCount: true,
          orderCount: total,
          titleStyle: textBold().copyWith(
            fontSize: Dimensions.fs18,
            color: cs.onSurface,
          ),
        ),
        SizedBox(height: Dimensions.h12),
        WalletActivityList(
          rows: [
            for (final Data earning in earnings)
              EarningTile(earning: earning, type: type),
          ],
        ),
      ],
    );
  }
}

/// One earning: order + date at the start, amount + what it is made of at the end.
class EarningTile extends StatelessWidget {
  final Data earning;
  final String? type;

  const EarningTile({super.key, required this.earning, required this.type});

  double get _fee => earning.originalDeliveryCharge ?? 0;
  double get _tip => earning.dmTips ?? 0;

  double get _amount {
    switch (type) {
      case 'delivery_fee':
        return _fee;
      case 'delivery_tips':
        return _tip;
      default:
        return _fee + _tip;
    }
  }

  String get _kinds {
    final bool showFee =
        type == 'delivery_fee' || (type != 'delivery_tips' && _fee > 0);
    final bool showTip =
        type == 'delivery_tips' || (type != 'delivery_fee' && _tip > 0);
    return [
      if (showFee) 'delivery_fee'.tr,
      if (showTip) 'delivery_tips'.tr,
    ].join(' · ');
  }

  String get _date => earning.createAt == null
      ? ''
      : DateConverterHelper.utcToDateTime(earning.createAt!);

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => showCustomBottomSheet(
        child: EarningHistoryBottomSheet(data: earning),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Dimensions.h14),
        child: Row(
          children: [
            const _EarningAvatar(),
            SizedBox(width: Dimensions.w12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'order'.tr} #${earning.order?.id}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textMedium().copyWith(
                      fontSize: Dimensions.fs14,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(height: Dimensions.h2),
                  Text(
                    _date,
                    textDirection: TextDirection.ltr,
                    style: textRegular().copyWith(
                      fontSize: Dimensions.fs12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: Dimensions.w12),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: Dimensions.w120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    PriceConverterHelper.convertPrice(_amount),
                    textDirection: TextDirection.ltr,
                    style: textBold().copyWith(
                      fontSize: Dimensions.fs16,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(height: Dimensions.h2),
                  Text(
                    _kinds,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textMedium().copyWith(
                      fontSize: Dimensions.fs12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningAvatar extends StatelessWidget {
  const _EarningAvatar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: WalletActivityRow.avatarSize,
      height: WalletActivityRow.avatarSize,
      child: Image.asset(
        ManagerAssets.earningOrderImage,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}