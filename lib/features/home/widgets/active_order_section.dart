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
    return GetBuilder<OrderController>(builder: (orderController) {
      final orders = orderController.currentOrderList;

      // تحميل: الشيمر يظهر بنفس مسافة الكرت الحقيقي
      if (orders == null) {
        return Container(
          margin: EdgeInsets.only(top: Dimensions.h20),
          height: Dimensions.h260,
          child: OrderShimmerWidget(isEnabled: true, margin: EdgeInsets.zero),
        );
      }

      // لا طلبات: لا مسافة ولا ارتفاع
      if (orders.isEmpty) return const SizedBox.shrink();

      final bool hasMoreOrder = orders.length > 1;

      return Container(
        margin: EdgeInsets.only(top: Dimensions.h20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            SizedBox(height: Dimensions.h10),
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
                          margin:
                              EdgeInsetsDirectional.only(end: Dimensions.w10),
                        );
                      },
                    )
                  : OrderCardWidget(
                      order: orders.first,
                      index: 0,
                      isRunningOrder: true,
                      margin: EdgeInsets.zero,
                    ),
            ),
            if (hasMoreOrder) ...[
              SizedBox(height: Dimensions.h16),
              Center(
                child: SmoothPageIndicator(
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
              ),
            ],
          ],
        ),
      );
    });
  }
}
