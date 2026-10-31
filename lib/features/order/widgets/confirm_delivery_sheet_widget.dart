import 'package:doghree_rider/common/widgets/replay_image.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/theme_extension.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfirmDeliverySheetWidget extends StatelessWidget {
  final OrderModel currentOrderModel;
  const ConfirmDeliverySheetWidget({super.key, required this.currentOrderModel});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
              'want_to_complete_the_order'.tr,
              textAlign: TextAlign.center,
              style: textMedium().copyWith(fontSize: Dimensions.fs16),
            ),

            SizedBox(height: Dimensions.h24),

            !orderController.isLoading
                ? CustomButtonWidget(
                    buttonText: 'ok'.tr,
                    radius: Dimensions.r10,
                    onPressed: () {
                      Get.find<OrderController>()
                          .updateOrderStatus(currentOrderModel, 'delivered',
                              parcel: false)
                          .then((success) {
                        if (success) {
                          Get.find<ProfileController>().getProfile();
                          Get.find<OrderController>().getCurrentOrders();
                          Get.offAllNamed(RouteHelper.getInitialRoute());
                        }
                      });
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