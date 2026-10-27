import 'package:doghree_rider/common/widgets/replay_image.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/theme_extension.dart';
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
  const CollectMoneyDeliverySheetWidget(
      {super.key,
      required this.currentOrderModel,
      required this.verify,
      required this.orderAmount,
      required this.cod,
      this.isSenderPay = false,
      this.isParcel = false});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final CustomColorsExtension colors =
        theme.extension<CustomColorsExtension>()!;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: GetBuilder<OrderController>(builder: (orderController) {
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.w20, vertical: Dimensions.h16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // المقبض
            Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.r16),
                color: colors.strock1,
              ),
            ),
            SizedBox(height: Dimensions.h16),

      
            const ReplayImage(
              asset: ManagerAssets.deliveredSuccessAnim,
              size: 200,
            ),
            SizedBox(height: Dimensions.h8),

            Text(
              cod! ? 'collect_money_from_customer'.tr : 'want_to_complete_the_order'.tr,
              textAlign: TextAlign.center,
              style: textMedium().copyWith(fontSize: Dimensions.fs16),
            ),

            if (cod!) ...[
              SizedBox(height: Dimensions.h16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  '${'order_amount'.tr}:',
                  textAlign: TextAlign.center,
                  style: textBold().copyWith(fontSize: Dimensions.fs16),
                ),
                SizedBox(width: Dimensions.w4),
                Text(
                  PriceConverterHelper.convertPrice(orderAmount),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  style: textBold().copyWith(
                    fontSize: Dimensions.fs16,
                    color: cs.onSurface, // was primaryColor (أصفر على أبيض)
                  ),
                ),
              ]),
            ],

            SizedBox(height: Dimensions.h24),

            !orderController.isLoading
                ? CustomButtonWidget(
                    buttonText: 'ok'.tr,
                    radius: Dimensions.r10,
                    onPressed: () {
                      if (verify!) {
                        Get.offAllNamed(RouteHelper.getInitialRoute());
                      } else {
                        Get.find<OrderController>()
                            .updateOrderStatus(currentOrderModel,
                                isSenderPay ? 'picked_up' : 'delivered',
                                parcel: isParcel)
                            .then((success) {
                          if (success) {
                            Get.find<ProfileController>().getProfile();
                            Get.find<OrderController>().getCurrentOrders();
                            if (!isSenderPay) {
                              Get.offAllNamed(RouteHelper.getInitialRoute());
                            }
                          }
                        });
                      }
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
            SizedBox(height: Dimensions.h10),
          ]),
        );
      }),
    );
  }
}