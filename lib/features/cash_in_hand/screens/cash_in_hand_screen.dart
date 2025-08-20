import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/cash_in_hand/widgets/balance_overviwe_section.dart';
import 'package:sixam_mart_delivery/features/cash_in_hand/widgets/transaction_history_section.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/features/cash_in_hand/widgets/wallet_attention_alert_widget.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';

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
                    margin: const EdgeInsets.only(
                        top: Dimensions.paddingSizeDefault),
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(children: [
                            BalanceOverviewSection(
                                profileController: profileController),
                            const SizedBox(
                                height: Dimensions.paddingSizeExtraLarge),
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
              : const Center(child: CircularProgressIndicator());
        });
      }),
    );
  }
}
