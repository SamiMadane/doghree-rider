import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/app_shimmer.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/features/wallet/controllers/wallet_controller.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_model.dart';
import 'package:doghree_rider/features/wallet/widgets/animated_amount_text.dart';
import 'package:doghree_rider/features/wallet/widgets/wallet_account_sheet.dart';
import 'package:doghree_rider/features/wallet/widgets/wallet_common_widgets.dart';
import 'package:doghree_rider/features/wallet/widgets/wallet_withdraw_sheet.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/theme_extension.dart';

/// Hero card: available balance, withdraw action, total withdrawn.
class BalanceOverviewSection extends StatelessWidget {
  final ProfileController profileController;

  const BalanceOverviewSection({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(builder: (c) {
      final WalletModel? wallet = c.wallet;
      final double? withdrawn = wallet?.totalWithdrawn ??
          profileController.profileModel?.totalWithdrawn;

      return WalletCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                Dimensions.w20,
                Dimensions.h18,
                Dimensions.w20,
                0,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _AvailableAmount(
                          wallet: wallet,
                          isLoading: c.walletLoading,
                        ),
                      ),
                      SizedBox(width: Dimensions.w8),
                      SizedBox(
                        width: Dimensions.w95,
                        height: Dimensions.h95,
                        child: Image.asset(
                          ManagerAssets.balanceImage,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.h16),
                  _WithdrawButton(wallet: wallet),
                ],
              ),
            ),
            WalletDashedDivider(vertical: Dimensions.h18),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                Dimensions.w20,
                0,
                Dimensions.w20,
                Dimensions.h18,
              ),
              child: _TotalWithdrawnRow(value: withdrawn),
              
            ),
          ],
        ),
      );
    });
  }
}

/// Label + big animated number.
class _AvailableAmount extends StatelessWidget {
  final WalletModel? wallet;
  final bool isLoading;

  const _AvailableAmount({required this.wallet, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextStyle amountStyle = textBold().copyWith(
      fontSize: Dimensions.fs34,
      height: 1.2,
      color: cs.onSurface,
    );
    final double? value = wallet?.availableBalance;

    final Widget amount;
    if (value != null) {
      amount = FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: AnimatedAmountText(value: value, style: amountStyle),
      );
    } else if (isLoading) {
      amount = AppShimmerBlock(
        width: Dimensions.w120,
        height: Dimensions.h40,
        radius: Dimensions.r8,
      );
    } else {
      amount = Text('—', style: amountStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'available_to_withdraw'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textMedium().copyWith(
            fontSize: Dimensions.fs13,
            color: cs.onSurfaceVariant,
          ),
        ),
        SizedBox(height: Dimensions.h4),
        amount,
      ],
    );
  }
}

class _WithdrawButton extends StatelessWidget {
  final WalletModel? wallet;

  const _WithdrawButton({required this.wallet});

  void _onPressed() {
    final WalletModel? w = wallet;
    if (w == null) return;
    if (!w.canRequestWithdraw) {
      showCustomSnackBar(
          w.withdrawBlock?.message ?? 'wallet_withdraw_unavailable'.tr);
      return;
    }
    if (w.availableBalance <= 0) {
      showCustomSnackBar('wallet_withdraw_no_balance'.tr);
      return;
    }
    if (w.accounts.isEmpty) {
      showCustomSnackBar('wallet_withdraw_add_account_first'.tr);
      showWalletAccountSheet();
      return;
    }
    showWithdrawSheet();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final CustomColorsExtension custom =
        theme.extension<CustomColorsExtension>()!;
        

    final WalletModel? w = wallet;
    final bool canWithdraw =
        w != null && w.canRequestWithdraw && w.availableBalance > 0;
    // Server message when withdrawing is blocked right now.
    final String? blockMessage =
        (w != null && !w.canRequestWithdraw) ? w.withdrawBlock?.message : null;

    return Column(
      children: [
        CustomButtonWidget(
          buttonText: 'wallet_request_withdraw'.tr,
          fontSize: Dimensions.fs16,
          backgroundColor:
              canWithdraw ? theme.primaryColor : custom.disabledButton,
          fontColor: canWithdraw ? null : cs.onSurfaceVariant,
          onPressed: _onPressed,
        ),
        if (blockMessage != null && blockMessage.isNotEmpty) ...[
          SizedBox(height: Dimensions.h10),
          Text(
            blockMessage,
            textAlign: TextAlign.center,
            style: textRegular().copyWith(
              fontSize: Dimensions.fs12,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Secondary info, same pattern as "Total Earnings" on home.
class _TotalWithdrawnRow extends StatelessWidget {
  final double? value;

  const _TotalWithdrawnRow({required this.value});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: Dimensions.w14,
          height: Dimensions.w14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.primaryColor,
            border: Border.all(color: cs.onPrimary, width: 1),
          ),
        ),
        SizedBox(width: Dimensions.w8),
        Expanded(
          child: Text(
            'total_withdrawn'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textMedium().copyWith(
              fontSize: Dimensions.fs13,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value == null ? '—' : PriceConverterHelper.convertPrice(value!),
          style: textBold().copyWith(
            fontSize: Dimensions.fs14,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}
