import 'package:doghree_rider/common/widgets/circle_icon_button.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/balance_overviwe_section.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/transaction_history_section.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/wallet_account_section.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/withdrawal_history_section.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/util/dimensions.dart';

class CashInHandScreen extends StatefulWidget {
  const CashInHandScreen({super.key});

  @override
  State<CashInHandScreen> createState() => _CashInHandScreenState();
}

class _CashInHandScreenState extends State<CashInHandScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.find<ProfileController>().getProfile();
      final cash = Get.find<CashInHandController>();
      cash.getWalletProvidedEarningList();
      cash.getWallet();
      cash.getWithdrawals();
    });
  }

  Future<void> _onRefresh() async {
    final cash = Get.find<CashInHandController>();
    try {
      await Future.wait([
        Get.find<ProfileController>().getProfile(),
        cash.getWallet(),
        cash.getWithdrawals(),
        cash.getWalletProvidedEarningList(),
      ]);
    } catch (e) {
      debugPrint('REFRESH error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
        title: 'balance'.tr,
        isBackButtonExist: true,
        actionWidget: CircleIconButton(
          iconAsset: ManagerAssets.earningsIcon,
          tooltip: 'wallet_earnings_details'.tr,
          onTap: () => Get.toNamed(RouteHelper.getMyEarningRoute()),
        ),
      ),
      body: Container(
        color: Theme.of(context).cardColor,
        margin: EdgeInsets.only(top: Dimensions.h16),
        child: GetBuilder<ProfileController>(builder: (profileController) {
          if (profileController.profileModel == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              padding: EdgeInsets.fromLTRB(
                Dimensions.w16,
                Dimensions.h20,
                Dimensions.w16,
                Dimensions.h25,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BalanceOverviewSection(profileController: profileController),
                  SizedBox(height: Dimensions.h20),
                  const WalletAccountSection(),
                  SizedBox(height: Dimensions.h25),
                  const WithdrawalHistorySection(),
                  const TransactionHistorySection(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
