import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/order_shimmer_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/order_card_widget.dart';
import 'package:sixam_mart_delivery/features/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/common/widgets/title_widget.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/features/order/screens/running_order_screen.dart';
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

      return  Container(
        margin: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
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
            SizedBox(height: hasActiveOrder ? Dimensions.paddingSizeSmall : 0),
            if (orderController.currentOrderList == null)
              OrderShimmerWidget(isEnabled: true)
            else if (orderController.currentOrderList!.isNotEmpty)
              Column(
                children: [
                  SizedBox(
                    height: 240,
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
                  const SizedBox(height: Dimensions.paddingSizeDefault),
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
