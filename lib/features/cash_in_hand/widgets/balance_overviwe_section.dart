import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/wallet_account_section.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/transaction_bottom_sheet.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/theme_extension.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/wallet_withdraw_sheet.dart';

class BalanceOverviewSection extends StatelessWidget {
  final ProfileController profileController;

  const BalanceOverviewSection({super.key, required this.profileController});

  String _money(double? v) =>
      v == null ? '—' : PriceConverterHelper.convertPrice(v);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CustomColorsExtension custom =
        theme.extension<CustomColorsExtension>()!;

    final wallet = Get.find<CashInHandController>().wallet;
    final profile = profileController.profileModel!;
    final String? blockMessage = (wallet != null && !wallet.canRequestWithdraw)
        ? wallet.withdrawBlock?.message
        : null;
    final bool canWithdraw = wallet != null &&
        wallet.canRequestWithdraw &&
        wallet.availableBalance > 0;
    final double? cashRaw = wallet?.cashInHand ?? profile.cashInHands;
    final bool hasCash =
        (cashRaw ?? 0) > 0 || (profile.payableBalance ?? 0) > 0;

    return Column(
      children: [
        /// Available Balance Section
        CustomCard(
          width: context.width,
          fillColor: theme.scaffoldBackgroundColor,
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.w16,
            vertical: Dimensions.h16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'available_to_withdraw'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textMedium().copyWith(
                            color: scheme.onSurfaceVariant,
                            fontSize: Dimensions.fs14,
                          ),
                        ),
                        SizedBox(height: Dimensions.h8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            _money(wallet?.availableBalance),
                            style: textBold().copyWith(
                              fontSize: Dimensions.fs32,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: Dimensions.w8),
                  SizedBox(
                    width: Dimensions.w120,
                    height: Dimensions.w120,
                    child: Image.asset(
                      ManagerAssets.balanceImage,
                      fit: BoxFit.contain,
                      matchTextDirection: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.h8),
              CustomButtonWidget(
                buttonText: 'wallet_request_withdraw'.tr,
                autoWidth: true,
                fontSize: Dimensions.fs16,
                backgroundColor:
                    canWithdraw ? theme.primaryColor : custom.disabledButton,
                fontColor: canWithdraw ? null : scheme.onSurfaceVariant,
                onPressed: () {
                  if (wallet == null) return;
                  if (!wallet.canRequestWithdraw) {
                    showCustomSnackBar(wallet.withdrawBlock?.message ??
                        'wallet_withdraw_unavailable'.tr);
                    return;
                  }
                  if (wallet.availableBalance <= 0) {
                    showCustomSnackBar('wallet_withdraw_no_balance'.tr);
                    return;
                  }
                  if (wallet.accounts.isEmpty) {
                    showCustomSnackBar('wallet_withdraw_add_account_first'.tr);
                    showWalletAccountSheet();
                    return;
                  }
                  showWithdrawSheet();
                },
              ),
            ],
          ),
        ),

        // رسالة السيرفر إذا السحب غير متاح حالياً
        if (blockMessage != null && blockMessage.isNotEmpty) ...[
          SizedBox(height: Dimensions.h10),
          Text(
            blockMessage,
            textAlign: TextAlign.center,
            style: textRegular().copyWith(
              fontSize: Dimensions.fs12,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        SizedBox(height: Dimensions.h16),

        /// Cash (actionable, wider) + Total withdrawn (info only, quieter)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: _CashTile(
                  title: 'cash_in_hand'.tr,
                  value: _money(wallet?.cashInHand ?? profile.cashInHands),
                  showSettle: hasCash,
                  settleText: 'wallet_settle_cash'.tr,
                  onSettle: () =>
                      showCustomBottomSheet(child: TransactionBottomSheet()),
                ),
              ),
              SizedBox(width: Dimensions.w12),
              Expanded(
                flex: 2,
                child: _WithdrawnTile(
                  title: 'total_withdrawn'.tr,
                  value: _money(
                      wallet?.totalWithdrawn ?? profile.totalWithdrawn),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.h20),
        const WalletAccountSection(),
      ],
    );
  }
}

class _CashTile extends StatelessWidget {
  final String title;
  final String value;
  final bool showSettle;
  final String settleText;
  final VoidCallback onSettle;

  const _CashTile({
    required this.title,
    required this.value,
    required this.showSettle,
    required this.settleText,
    required this.onSettle,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    // Asphalt + white in light, yellow + asphalt in dark (same as the brand buttons).
    final Color btnBg = isDark ? scheme.primary : scheme.onSurface;
    final Color btnFg = isDark ? scheme.onPrimary : scheme.surface;

    return CustomCard(
      padding: EdgeInsets.all(Dimensions.w16),
      fillColor: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textMedium().copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: Dimensions.fs13,
            ),
          ),
          SizedBox(height: Dimensions.h8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: textBold().copyWith(
                fontSize: Dimensions.fs20,
                color: scheme.onSurface,
              ),
            ),
          ),
          if (showSettle) ...[
            const Spacer(),
            SizedBox(height: Dimensions.h12),
            Material(
              color: btnBg,
              borderRadius: BorderRadius.circular(Dimensions.r20),
              child: InkWell(
                borderRadius: BorderRadius.circular(Dimensions.r20),
                onTap: onSettle,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: Dimensions.h8),
                  alignment: Alignment.center,
                  child: Text(
                    settleText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textBold().copyWith(
                      fontSize: Dimensions.fs13,
                      color: btnFg,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WithdrawnTile extends StatelessWidget {
  final String title;
  final String value;

  const _WithdrawnTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return CustomCard(
      padding: EdgeInsets.all(Dimensions.w16),
      fillColor: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textMedium().copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: Dimensions.fs13,
            ),
          ),
          SizedBox(height: Dimensions.h8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: textBold().copyWith(
                fontSize: Dimensions.fs16,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}