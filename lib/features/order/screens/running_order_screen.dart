import 'package:wefrh_rider/features/order/controllers/order_controller.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:wefrh_rider/features/order/widgets/history_order_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RunningOrderScreen extends StatelessWidget {
  const RunningOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'running_orders'.tr),
      body: Container(
             padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
        margin: EdgeInsets.only(top: Dimensions.h16),
        color: Theme.of(context).cardColor,
        height: double.maxFinite,
        child: GetBuilder<OrderController>(builder: (orderController) {
        
          return orderController.currentOrderList != null ? orderController.currentOrderList!.isNotEmpty ? RefreshIndicator(
            onRefresh: () async {
              await orderController.getCurrentOrders();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(child: SizedBox(
                width: 1170,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal:Dimensions.w10 ,vertical: Dimensions.h10,),
                  itemCount: orderController.currentOrderList!.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return HistoryOrderWidget(orderModel: orderController.currentOrderList![index], isRunning: true, index: index);
                  },
                ),
              )),
            ),
          ) : Center(child: Text('no_order_found'.tr)) : const Center(child: CircularProgressIndicator());
        }),
      ),
    );
  }
}
