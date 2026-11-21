import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/history_page_footer_widget.dart';
import 'package:doghree_rider/features/wallet/controllers/wallet_controller.dart';
import 'package:doghree_rider/features/wallet/widgets/withdrawal_history_section.dart';
import 'package:doghree_rider/util/dimensions.dart';

class WithdrawalsScreen extends StatefulWidget {
  const WithdrawalsScreen({super.key});

  @override
  State<WithdrawalsScreen> createState() => _WithdrawalsScreenState();
}

class _WithdrawalsScreenState extends State<WithdrawalsScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.find<WalletController>().getWithdrawals();
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  /// Audit row 42: the next page loads near the end of the list.
  void _onScroll() {
    if (!_scroll.hasClients) return;
    final ScrollPosition p = _scroll.position;
    if (p.pixels >= p.maxScrollExtent - Dimensions.h100) {
      Get.find<WalletController>().loadNextWithdrawalsPage();
    }
  }

  /// A list shorter than the screen cannot scroll, so it loads the next page
  /// by itself until it scrolls, ends or a page fails.
  void _fillIfShort(WalletController c) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final ScrollPosition p = _scroll.position;
      if (p.hasContentDimensions && p.maxScrollExtent <= 0) {
        c.loadNextWithdrawalsPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
          title: 'wallet_withdraw_requests'.tr, isBackButtonExist: true),
      body: Container(
        color: Theme.of(context).cardColor,
        margin: EdgeInsets.only(top: Dimensions.h16),
        child: RefreshIndicator(
          // Page 1 again; a next page still in flight is dropped.
          onRefresh: () => Get.find<WalletController>().getWithdrawals(),
          child: ListView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              Dimensions.w16,
              Dimensions.h20,
              Dimensions.w16,
              Dimensions.h25,
            ),
            children: [
              const WithdrawalsBody(),
              GetBuilder<WalletController>(builder: (c) {
                final bool showFooter =
                    c.withdrawalsLoadingMore || c.withdrawalsPageFailed;
                if (c.hasMoreWithdrawals && !c.withdrawalsPageFailed) {
                  _fillIfShort(c);
                }
                if (!showFooter) return const SizedBox.shrink();
                return HistoryPageFooterWidget(
                  isLoading: c.withdrawalsLoadingMore,
                  failed: c.withdrawalsPageFailed,
                  onRetry: c.retryWithdrawalsPage,
                  failedText: 'wallet_load_more_failed'.tr,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
