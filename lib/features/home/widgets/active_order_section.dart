import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/order_shimmer_widget.dart';
import 'package:wefrh_rider/features/home/widgets/order_card_widget.dart';
import 'package:wefrh_rider/features/order/controllers/order_controller.dart';
import 'package:wefrh_rider/common/widgets/title_widget.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/features/order/screens/running_order_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ActiveOrderSection extends StatefulWidget {
  const ActiveOrderSection({super.key});

  @override
  State<ActiveOrderSection> createState() => _ActiveOrderSectionState();
}

class _ActiveOrderSectionState extends State<ActiveOrderSection> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<OrderController>();

    return GetBuilder<OrderController>(builder: (_) {
      bool hasActiveOrder = orderController.currentOrderList != null &&
          orderController.currentOrderList!.isNotEmpty;
      bool hasMoreOrder = orderController.currentOrderList != null &&
          orderController.currentOrderList!.length > 1;

      return Container(
        margin: EdgeInsets.only(top: Dimensions.h20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasActiveOrder)
              TitleWidget(
                title: 'active_orders'.tr,
                showOrderCount: true,
                orderCount: orderController.currentOrderList?.length ?? 0,
                onTap: hasMoreOrder
                    ? () {
                        Get.toNamed(
                          RouteHelper.getRunningOrderRoute(),
                          arguments: const RunningOrderScreen(),
                        );
                      }
                    : null,
              ),
            SizedBox(height: hasActiveOrder ? Dimensions.h10 : 0),
            if (orderController.currentOrderList == null)
              OrderShimmerWidget(isEnabled: true)
            else if (orderController.currentOrderList!.isNotEmpty)
              Column(
                children: [
                  SizedBox(
                    height: Dimensions.h260,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: orderController.currentOrderList!.length,
                      itemBuilder: (context, index) {
                        return OrderCardWidget(
                          order: orderController.currentOrderList![index],
                          index: index,
                          isRunningOrder: true,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: Dimensions.h16),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: orderController.currentOrderList!.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: Theme.of(context).primaryColor,
                      dotColor: Theme.of(context).disabledColor,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 6,
                    ),
                  ),
                ],
              )
            else
              const SizedBox(),
          ],
        ),
      );
    });
  }
}
