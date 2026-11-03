import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/empty_state_widget.dart';
import 'package:doghree_rider/features/wallet/controllers/wallet_controller.dart';
import 'package:doghree_rider/features/wallet/widgets/earning_app_bar_actions.dart';
import 'package:doghree_rider/features/wallet/widgets/earning_error_state.dart';
import 'package:doghree_rider/features/wallet/widgets/earning_filter_chips_widget.dart';
import 'package:doghree_rider/features/wallet/widgets/earning_statement_section.dart';
import 'package:doghree_rider/features/wallet/widgets/earning_summary_card.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';

class MyEarningScreen extends StatefulWidget {
  const MyEarningScreen({super.key});

  @override
  State<MyEarningScreen> createState() => _MyEarningScreenState();
}

class _MyEarningScreenState extends State<MyEarningScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Must run after the first frame: getEarningReport calls update(), which
    // throws if it happens while another screen listening to the controller
    // (the wallet screen) is still building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final WalletController c = Get.find<WalletController>();
      c.resetEarningFilter(isUpdate: false);
      c.setOffset(1);
      c.getEarningReport(
        offset: '1',
        startDate: null,
        endDate: null,
        type: 'all_types_earning',
      );
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final WalletController c = Get.find<WalletController>();
    final ScrollPosition position = _scrollController.position;
    final bool nearEnd =
        position.pixels >= position.maxScrollExtent - Dimensions.h40;
    if (!nearEnd || c.earningList == null || c.isLoading) return;

    final int pages = ((c.pageSize ?? 0) / 10).ceil();
    if (c.offset >= pages) return;

    c.setOffset(c.offset + 1);
    c.showBottomLoader();
    c.getEarningReport(
      offset: c.offset.toString(),
      startDate: c.from,
      endDate: c.to,
      type: c.selectedEarningType,
      fromFilter: c.isFiltered,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
        title: 'my_earning'.tr,
        actionWidget: const EarningAppBarActions(),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).cardColor,
        margin: EdgeInsets.only(top: Dimensions.h16),
        child: Column(
          children: [
            // Applied-filter chips: hidden when no filter is active.
            SizedBox(
              width: double.infinity,
              child: Wrap(children: [
                EarningFilterChipsWidget(),
              ]),
            ),

            Expanded(
              child: GetBuilder<WalletController>(builder: (c) {
                // Must come before the null check: a failed first page leaves
                // the list null, which would otherwise look like "loading".
                if (c.earningFailed) {
                  return EarningErrorState(onRetry: c.retryEarningReport);
                }

                final list = c.earningList;

                if (list == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (list.isEmpty) {
                  // Filter returned nothing: say so and offer a way out,
                  // instead of the generic "no earnings yet" state.
                  if (c.isFiltered) {
                    return EmptyStateWidget(
                      image: ManagerAssets.noTransactionImage,
                      title: 'no_earning_found'.tr,
                      description: 'no_earning_for_this_filter'.tr,
                      spacing: Dimensions.h4,
                      buttonText: 'reset'.tr,
                      onButtonPressed: c.clearEarningFilter,
                    );
                  }
                  return EmptyStateWidget(
                    image: ManagerAssets.noTransactionImage,
                    title: 'no_earning_found'.tr,
                    description:
                        'get_ready_receive_first_order_track_earnings'.tr,
                    spacing: Dimensions.h10,
                  );
                }

                return SingleChildScrollView(
                  controller: _scrollController,
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
                      EarningSummaryCard(report: c.earningReportModel),
                      SizedBox(height: Dimensions.h25),
                      EarningStatementSection(
                        earnings: list,
                        total: c.pageSize ?? list.length,
                        type: c.selectedEarningType,
                      ),
                      if (c.isLoading)
                        Padding(
                          padding: EdgeInsets.only(top: Dimensions.h16),
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
