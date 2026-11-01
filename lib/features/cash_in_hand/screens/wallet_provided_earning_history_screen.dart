import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/empty_state_widget.dart';
import 'package:doghree_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/transaction_history_section.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';

class WalletProvidedHistoryScreen extends StatefulWidget {
  const WalletProvidedHistoryScreen({super.key});

  @override
  State<WalletProvidedHistoryScreen> createState() =>
      _WalletProvidedHistoryScreenState();
}

class _WalletProvidedHistoryScreenState
    extends State<WalletProvidedHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.find<CashInHandController>().getWalletProvidedEarningList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(title: 'wallet_provided_earning_history'.tr),
      body: Container(
        color: Theme.of(context).cardColor,
        margin: EdgeInsets.only(top: Dimensions.h16),
        child: GetBuilder<CashInHandController>(builder: (c) {
        final list = c.walletProvidedTransactions;

        if (list == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (list.isEmpty) {
          return EmptyStateWidget(
            image: ManagerAssets.noTransactionImage,
            title: 'no_transaction_found'.tr,
            description: 'get_ready_receive_first_order_track_earnings'.tr,
            spacing: Dimensions.h4,
          );
        }

        return ListView(
          padding: EdgeInsets.fromLTRB(
            Dimensions.w16,
            Dimensions.h20,
            Dimensions.w16,
            Dimensions.h25,
          ),
          children: [TransactionsList(transactions: list)],
        );
      }),
      ),
    );
  }
}