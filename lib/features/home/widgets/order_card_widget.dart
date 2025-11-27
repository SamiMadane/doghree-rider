import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/common/widgets/custom_image_widget.dart';
import 'package:wefrh_rider/features/order/domain/models/order_model.dart';
import 'package:wefrh_rider/features/order/screens/order_details_screen.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/styles.dart';

class OrderCardWidget extends StatelessWidget {
  final OrderModel order;
  final int index;
  final bool isRunningOrder;

  const OrderCardWidget({
    super.key,
    required this.order,
    required this.index,
    this.isRunningOrder = true,
  });

  @override
  Widget build(BuildContext context) {
    bool parcel = order.orderType == 'parcel';

    return CustomCard(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(Dimensions.p16),
      margin: const EdgeInsetsDirectional.only(end: Dimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID + حالة الدفع
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${'id_label'.tr}: ', // هذا نص الـ Label للترجمة
                        style: robotoSemiBold.copyWith(
                          fontSize: Dimensions.fs14,
                          color: Theme.of(context).hintColor, // لون رمادي
                        ),
                      ),
                      TextSpan(
                        text: '#${order.id}', // القيمة نفسها
                        style: robotoSemiBold.copyWith(
                          fontSize: Dimensions.fs14,
                          color: ManagerColors.darkGreen, // برايمري كولور
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomCard(
                isBorder: false,
                autoWidth: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                fillColor: order.paymentStatus == 'paid'
                    ? ManagerColors.greenLightMode
                    : Theme.of(context).colorScheme.error,
                borderRadius: Dimensions.r20,
                child: Text(
                  order.paymentStatus == 'paid' ? 'paid'.tr : 'unpaid'.tr,
                  style: robotoMedium.copyWith(
                    color: ManagerColors.white,
                    fontSize: Dimensions.fs14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.p16),

          // أيقونات + خطوط
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  ClipOval(
                    child: CustomImageWidget(
                        image:
                            order.storeLogoFullUrl ?? ManagerAssets.storeImage,
                        width: 28,
                        height: 28),
                  ),
                  SizedBox(
                    height: 40,
                    child: DottedLine(
                      direction: Axis.vertical,
                      lineLength: double.infinity,
                      dashLength: 6,
                      dashColor: Theme.of(context).disabledColor,
                    ),
                  ),
                  SvgPicture.asset(ManagerAssets.locationIcon,
                      width: 24, height: 24),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.storeName!,
                        style:
                            robotoSemiBold.copyWith(fontSize: Dimensions.fs14)),
                    Text(order.storeAddress!,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fs14,
                            color: Theme.of(context).hintColor)),
                    const SizedBox(height: Dimensions.p4),
                    if (parcel)
                      Container(
                        padding: const EdgeInsets.all(Dimensions.p4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.r4),
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                        child: Text('parcel'.tr,
                            style: robotoMedium.copyWith(
                                fontSize: Dimensions.fs10,
                                color: Theme.of(context).primaryColor)),
                      ),
                    const SizedBox(height: Dimensions.p10),
                    Text(
                        parcel
                            ? order.deliveryAddress.toString()
                            : order.storeAddress!,
                        style:
                            robotoSemiBold.copyWith(fontSize: Dimensions.fs14)),
                    Text(parcel ? 'delivery_location'.tr : 'store_location'.tr,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fs14,
                            color: Theme.of(context).hintColor)),
                  ],
                ),
              )
            ],
          ),

          const Spacer(),

          CustomButtonWidget(
            onPressed: () {
              Get.toNamed(
                RouteHelper.getOrderDetailsRoute(order.id),
                arguments: OrderDetailsScreen(
                    orderId: order.id,
                    isRunningOrder: isRunningOrder,
                    orderIndex: index),
              );
            },
            isBorder: true,
            transparent: true,
            textColor: Theme.of(context).textTheme.bodyMedium?.color,
            borderColor: Theme.of(context).textTheme.bodyMedium?.color,
            buttonText: 'details'.tr,
          ),
        ],
      ),
    );
  }
}
