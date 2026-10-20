import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/screens/order_details_screen.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';

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
      padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
      margin: EdgeInsetsDirectional.only(end: Dimensions.w16),
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
                        style: textSemiBold().copyWith(
                          fontSize: Dimensions.fs14,
                          color: Theme.of(context).hintColor, // لون رمادي
                        ),
                      ),
                      TextSpan(
                        text: '#${order.id}', 
                        style: textSemiBold().copyWith(
                          fontSize: Dimensions.fs14,
                          color: ManagerColors.darkGreen, 
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
                    EdgeInsets.symmetric(horizontal: Dimensions.w12, vertical: Dimensions.h4),
                fillColor: order.paymentStatus == 'paid'
                    ? ManagerColors.greenLightMode
                    : Theme.of(context).colorScheme.error,
                borderRadius: Dimensions.r20,
                child: Text(
                  order.paymentStatus == 'paid' ? 'paid'.tr : 'unpaid'.tr,
                  style: textMedium().copyWith(
                    color: ManagerColors.white,
                    fontSize: Dimensions.fs14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.h16),

          // أيقونات + خطوط
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  ClipOval(
                    child: CustomImageWidget(
                        image:
                            order.storeLogoFullUrl,
                        width: Dimensions.w28,
                        height: Dimensions.h28),
                  ),
                  SizedBox(
                    height: Dimensions.h40,
                    child: DottedLine(
                      direction: Axis.vertical,
                      lineLength: double.infinity,
                      dashLength: 8,
                      dashColor: Theme.of(context).disabledColor,
                    ),
                  ),
                  SvgPicture.asset(ManagerAssets.locationIcon,
                      width: Dimensions.w24, height: Dimensions.h24),
                ],
              ),
              SizedBox(width: Dimensions.w8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.storeName!,
                        style:
                            textSemiBold().copyWith(fontSize: Dimensions.fs14)),
                    Text(order.storeAddress!,
                        style: textRegular().copyWith(
                            fontSize: Dimensions.fs14,
                            color: Theme.of(context).hintColor)),
                    SizedBox(height: Dimensions.h4),
                    if (parcel)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal:Dimensions.w4 ,vertical: Dimensions.h4,),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.r4),
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                        child: Text('parcel'.tr,
                            style: textMedium().copyWith(
                                fontSize: Dimensions.fs10,
                                color: Theme.of(context).primaryColor)),
                      ),
                    SizedBox(height: Dimensions.h20),
                    Text(
                        parcel
                            ? order.deliveryAddress.toString()
                            : order.storeAddress!,
                        style:
                            textSemiBold().copyWith(fontSize: Dimensions.fs14)),
                    Text(parcel ? 'delivery_location'.tr : 'store_location'.tr,
                        style: textRegular().copyWith(
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
