import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:wefrh_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:wefrh_rider/features/cash_in_hand/widgets/withdrawal_history_section.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';

class WithdrawalsScreen extends StatefulWidget {
  const WithdrawalsScreen({super.key});

  @override
  State<WithdrawalsScreen> createState() => _WithdrawalsScreenState();
}

class _WithdrawalsScreenState extends State<WithdrawalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.find<CashInHandController>().getWithdrawals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
          title: 'wallet_withdraw_requests'.tr, isBackButtonExist: true),
      body: Padding(
        padding: EdgeInsets.only(top: Dimensions.h16),
        child: Container(
          color: Theme.of(context).cardColor,
          child: GetBuilder<CashInHandController>(builder: (c) {
            final list = c.withdrawals;
            return RefreshIndicator(
              onRefresh: () => c.getWithdrawals(),
              child: list == null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 60),
                        Center(
                          child: c.withdrawalsFailed
                              ? IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () => c.getWithdrawals())
                              : const CircularProgressIndicator(),
                        ),
                      ],
                    )
                  : list.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 60),
                            Center(
                              child: Text('wallet_no_withdrawals'.tr,
                                  style: textRegular().copyWith(
                                      color: Theme.of(context).hintColor)),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(Dimensions.w16),
                          itemCount: list.length,
                          itemBuilder: (_, i) => WithdrawalTile(item: list[i]),
                        ),
            );
          }),
        ),
      ),
    );
  }
}