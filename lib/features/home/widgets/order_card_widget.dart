import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_outlined_button.dart';
import 'package:sixam_mart_delivery/features/home/widgets/order_action_row.dart';
import 'package:sixam_mart_delivery/features/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/features/order/screens/order_details_screen.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
    var isArabic =
        Get.locale?.languageCode == AppConstants.languages[1].languageCode;

    return CustomCard(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(Dimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID + حالة الدفع
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
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
              CustomCard(
                width: isArabic ? 90 : 80,
                isBorder: false,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                fillColor: order.paymentStatus == 'paid'
                    ? ManagerColors.success
                    : Theme.of(context).colorScheme.error,
                borderRadius: Dimensions.r20,
                child: Center(
                  child: Text(
                    order.paymentStatus == 'paid' ? 'paid'.tr : 'unpaid'.tr,
                    style: robotoMedium.copyWith(
                      color: ManagerColors.white,
                      fontSize: Dimensions.fs14,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                  Image.asset(ManagerAssets.storeImage, width: 24, height: 24),
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
                        style: robotoSemiBold.copyWith(
                            fontSize: Dimensions.fs14)),
                    Text(order.storeAddress!,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fs14,
                            color: Theme.of(context).hintColor)),
                    const SizedBox(height: Dimensions.p5),
                    if (parcel)
                      Container(
                        padding: const EdgeInsets.all(
                            Dimensions.p5),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.r4),
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
                        style: robotoSemiBold.copyWith(
                            fontSize: Dimensions.fs14)),
                    Text(parcel ? 'Delivery Location' : 'Store Location',
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fs14,
                            color: Theme.of(context).hintColor)),
                  ],
                ),
              )
            ],
          ),

          const Spacer(),

          // Actions
          OrderActionRow(
            textAbove: null,
            actions: [
              Expanded(
                child: CustomOutlinedButton(
                  onPressed: () {
                    Get.toNamed(
                      RouteHelper.getOrderDetailsRoute(order.id),
                      arguments: OrderDetailsScreen(
                          orderId: order.id,
                          isRunningOrder: isRunningOrder,
                          orderIndex: index),
                    );
                  },
                  text: 'details'.tr,
                ),
              ),
              if (parcel) const SizedBox(width: 8),
              if (parcel)
                InkWell(
                  onTap: () async {
                    String url;
                    if (parcel &&
                        order.orderStatus == 'picked_up' &&
                        order.receiverDetails != null) {
                      url =
                          'https://www.google.com/maps/dir/?api=1&destination=${order.receiverDetails!.latitude},${order.receiverDetails!.longitude}&mode=d';
                    } else if (parcel) {
                      url =
                          'https://www.google.com/maps/dir/?api=1&destination=${order.deliveryAddress?.latitude},${order.deliveryAddress?.longitude}&mode=d';
                    } else if (!parcel &&
                        order.orderStatus == 'picked_up' &&
                        order.deliveryAddress != null) {
                      url =
                          'https://www.google.com/maps/dir/?api=1&destination=${order.deliveryAddress!.latitude},${order.deliveryAddress!.longitude}&mode=d';
                    } else {
                      url =
                          'https://www.google.com/maps/dir/?api=1&destination=${order.storeLat ?? '0'},${order.storeLng ?? '0'}&mode=d';
                    }

                    if (await canLaunchUrlString(url)) {
                      await launchUrlString(url,
                          mode: LaunchMode.externalApplication);
                    } else {
                      Get.snackbar('Error', '${'could_not_launch'.tr} $url');
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.directions,
                            color: Theme.of(context).primaryColor, size: 20),
                        const SizedBox(width: 4),
                        Text('direction'.tr,
                            style: robotoMedium.copyWith(
                                color: Theme.of(context).primaryColor)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
