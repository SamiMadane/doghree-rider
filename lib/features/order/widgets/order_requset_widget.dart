import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart_delivery/common/widgets/confirmation_bottom_sheet.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/features/address/controllers/address_controller.dart';
import 'package:sixam_mart_delivery/features/navigation_handler/controllers/navigation_handler_controller.dart';
import 'package:sixam_mart_delivery/features/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/features/order/screens/order_details_screen.dart';
import 'package:sixam_mart_delivery/features/order/screens/order_location_screen.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class OrderRequestWidget extends StatelessWidget {
  final OrderModel orderModel;
  final int index;
  final bool fromDetailsPage;
  final Function onTap;

  const OrderRequestWidget({
    super.key,
    required this.orderModel,
    required this.index,
    required this.onTap,
    this.fromDetailsPage = false,
  });

  @override
  Widget build(BuildContext context) {
    bool parcel = orderModel.orderType == 'parcel';

    double distance = Get.find<AddressController>().getRestaurantDistance(
      LatLng(
        double.parse(parcel
            ? orderModel.deliveryAddress?.latitude ?? '0'
            : orderModel.storeLat ?? '0'),
        double.parse(parcel
            ? orderModel.deliveryAddress?.longitude ?? '0'
            : orderModel.storeLng ?? '0'),
      ),
    );

    return CustomCard(
      padding: const EdgeInsets.all(Dimensions.p16),
      child: GetBuilder<OrderController>(builder: (orderController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID + Time + Payment + Earning
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${'order_id'.tr}: ', // هذا نص الـ Label للترجمة
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fs14,
                          color: Theme.of(context).hintColor, // لون رمادي
                        ),
                      ),
                      TextSpan(
                        text: '#${orderModel.id}', // القيمة نفسها
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fs14,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color, // برايمري كولور
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: Dimensions.p8,
                ),
                Text(
                  '${DateConverterHelper.timeDistanceInMin(orderModel.createdAt!)} ${'mins_ago'.tr}',
                  style: robotoRegular.copyWith(
                      color: ManagerColors.darkGreen,
                      fontSize: Dimensions.fs10),
                ),
                Spacer(),
                Row(
                  children: [
                    (Get.find<NavigationHandlerController>()
                                .configModel!
                                .showDmEarning! &&
                            Get.find<ProfileController>().profileModel !=
                                null &&
                            Get.find<ProfileController>()
                                    .profileModel!
                                    .earnings ==
                                1)
                        ? Text(
                            PriceConverterHelper.convertPrice(
                                orderModel.originalDeliveryCharge! +
                                    orderModel.dmTips!),
                            style: robotoSemiBold.copyWith(
                                fontSize: Dimensions.fs14),
                          )
                        : const SizedBox(),
                    SizedBox(
                      width: Dimensions.p8,
                    ),
                    Text(
                      '${orderModel.paymentMethod == 'cash_on_delivery' ? 'cod'.tr : orderModel.paymentMethod == 'wallet' ? 'wallet'.tr : 'paid'.tr}',
                      style: robotoSemiBold.copyWith(
                        fontSize: Dimensions.fs14,
                        color: orderModel.paymentMethod == 'cash_on_delivery'
                            ? ManagerColors.orangeLightMode
                            : orderModel.paymentMethod == 'wallet'
                                ? ManagerColors.darkGreen
                                : ManagerColors.darkGreen,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: Dimensions.p16),

            // ICONS + DOTTED LINE + CONTENT
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // left icons with dotted line
                Column(
                  children: [
                    parcel
                        ? ClipOval(
                            child: Image.asset(ManagerAssets.storeImage,
                                width: 30, height: 30),
                          )
                        : ClipOval(
                            child: CustomImageWidget(
                                image: orderModel.storeLogoFullUrl ?? '',
                                height: 30,
                                width: 30,
                                fit: BoxFit.cover),
                          ),
                    SizedBox(
                      height: 60,
                      child: DottedLine(
                        direction: Axis.vertical,
                        lineLength: double.infinity,
                        dashLength: 6,
                        dashColor: Theme.of(context).disabledColor,
                      ),
                    ),
                    SvgPicture.asset(
                      ManagerAssets.locationIcon,
                      width: 25,
                      height: 25,
                    ),
                  ],
                ),
                const SizedBox(width: Dimensions.p8),

                // right content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // store/parcel + distance
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      parcel
                                          ? orderModel.parcelCategory?.name ??
                                              ''
                                          : orderModel.storeName ?? '',
                                      style: robotoSemiBold.copyWith(
                                        fontSize: Dimensions.fs12,
                                      ),
                                    ),
                                    SizedBox(
                                      width: Dimensions.p8,
                                    ),
                                    Text(
                                      '${distance > 1000 ? '1000+' : distance.toStringAsFixed(2)} ${'km_away'.tr}',
                                      style: robotoRegular.copyWith(
                                          fontSize:
                                              Dimensions.fs10,
                                          color: ManagerColors.darkGreen),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                    height: Dimensions.p4),
                                Text(
                                  parcel
                                      ? 'parcel'.tr
                                      : '${orderModel.detailsCount} ${orderModel.detailsCount! > 1 ? 'items'.tr : 'item'.tr}',
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fs12,
                                    color: ManagerColors.darkGreen,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  parcel
                                      ? orderModel
                                              .parcelCategory?.description ??
                                          ''
                                      : orderModel.storeAddress ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fs12,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: Dimensions.p20),

                      // delivery + view on map
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  parcel
                                      ? orderModel.receiverDetails?.address ??
                                          ''
                                      : orderModel.deliveryAddress?.address ??
                                          '',
                                  style: robotoSemiBold.copyWith(
                                    fontSize: Dimensions.fs12,
                                  ),
                                ),
                                const SizedBox(height: Dimensions.p4),
                                Text(
                                  'delivery_location'.tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fs12,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: Dimensions.p50,
                          ),
                          Expanded(
                            child: CustomButtonWidget(
                              buttonText: 'view_on_map'.tr,
                              fontSize: Dimensions.fs15,
                              radius: Dimensions.r24,
                              fontColor:
                              Theme.of(context).textTheme.bodyMedium?.color,
                              onPressed: () => Get.to(() => OrderLocationScreen(
                                    orderModel: orderModel,
                                    orderController: orderController,
                                    index: index,
                                    onTap: onTap,
                                  )),
                              transparent: true,
                              isBorder: true,
                              borderColor:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              height: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: Dimensions.p20),

            // ACTIONS: ignore + accept
            Row(
              children: [
                Expanded(
                  child: CustomButtonWidget(
                      height: 40,
                      radius: Dimensions.r10,
                      buttonText: 'ignore'.tr,
                      transparent: true,
                      fontSize: Dimensions.fs16,
                      fontColor: Theme.of(context).textTheme.bodyLarge!.color,
                      isBorder: true,
                      borderColor: Theme.of(context).textTheme.bodyLarge!.color,
                      onPressed: () => showCustomBottomSheet(
                            child: ConfirmationBottomSheet(
                              title: 'are_you_sure_you_want_to_ignor_this_order'.tr,
                              acceptText: 'yes_ignore'.tr,
                              cancelText: 'no_cancel'.tr,
                              acceptColor: ManagerColors.error,
                              onAccept: () {
                                if (Get.isSnackbarOpen) {
                                  Get.back();
                                }
                                orderController.ignoreOrder(index);
                                Get.back();
                                showCustomSnackBar('order_ignored'.tr,
                                    isError: false);
                              },
                            ),
                          )),
                ),
                const SizedBox(width: Dimensions.p10),
                Expanded(
                  child: CustomButtonWidget(
                      height: 40,
                      radius: Dimensions.r10,
                      buttonText: 'accept'.tr,
                      fontSize: Dimensions.fs16,
                      onPressed: () => showCustomBottomSheet(
                            child: ConfirmationBottomSheet(
                              title: 'are_you_sure_you_want_to_accept_this_order'.tr,
                            
                              acceptText: 'yes_accept'.tr,
                              cancelText: 'no_cancel'.tr,
                              acceptColor: Theme.of(Get.context!).primaryColor,
                              onAccept: () {
                                orderController
                                    .acceptOrder(
                                        orderModel.id, index, orderModel)
                                    .then((isSuccess) {
                                  if (isSuccess) {
                                    onTap();
                                    orderModel.orderStatus = 'accepted';
                                    Get.toNamed(
                                      RouteHelper.getOrderDetailsRoute(
                                          orderModel.id),
                                      arguments: OrderDetailsScreen(
                                        orderId: orderModel.id,
                                        isRunningOrder: true,
                                        orderIndex: orderController
                                                .currentOrderList!.length -
                                            1,
                                      ),
                                    );
                                  } else {
                                    Get.find<OrderController>()
                                        .getLatestOrders();
                                  }
                                });
                              },
                            ),
                          )),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
