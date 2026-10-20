import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:doghree_rider/doghree_map/map_safety.dart';
import 'package:doghree_rider/common/widgets/confirmation_bottom_sheet.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/address/controllers/address_controller.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/features/order/screens/order_details_screen.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';

class LocationCardWidget extends StatelessWidget {
  final OrderModel orderModel;
  final OrderController orderController;
  final int index;
  final Function onTap;
  const LocationCardWidget({
    super.key,
    required this.orderModel,
    required this.orderController,
    required this.index,
    required this.onTap,
  });

  /// null = إحداثيات غير صالحة (فارغة، 0,0، أو خارج غزة) فلا نعرض رقماً خاطئاً
  static String _distanceLabel(double? km) {
    if (km == null) return '--';
    return km > 1000 ? '1000+' : km.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    bool parcel = orderModel.orderType == 'parcel';
    final addressController = Get.find<AddressController>();

    // نقطة الاستلام (المحل، أو عنوان التوصيل في طلبات parcel كما كان سابقاً)
    final LatLng? pickupPoint = parsePoint(
      parcel ? orderModel.deliveryAddress?.latitude : orderModel.storeLat,
      parcel ? orderModel.deliveryAddress?.longitude : orderModel.storeLng,
    );
    // نقطة التسليم (المستلم في parcel، وإلا عنوان العميل)
    final LatLng? dropPoint = parsePoint(
      parcel
          ? orderModel.receiverDetails?.latitude
          : orderModel.deliveryAddress?.latitude,
      parcel
          ? orderModel.receiverDetails?.longitude
          : orderModel.deliveryAddress?.longitude,
    );

    final double? restaurantDistance = pickupPoint == null
        ? null
        : addressController.getRestaurantDistance(pickupPoint);
    final double? restaurantToCustomerDistance =
        (pickupPoint == null || dropPoint == null)
            ? null
            : addressController.getRestaurantDistance(pickupPoint,
                customerLatLng: dropPoint);

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.w16,
          vertical: Dimensions.h25),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.r20),
          topRight: Radius.circular(Dimensions.r20),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------- STORE / PICKUP --------
          CustomCard(
            padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
            child: Row(
              children: [
                parcel
                    ? ClipOval(
                        child: Image.asset(
                          ManagerAssets.storeImage,
                          width: 40,
                          height: 40,
                        ),
                      )
                    : ClipOval(
                        child: CustomImageWidget(
                          image: orderModel.storeLogoFullUrl ?? '',
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                SizedBox(width: Dimensions.w10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
             // TODO: BACK TO FIX PARCEL , AND SURE FROM INFORMATION DISPLAY IN THIS SCREEN

                    Text(
                      parcel
                          ? orderModel.parcelCategory?.name ?? '' // is it true ? add parcel order to check it
                          : orderModel.storeName ?? '', // وفرة مارت
                      style: textMedium().copyWith(
                          fontSize: Dimensions.fs16),
                    ),
                    Text(
                      parcel
                          ? orderModel.parcelCategory?.description ?? '' // not have type 
                          : orderModel.moduleType ?? '', // grocery
                      style: textRegular().copyWith(
                          fontSize: Dimensions.fs14,
                          color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
                Spacer(),
                Text(
                  '${_distanceLabel(restaurantDistance)} ${'km_away'.tr}',
                  style: textMedium().copyWith(
                    fontSize: Dimensions.fs12,
                    color: ManagerColors.darkGreen,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: Dimensions.h10),

          // -------- CUSTOMER / DELIVERY --------
          CustomCard(
            padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
            child: Row(
              children: [
                parcel
                    ? ClipOval(
                        child: Image.asset(
                          ManagerAssets.storeImage,
                          width: 40,
                          height: 40,
                        ),
                      )
                    : ClipOval(
                        child: CustomImageWidget(
                          image: orderModel.customer?.imageFullUrl ?? '',
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                SizedBox(width: Dimensions.w10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parcel
                          ? orderModel.receiverDetails?.contactPersonName ?? ''
                          : orderModel.customer?.fName ?? '',
                      style: textMedium().copyWith(
                          fontSize: Dimensions.fs16),
                    ),
                    Text(
                      parcel
                          ? orderModel.receiverDetails?.addressType ?? ''
                          : 'customer'.tr,
                      style: textRegular().copyWith(
                          fontSize: Dimensions.fs14,
                          color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
                Spacer(),
                Text(
                  '${_distanceLabel(restaurantToCustomerDistance)} ${'km_away'.tr}',
                  style: textMedium().copyWith(
                    fontSize: Dimensions.fs12,
                    color: ManagerColors.darkGreen,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: Dimensions.h20),

          // -------- PRICE + PAYMENT --------
          Row(
            children: [
              (Get.find<SplashController>()
                          .configModel!
                          .showDmEarning! &&
                      Get.find<ProfileController>().profileModel!.earnings == 1)
                  ? Text(
                      PriceConverterHelper.convertPrice(
                          orderModel.originalDeliveryCharge! +
                              orderModel.dmTips!),
                      style: textMedium().copyWith(
                          fontSize: Dimensions.fs16),
                    )
                  : const SizedBox(),
              SizedBox(
                width: Dimensions.w10,
              ),
              Text(
                '${orderModel.paymentMethod == 'cash_on_delivery' ? 'cod'.tr : orderModel.paymentMethod == 'wallet' ? 'wallet'.tr : 'paid'.tr}',
                style: textSemiBold().copyWith(
                  fontSize: Dimensions.fs14,
                  color: orderModel.paymentMethod == 'cash_on_delivery'
                      ? ManagerColors.orangeLightMode
                      : orderModel.paymentMethod == 'wallet'
                          ? ManagerColors.darkGreen
                          : ManagerColors.darkGreen,
                ),
              ),
            ],
          ),

          SizedBox(height: Dimensions.h20),

          // -------- ACTION BUTTONS --------
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
                            title:
                                'are_you_sure_you_want_to_ignor_this_order'.tr,
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
              SizedBox(width: Dimensions.w10),
              Expanded(
                child: CustomButtonWidget(
                    height: 40,
                    radius: Dimensions.r10,
                    buttonText: 'accept'.tr,
                    fontSize: Dimensions.fs16,
                    onPressed: () => showCustomBottomSheet(
                          child: ConfirmationBottomSheet(
                            title:
                                'are_you_sure_you_want_to_accept_this_order'.tr,
                            acceptText: 'yes_accept'.tr,
                            cancelText: 'no_cancel'.tr,
                            acceptColor: Theme.of(Get.context!).primaryColor,
                            onAccept: () {
                              orderController
                                  .acceptOrder(orderModel.id, index, orderModel)
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
                                  Get.find<OrderController>().getLatestOrders();
                                }
                              });
                            },
                          ),
                        )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}