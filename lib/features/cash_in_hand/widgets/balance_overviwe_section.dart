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
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/wallet_withdraw_sheet.dart';

class BalanceOverviewSection extends StatelessWidget {
  final ProfileController profileController;

  const BalanceOverviewSection({Key? key, required this.profileController})
      : super(key: key);

  String _money(double? v) =>
      v == null ? '—' : PriceConverterHelper.convertPrice(v);

  @override
  Widget build(BuildContext context) {
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
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.r4),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.w16,
                    vertical: Dimensions.h16,
                  ),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      Flexible(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'available_to_withdraw'.tr,
                              style: textRegular().copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: Dimensions.fs16,
                              ),
                            ),
                            SizedBox(height: Dimensions.h16),
                            Text(
                              _money(wallet?.availableBalance),
                              style: textBold().copyWith(
                                fontSize: Dimensions.fs28,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                            ),
                            SizedBox(height: Dimensions.h16),
                            CustomButtonWidget(
                              buttonText: 'wallet_request_withdraw'.tr,
                              fontSize: Dimensions.fs16,
                              backgroundColor: canWithdraw
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor,
                              onPressed: () {
                                if (wallet == null) return;
                                if (!wallet.canRequestWithdraw) {
                                  showCustomSnackBar(
                                      wallet.withdrawBlock?.message ??
                                          'wallet_withdraw_unavailable'.tr);
                                  return;
                                }
                                if (wallet.availableBalance <= 0) {
                                  showCustomSnackBar(
                                      'wallet_withdraw_no_balance'.tr);
                                  return;
                                }
                                if (wallet.accounts.isEmpty) {
                                  showCustomSnackBar(
                                      'wallet_withdraw_add_account_first'.tr);
                                  showWalletAccountSheet();
                                  return;
                                }
                                showWithdrawSheet();
                              },
                            )
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        child: Container(),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.5,
                      maxHeight: 150,
                    ),
                    child: Image.asset(
                      ManagerAssets.balanceImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
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
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
        if (hasCash)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () =>
                  showCustomBottomSheet(child: TransactionBottomSheet()),
              child: Text('wallet_settle_cash'.tr),
            ),
          ),
        SizedBox(height: Dimensions.h20),

        /// Cash Info Section
        Row(
          children: [
            Expanded(
              child: CustomCard(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.w16,
                  vertical: Dimensions.h16,
                ),
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'cash_in_hand'.tr,
                      style: textRegular().copyWith(
                        color: Theme.of(context).disabledColor,
                        fontSize: Dimensions.fs14,
                      ),
                    ),
                    SizedBox(height: Dimensions.h16),
                    Text(
                      _money(wallet?.cashInHand ?? profile.cashInHands),
                      style: textBold().copyWith(
                        fontSize: Dimensions.fs16,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: Dimensions.w16),
            Expanded(
              child: CustomCard(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.w16,
                  vertical: Dimensions.h16,
                ),
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'total_withdrawn'.tr,
                      style: textRegular().copyWith(
                        color: Theme.of(context).disabledColor,
                        fontSize: Dimensions.fs14,
                      ),
                    ),
                    SizedBox(height: Dimensions.h16),
                    Text(
                      _money(wallet?.totalWithdrawn ?? profile.totalWithdrawn),
                      style: textBold().copyWith(
                        fontSize: Dimensions.fs16,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Dimensions.h20),
        const WalletAccountSection(),
      ],
    );
  }
}
