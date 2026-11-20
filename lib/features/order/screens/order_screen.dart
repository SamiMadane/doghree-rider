import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/empty_state_widget.dart';
import 'package:doghree_rider/common/widgets/no_internet_screen.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/widgets/history_order_widget.dart';
import 'package:doghree_rider/features/order/widgets/history_page_footer_widget.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<OrderController>().getCompletedOrders(1, willUpdate: false);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final ScrollPosition pos = _scrollController.position;

    // Start loading slightly before the end of the list. The controller
    // decides whether a page is allowed (one in flight, none after a failure).
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      Get.find<OrderController>().loadNextHistoryPage();
    }
  }

  /// A page can be too short to scroll (orders without items are filtered
  /// out), so the next page loads by itself until the screen is full, the
  /// history ends, or a page fails.
  void _fillIfShort() {
    if (!mounted || !_scrollController.hasClients) return;
    final OrderController c = Get.find<OrderController>();
    final bool fillsScreen = _scrollController.position.maxScrollExtent > 0;
    if (c.historyNeedsFill(fillsScreen: fillsScreen)) {
      c.loadNextHistoryPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.cardColor,
      appBar:
          CustomAppBarWidget(title: 'my_orders'.tr, isBackButtonExist: false),
      body: GetBuilder<OrderController>(builder: (orderController) {
        final List<dynamic>? orders = orderController.completedOrderList;

        if (orders == null && orderController.completedOrdersFailed) {
          return NoInternetScreen(
            onRetry: () => orderController.getCompletedOrders(1),
          );
        }

        if (orders == null) {
          return Center(child: CircularProgressIndicator(color: cs.onSurface));
        }

        if (orders.isEmpty) {
          return EmptyStateWidget(
            image: ManagerAssets.noOrderImage,
            imageScale: 1.1,
            title: 'no_order_found'.tr,
            buttonText: 'back_to_home_screen'.tr,
            onButtonPressed: () =>
                Get.offAllNamed(RouteHelper.getInitialRoute()),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _fillIfShort());

        final bool showFooter =
            orderController.paginate || orderController.historyPageFailed;

        return RefreshIndicator(
          color: cs.onPrimary,
          backgroundColor: cs.primary,
          onRefresh: () => orderController.getCompletedOrders(1),
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              Dimensions.w16,
              Dimensions.h16 + Dimensions.h16,
              Dimensions.w16,
              Dimensions.h24,
            ),
            itemCount: orders.length + (showFooter ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= orders.length) {
                return HistoryPageFooterWidget(
                  isLoading: orderController.paginate,
                  failed: orderController.historyPageFailed,
                  onRetry: orderController.retryHistoryPage,
                );
              }
              return HistoryOrderWidget(
                orderModel: orders[index],
                isRunning: false,
                index: index,
              );
            },
          ),
        );
      }),
    );
  }
}