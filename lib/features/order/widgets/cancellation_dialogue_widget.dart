import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';

class CancellationDialogueWidget extends StatelessWidget {
  final int? orderId;
  const CancellationDialogueWidget({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    Get.find<OrderController>().getOrderCancelReasons();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.r4)),
      insetPadding: EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: GetBuilder<OrderController>(builder: (orderController) {
        return SizedBox(
          width: 500, height: MediaQuery.of(context).size.height * 0.6,
          child: Column(children: [

            Container(
              width: 500,
              padding: EdgeInsets.symmetric(vertical: Dimensions.h10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: Get.isDarkMode ? null : [BoxShadow(color: Colors.grey[200]!, spreadRadius: 1, blurRadius: 5)],
              ),
              child: Column(children: [
                Text('select_cancellation_reasons'.tr, style: textMedium().copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fs16)),
                SizedBox(height: Dimensions.h4),
              ]),
            ),

            Expanded(
              child: orderController.orderCancelReasons != null ? orderController.orderCancelReasons!.isNotEmpty ? ListView.builder(
                itemCount: orderController.orderCancelReasons!.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.w10),
                    child: ListTile(
                      onTap: (){
                        orderController.setOrderCancelReason(orderController.orderCancelReasons![index].reason);
                      },
                      title: Row(children: [

                        Icon(orderController.orderCancelReasons![index].reason == orderController.cancelReason ? Icons.radio_button_checked : Icons.radio_button_off, color: Theme.of(context).primaryColor, size: 18),
                        SizedBox(width: Dimensions.w4),

                        Flexible(child: Text(orderController.orderCancelReasons![index].reason!, style: textRegular(), maxLines: 3, overflow: TextOverflow.ellipsis)),

                      ]),
                    ),
                  );
                },
              ) : Center(child: Text('no_reasons_available'.tr)) : const Center(child: CircularProgressIndicator()),
            ),
            SizedBox(height: Dimensions.h4),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.fs14, vertical: Dimensions.h10),
              child: !orderController.isLoading ? Row(children: [

                Expanded(child: CustomButtonWidget(
                  buttonText: 'cancel'.tr, backgroundColor: Theme.of(context).disabledColor, radius: 50,
                  onPressed: () => Get.back(),
                )),
                SizedBox(width: Dimensions.w10),

                Expanded(child: CustomButtonWidget(
                  buttonText: 'submit'.tr,  radius: 50,
                  onPressed: (){
                    if(orderController.cancelReason != '' && orderController.cancelReason != null){
                      orderController.updateOrderStatus(OrderModel(id: orderId), AppConstants.canceled, back: true, reason: orderController.cancelReason).then((success) {
                        if(success) {
                          Get.find<ProfileController>().getProfile();
                          Get.find<OrderController>().getCurrentOrders();
                        }
                      });
                    }else{
                      if(Get.isDialogOpen!){
                        Get.back();
                      }
                      showCustomSnackBar('you_did_not_select_select_any_reason'.tr);
                    }
                  },
                )),
              ]) : const Center(child: CircularProgressIndicator()),
            ),
          ]),
        );
      }),
    );
  }
}
