import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart_delivery/common/widgets/confirmation_bottom_sheet.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/features/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/address/controllers/address_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/navigation_handler/controllers/navigation_handler_controller.dart';
import 'package:sixam_mart_delivery/features/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/features/order/screens/order_details_screen.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    bool parcel = orderModel.orderType == 'parcel';
    double restaurantDistance =
        Get.find<AddressController>().getRestaurantDistance(
      LatLng(
          double.parse(parcel
              ? orderModel.deliveryAddress?.latitude ?? '0'
              : orderModel.storeLat ?? '0'),
          double.parse(parcel
              ? orderModel.deliveryAddress?.longitude ?? '0'
              : orderModel.storeLng ?? '0')),
    );
    double restaurantToCustomerDistance =
        Get.find<AddressController>().getRestaurantDistance(
      LatLng(
          double.parse(parcel
              ? orderModel.deliveryAddress?.latitude ?? '0'
              : orderModel.storeLat ?? '0'),
          double.parse(parcel
              ? orderModel.deliveryAddress?.longitude ?? '0'
              : orderModel.storeLng ?? '0')),
      customerLatLng: LatLng(
          double.parse(parcel
              ? orderModel.receiverDetails?.latitude ?? '0'
              : orderModel.deliveryAddress?.latitude ?? '0'),
          double.parse(parcel
              ? orderModel.receiverDetails?.longitude ?? '0'
              : orderModel.deliveryAddress?.longitude ?? '0')),
    );

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeExtraLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
          topRight: Radius.circular(Dimensions.radiusExtraLarge),
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
            padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
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
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
             // TODO: BACK TO FIX PARCEL , AND SURE FROM INFORMATION DISPLAY IN THIS SCREEN

                    Text(
                      parcel
                          ? orderModel.parcelCategory?.name ?? '' // is it true ? add parcel order to check it
                          : orderModel.storeName ?? '', // وفرة مارت
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge),
                    ),
                    Text(
                      parcel
                          ? orderModel.parcelCategory?.description ?? '' // not have type 
                          : orderModel.moduleType ?? '', // grocery
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
                Spacer(),
                Text(
                  '${restaurantDistance > 1000 ? '1000+' : restaurantDistance.toStringAsFixed(2)} ${'km_away'.tr}',
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: ManagerColors.darkGreen,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          // -------- CUSTOMER / DELIVERY --------
          CustomCard(
            padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
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
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parcel
                          ? orderModel.receiverDetails?.contactPersonName ?? ''
                          : orderModel.customer?.fName ?? '',
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge),
                    ),
                    Text(
                      parcel
                          ? orderModel.receiverDetails?.addressType ?? ''
                          : 'customer'.tr,
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
                Spacer(),
                Text(
                  '${restaurantToCustomerDistance > 1000 ? '1000+' : restaurantToCustomerDistance.toStringAsFixed(2)} ${'km_away'.tr}',
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: ManagerColors.darkGreen,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          // -------- PRICE + PAYMENT --------
          Row(
            children: [
              (Get.find<NavigationHandlerController>()
                          .configModel!
                          .showDmEarning! &&
                      Get.find<ProfileController>().profileModel!.earnings == 1)
                  ? Text(
                      PriceConverterHelper.convertPrice(
                          orderModel.originalDeliveryCharge! +
                              orderModel.dmTips!),
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge),
                    )
                  : const SizedBox(),
              SizedBox(
                width: Dimensions.paddingSizeSmall,
              ),
              Text(
                '${orderModel.paymentMethod == 'cash_on_delivery' ? 'cod'.tr : orderModel.paymentMethod == 'wallet' ? 'wallet'.tr : 'paid'.tr}',
                style: robotoSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: orderModel.paymentMethod == 'cash_on_delivery'
                      ? ManagerColors.orange
                      : orderModel.paymentMethod == 'wallet'
                          ? ManagerColors.darkGreen
                          : ManagerColors.darkGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          // -------- ACTION BUTTONS --------
          Row(
            children: [
              Expanded(
                child: CustomButtonWidget(
                    height: 40,
                    radius: Dimensions.radiusDefault,
                    buttonText: 'ignore'.tr,
                    transparent: true,
                    fontSize: Dimensions.fontSizeLarge,
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
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: CustomButtonWidget(
                    height: 40,
                    radius: Dimensions.radiusDefault,
                    buttonText: 'accept'.tr,
                    fontSize: Dimensions.fontSizeLarge,
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
