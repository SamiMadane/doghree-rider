import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/order_shimmer_widget.dart';
import 'package:doghree_rider/features/home/widgets/order_card_widget.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/common/widgets/title_widget.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/features/order/screens/running_order_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ActiveOrderSection extends StatefulWidget {
  const ActiveOrderSection({super.key});

  @override
  State<ActiveOrderSection> createState() => _ActiveOrderSectionState();
}

class _ActiveOrderSectionState extends State<ActiveOrderSection> {
  // الكرت التالي يظهر جزئياً عند وجود أكثر من طلب
  final PageController _pageController = PageController(viewportFraction: 0.92);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<OrderController>();

    return GetBuilder<OrderController>(builder: (_) {
      final orders = orderController.currentOrderList;
      final bool hasActiveOrder = orders != null && orders.isNotEmpty;
      final bool hasMoreOrder = orders != null && orders.length > 1;

      return Container(
        margin: EdgeInsets.only(top: Dimensions.h20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasActiveOrder)
              TitleWidget(
                title: 'active_orders'.tr,
                showOrderCount: true,
                orderCount: orders.length,
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
            if (orders == null)
              SizedBox(
                height: Dimensions.h260,
                  child: OrderShimmerWidget(
                      isEnabled: true, margin: EdgeInsets.zero))
            else if (orders.isNotEmpty)
              Column(
                children: [
                  SizedBox(
                    height: Dimensions.h260,
                    child: hasMoreOrder
                        ? PageView.builder(
                            controller: _pageController,
                            padEnds: false,
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              return OrderCardWidget(
                                order: orders[index],
                                index: index,
                                isRunningOrder: true,
                                margin: EdgeInsetsDirectional.only(
                                    end: Dimensions.w10),
                              );
                            },
                          )
                        // طلب واحد: عرض كامل بنفس padding الصفحة (16)
                        : OrderCardWidget(
                            order: orders.first,
                            index: 0,
                            isRunningOrder: true,
                            margin: EdgeInsets.zero,
                          ),
                  ),
                  if (hasMoreOrder) ...[
                    SizedBox(height: Dimensions.h16),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: orders.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: Theme.of(context).primaryColor,
                        dotColor: Theme.of(context).disabledColor,
                        dotHeight: 8,
                        dotWidth: 8,
                        spacing: 6,
                      ),
                    ),
                  ],
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
