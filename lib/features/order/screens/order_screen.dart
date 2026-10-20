import 'package:flutter/material.dart';
import 'package:doghree_rider/common/widgets/empty_state_widget.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/features/order/widgets/history_order_widget.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/util/manager_assets.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<OrderController>().getCompletedOrders(1, willUpdate: false);
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          Get.find<OrderController>().completedOrderList != null &&
          !Get.find<OrderController>().paginate) {
        int pageSize = (Get.find<OrderController>().pageSize! / 10).ceil();
        if (Get.find<OrderController>().offset < pageSize) {
          Get.find<OrderController>()
              .setOffset(Get.find<OrderController>().offset + 1);
          debugPrint('end of the page');
          Get.find<OrderController>().showBottomLoader();
          Get.find<OrderController>()
              .getCompletedOrders(Get.find<OrderController>().offset);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          CustomAppBarWidget(title: 'my_orders'.tr, isBackButtonExist: false),
      body: GetBuilder<OrderController>(builder: (orderController) {
        return orderController.completedOrderList != null
            ? orderController.completedOrderList!.isNotEmpty
                ? RefreshIndicator(
                    onRefresh: () async {
                      await orderController.getCompletedOrders(1);
                    },
                    child: Container(
                      color: Theme.of(context).cardColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.w16,
                        vertical: Dimensions.h16,
                      ),
                      margin: EdgeInsets.only(top: Dimensions.h16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height -
                              kToolbarHeight, // يأخذ ارتفاع الشاشة كامل بدون AppBar
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount:
                                    orderController.completedOrderList!.length,
                                itemBuilder: (context, index) {
                                  return HistoryOrderWidget(
                                    orderModel: orderController
                                        .completedOrderList![index],
                                    isRunning: false,
                                    index: index,
                                  );
                                },
                              ),
                            ),
                            orderController.paginate
                                ? Center(
                                    child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimensions.w10,
                                      vertical: Dimensions.h10,
                                    ),
                                    child: CircularProgressIndicator(),
                                  ))
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  )
                : Container(
                    margin: EdgeInsets.only(top: Dimensions.h16),
                    color: Theme.of(context).cardColor,
                    child: EmptyStateWidget(
                      image: ManagerAssets.noOrderImage,
                      imageScale: 1.1,
                      title: 'no_order_found'.tr,
                      buttonText: 'back_to_home_screen'.tr,
                      onButtonPressed: () {
                        Get.offAllNamed(RouteHelper.getInitialRoute());
                      },
                    ),
                  )
            : Container(
                margin: EdgeInsets.only(top: Dimensions.h16),
                color: Theme.of(context).cardColor,
                child: const Center(child: CircularProgressIndicator()));
      }),
    );
  }
}
