import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/empty_state_widget.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/widgets/history_order_widget.dart';
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
    final OrderController c = Get.find<OrderController>();
    if (!_scrollController.hasClients) return;
    final ScrollPosition pos = _scrollController.position;

    // نبدأ التحميل قبل نهاية القائمة بقليل بدل انتظار الوصول للنهاية بالضبط
    final bool nearEnd = pos.pixels >= pos.maxScrollExtent - 200;
    if (nearEnd && c.completedOrderList != null && !c.paginate) {
      final int totalPages = ((c.pageSize ?? 0) / 10).ceil();
      if (c.offset < totalPages) {
        c.setOffset(c.offset + 1);
        c.showBottomLoader();
        c.getCompletedOrders(c.offset);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar:
          CustomAppBarWidget(title: 'my_orders'.tr, isBackButtonExist: false),
      body: Container(
        color: Theme.of(context).cardColor,
        margin: EdgeInsets.only(top: Dimensions.h16),
        child: GetBuilder<OrderController>(builder: (orderController) {
          final List? orders = orderController.completedOrderList;
        
          if (orders == null) {
            return Center(
              child: CircularProgressIndicator(color: scheme.onSurface),
            );
          }
        
          if (orders.isEmpty) {
            return EmptyStateWidget(
              image: ManagerAssets.noOrderImage,
              imageScale: 1.1,
              title: 'no_order_found'.tr,
              buttonText: 'back_to_home_screen'.tr,
              onButtonPressed: () {
                Get.offAllNamed(RouteHelper.getInitialRoute());
              },
            );
          }
        
          return RefreshIndicator(
            color: scheme.onPrimary,
            backgroundColor: scheme.primary,
            onRefresh: () async {
              await orderController.getCompletedOrders(1);
            },
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                Dimensions.w16,
                Dimensions.h16,
                Dimensions.w16,
                Dimensions.h16,
              ),
              itemCount: orders.length + (orderController.paginate ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= orders.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimensions.h16),
                    child: Center(
                      child: CircularProgressIndicator(color: scheme.onSurface),
                    ),
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
      ),
    );
  }
}