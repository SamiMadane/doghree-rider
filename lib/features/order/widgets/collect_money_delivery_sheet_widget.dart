import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CollectMoneyDeliverySheetWidget extends StatelessWidget {
  final OrderModel currentOrderModel;
  final bool? verify;
  final bool? cod;
  final double? orderAmount;
  final bool isSenderPay;
  final bool? isParcel;
  const CollectMoneyDeliverySheetWidget({super.key, required this.currentOrderModel, required this.verify, required this.orderAmount,
    required this.cod, this.isSenderPay = false, this.isParcel = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.grey.shade900 : Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: GetBuilder<OrderController>(builder: (orderController) {

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.w20, vertical: Dimensions.h20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            Container(
              height: 5, width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.r16),
                color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
              ),
            ),

            cod! ? Column(children: [
              SizedBox(height: Dimensions.h20),

              Image.asset(ManagerAssets.deliveredSuccess, height: 100, width: 100),
              SizedBox(height: Dimensions.h10),

              Text(
                'collect_money_from_customer'.tr, textAlign: TextAlign.center,
                style: textMedium().copyWith(fontSize: Dimensions.fs16),
              ),
              SizedBox(height: Dimensions.h20),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  '${'order_amount'.tr}:', textAlign: TextAlign.center,
                  style: textBold().copyWith(fontSize: Dimensions.fs16),
                ),
                SizedBox(width: Dimensions.w4),
                Text(
                  PriceConverterHelper.convertPrice(orderAmount), textAlign: TextAlign.center,
                  style: textBold().copyWith(fontSize: Dimensions.fs16, color: Theme.of(context).primaryColor),
                ),
              ]),
              SizedBox(height: verify! ? 20 : 40),
            ]) : Column(children: [
              SizedBox(height: Dimensions.h20),

              Image.asset(ManagerAssets.deliveredSuccess, height: 100, width: 100),
              SizedBox(height: Dimensions.h10),

              Text(
                'want_to_complete_the_order'.tr, textAlign: TextAlign.center,
                style: textMedium().copyWith(fontSize: Dimensions.fs16),
              ),
              SizedBox(height: Dimensions.h20),
              SizedBox(height: verify! ? 20 : 40),
            ]),

           !orderController.isLoading ? CustomButtonWidget(
              buttonText: 'ok'.tr,
              radius: Dimensions.r10,
              margin: EdgeInsets.only(bottom: Dimensions.h10),
              onPressed: () {

                if(verify!){
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                } else{
                  Get.find<OrderController>().updateOrderStatus(currentOrderModel, isSenderPay ? 'picked_up' : 'delivered', parcel: isParcel).then((success) {
                    if(success) {
                      Get.find<ProfileController>().getProfile();
                      Get.find<OrderController>().getCurrentOrders();
                      if(!isSenderPay) {
                        Get.offAllNamed(RouteHelper.getInitialRoute());
                      }
                    }
                  });
                }
              },
            ) : const Center(child: CircularProgressIndicator()),

            SizedBox(height: Dimensions.h20),
          ]),
        );
      }),
    );
  }
}
