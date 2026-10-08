import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/features/cash_in_hand/widgets/balance_overviwe_section.dart';
import 'package:wefrh_rider/features/cash_in_hand/widgets/transaction_history_section.dart';
import 'package:wefrh_rider/features/profile/controllers/profile_controller.dart';
import 'package:wefrh_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:wefrh_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:wefrh_rider/features/cash_in_hand/widgets/wallet_attention_alert_widget.dart';
import 'package:wefrh_rider/util/dimensions.dart';

class CashInHandScreen extends StatefulWidget {
  const CashInHandScreen({super.key});

  @override
  State<CashInHandScreen> createState() => _CashInHandScreenState();
}

class _CashInHandScreenState extends State<CashInHandScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    Get.find<ProfileController>().getProfile();
    Get.find<CashInHandController>().getWalletPaymentList();
    Get.find<CashInHandController>().getWalletProvidedEarningList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Get.find<ProfileController>().profileModel == null) {
      Get.find<ProfileController>().getProfile();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
        title: 'balance'.tr,
        isBackButtonExist: true,
      ),
      body: GetBuilder<CashInHandController>(builder: (cashInHandController) {
        return GetBuilder<ProfileController>(builder: (profileController) {
          return (profileController.profileModel != null &&
                  cashInHandController.transactions != null)
              ? RefreshIndicator(
                  onRefresh: () async {
                    profileController.getProfile();
                    Get.find<CashInHandController>().getWalletPaymentList();
                    Get.find<CashInHandController>()
                        .getWalletProvidedEarningList();
                    return await Future.delayed(const Duration(seconds: 1));
                  },
                  child: Container(
                    color: Theme.of(context).cardColor,
                    margin: EdgeInsets.only(top: Dimensions.h16),
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.w16,
                      vertical: Dimensions.h16,
                    ),
                    child: Column(children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(children: [
                            BalanceOverviewSection(
                                profileController: profileController),
                            SizedBox(height: Dimensions.h25),
                            TransactionHistorySection(
                                cashInHandController: cashInHandController),
                          ]),
                        ),
                      ),
                      (profileController.profileModel!.overFlowWarning! ||
                              profileController
                                  .profileModel!.overFlowBlockWarning!)
                          ? WalletAttentionAlertWidget(
                              isOverFlowBlockWarning: profileController
                                  .profileModel!.overFlowBlockWarning!)
                          : const SizedBox(),
                    ]),
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(top: Dimensions.h16),
                  color: Theme.of(context).cardColor,
                  child: const Center(child: CircularProgressIndicator()));
        });
      }),
    );
  }
}
