import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/confirmation_bottom_sheet.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_model.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/wallet_account_details.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/wallet_account_sheet.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/wallet_common_widgets.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

void _confirmDeleteAccount(BuildContext context, int id) {
  showCustomBottomSheet(
    child: ConfirmationBottomSheet(
      title: 'wallet_delete_account'.tr,
      description: 'wallet_delete_account_confirm'.tr,
      acceptText: 'wallet_delete'.tr,
      acceptColor: Theme.of(context).colorScheme.error,
      cancelText: 'wallet_cancel'.tr,
      onCancel: () => Navigator.of(context).pop(),
      onAccept: () {
        Navigator.of(context).pop();
        Get.find<CashInHandController>().deleteWalletAccount(id);
      },
    ),
  );
}

class WalletAccountSection extends StatelessWidget {
  const WalletAccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CashInHandController>(builder: (c) {
      final WalletModel? wallet = c.wallet;

      // Wallet not loaded yet (or failed to load)
      if (wallet == null) {
        return _UnavailableCard(
          isLoading: c.walletLoading,
          onRetry: () => c.getWallet(),
        );
      }

      if (wallet.accounts.isEmpty) return const _EmptyAccountCard();

      final WalletAccount account = wallet.accounts
          .firstWhere((a) => a.isDefault, orElse: () => wallet.accounts.first);

      return _AccountCard(
        account: account,
        onDelete: () => _confirmDeleteAccount(context, account.id),
      );
    });
  }
}

class _UnavailableCard extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRetry;

  const _UnavailableCard({required this.isLoading, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return WalletCard(
      padding: EdgeInsets.all(Dimensions.w20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'wallet_payout_account'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textMedium().copyWith(
                fontSize: Dimensions.fs14,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          if (isLoading)
            SizedBox(
              width: Dimensions.w20,
              height: Dimensions.w20,
              child: CircularProgressIndicator(strokeWidth: Dimensions.w2),
            )
          else
            InkWell(
              customBorder: const CircleBorder(),
              onTap: onRetry,
              child: Padding(
                padding: EdgeInsets.all(Dimensions.w4),
                child: Icon(Icons.refresh, color: cs.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyAccountCard extends StatelessWidget {
  const _EmptyAccountCard();

  @override
  Widget build(BuildContext context) {
    final Color? textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return WalletCard(
      padding: EdgeInsets.all(Dimensions.w20),
      child: Column(
        children: [
          _AccountHeading(
            leading: const _AddAccountBadge(),
            headline: 'wallet_no_account'.tr,
          ),
          SizedBox(height: Dimensions.h16),
          CustomButtonWidget(
            buttonText: 'wallet_add_account'.tr,
            onPressed: showWalletAccountSheet,
            isBorder: true,
            transparent: true,
            textColor: textColor,
            borderColor: textColor,
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final WalletAccount account;
  final VoidCallback onDelete;

  const _AccountCard({required this.account, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return WalletCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              Dimensions.w20,
              Dimensions.h16,
              Dimensions.w8,
              Dimensions.h16,
            ),
            child: _AccountHeading(
              leading: WalletMethodAvatar(
                name: account.methodName,
                size: _avatarSize,
              ),
              headline: account.methodName,
              trailing: _DeleteButton(onTap: onDelete),
            ),
          ),
          if (account.summary.trim().isNotEmpty) ...[
            const WalletDashedDivider(vertical: 0),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                Dimensions.w20,
                Dimensions.h12,
                Dimensions.w20,
                Dimensions.h12,
              ),
              child: WalletAccountDetails(
                methodName: account.methodName,
                fields: account.fields,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

double get _avatarSize => Dimensions.w24 + Dimensions.w20;

/// Avatar slot + small caption + headline.
class _AccountHeading extends StatelessWidget {
  final Widget leading;
  final String headline;
  final Widget? trailing;

  const _AccountHeading({
    required this.leading,
    required this.headline,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        leading,
        SizedBox(width: Dimensions.w12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'wallet_payout_account'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textMedium().copyWith(
                  fontSize: Dimensions.fs12,
                  color: cs.onSurfaceVariant,
                ),
              ),
              SizedBox(height: Dimensions.h2),
              Text(
                headline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textBold().copyWith(
                  fontSize: Dimensions.fs16,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// "+" badge for the no-account state.
class _AddAccountBadge extends StatelessWidget {
  const _AddAccountBadge();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.primaryContainer,
      ),
      child: Icon(
        Icons.add_rounded,
        size: Dimensions.w24,
        color: cs.onPrimaryContainer,
      ),
    );
  }
}

/// Quiet delete action: the confirmation sheet is the real safeguard.
class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(Dimensions.w12),
        child: Icon(
          Icons.delete_outline_rounded,
          size: Dimensions.w20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}