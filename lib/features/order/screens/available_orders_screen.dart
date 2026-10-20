import 'dart:async';
import 'package:doghree_rider/common/widgets/empty_state_widget.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/features/order/widgets/order_requset_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/util/manager_assets.dart';

class AvailableOrdersScreen extends StatefulWidget {
  final Function onTap;
  const AvailableOrdersScreen({super.key, required this.onTap});

  @override
  AvailableOrdersScreenState createState() => AvailableOrdersScreenState();
}

class AvailableOrdersScreenState extends State<AvailableOrdersScreen> {
  Timer? _timer;

  @override
  initState() {
    super.initState();

    if (Get.find<ProfileController>().profileModel == null) {
      Get.find<ProfileController>().getProfile();
    }

    Get.find<OrderController>().getLatestOrders();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      Get.find<OrderController>().getLatestOrders();
    });
  }

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
          title: 'available_orders'.tr, isBackButtonExist: false),
      body: Container(
        color: Theme.of(context).cardColor,
        margin: EdgeInsets.only(top: Dimensions.h16),
        child: GetBuilder<OrderController>(builder: (orderController) {
          return orderController.latestOrderList != null
              ? orderController.latestOrderList!.isNotEmpty
                  ? RefreshIndicator(
                      onRefresh: () async {
                        await Get.find<OrderController>().getLatestOrders();
                      },
                      child: ListView.builder(
                        itemCount: orderController.latestOrderList!.length,
                        padding:
                            EdgeInsets.symmetric(horizontal:Dimensions.w10 ,vertical: Dimensions.h10,),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return OrderRequestWidget(
                              orderModel:
                                  orderController.latestOrderList![index],
                              index: index,
                              onTap: widget.onTap);
                        },
                      ),
                    )
                  : EmptyStateWidget(
                    image: ManagerAssets.noOrderImage,
                    imageScale: 1.3,
                    spacing: Dimensions.h40,
                    title: 'no_order_request_available'.tr,
                                    
                  )
              : const Center(child: CircularProgressIndicator());
        }),
      ),
    );
  }
}
