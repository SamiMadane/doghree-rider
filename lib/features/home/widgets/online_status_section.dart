import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/features/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_confirmation_bottom_sheet.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';

class StatusSwitchSection extends StatelessWidget {
  const StatusSwitchSection({super.key});

  void _checkPermission(Function callback) async {
    LocationPermission permission = await Geolocator.requestPermission();
    permission = await Geolocator.checkPermission();

    while (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    if (permission == LocationPermission.denied) {
      showCustomBottomSheet(
        child: CustomConfirmationBottomSheet(
          title: 'location_access_needed'.tr,
          description: 'you_denied'.tr,
          image: ManagerAssets.locationAccessIcon,
          buttonWidget: Padding(
            padding:
                const EdgeInsets.only(bottom: 20, top: 10, left: 30, right: 30),
            child: CustomButtonWidget(
              onPressed: () async {
                Get.back();
                final perm = await Geolocator.requestPermission();
                if (perm == LocationPermission.deniedForever)
                  await Geolocator.openAppSettings();
                if (GetPlatform.isAndroid) _checkPermission(callback);
              },
              buttonText: 'allow_location_permission'.tr,
            ),
          ),
        ),
      );
    } else if (permission == LocationPermission.deniedForever ||
        (GetPlatform.isIOS
            ? false
            : permission == LocationPermission.whileInUse)) {
      showCustomBottomSheet(
        child: CustomConfirmationBottomSheet(
          title: 'location_access_needed'.tr,
          description: permission == LocationPermission.whileInUse
              ? 'you_denied'.tr
              : 'you_denied_forever'.tr,
          image: ManagerAssets.locationAccessIcon,
          buttonWidget: Padding(
            padding:
                const EdgeInsets.only(bottom: 20, top: 10, left: 30, right: 30),
            child: CustomButtonWidget(
              onPressed: () async {
                Get.back();
                await Geolocator.openAppSettings();
                Future.delayed(const Duration(seconds: 3), () {
                  if (GetPlatform.isAndroid) _checkPermission(callback);
                });
              },
              buttonText: 'allow_location_permission'.tr,
            ),
          ),
        ),
      );
    } else {
      callback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<OrderController>();

    return GetBuilder<ProfileController>(builder: (profileController) {
      if (profileController.profileModel == null ||
          orderController.currentOrderList == null) {
        return const SizedBox();
      }

      bool isActive = profileController.profileModel!.active == 1;

      return CustomCard(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isActive ? 'online'.tr : 'offline'.tr,
              style: robotoSemiBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
              ),
            ),
            FlutterSwitch(
              width: 60,
              height: 30,
              valueFontSize: Dimensions.fontSizeExtraSmall,
              activeColor: Theme.of(context).primaryColor,
              value: isActive,
              onToggle: (bool toggle) async {
                if (!toggle && orderController.currentOrderList!.isNotEmpty) {
                  showCustomBottomSheet(
                    child: CustomConfirmationBottomSheet(
                      title: 'you_cant_go_offline'.tr,
                      description: 'you_can_not_go_offline_now'.tr,
                      buttonWidget: Padding(
                        padding: const EdgeInsets.only(bottom: 20, top: 10),
                        child: CustomButtonWidget(
                          width: 150,
                          onPressed: () => Get.back(),
                          buttonText: 'okay'.tr,
                        ),
                      ),
                    ),
                  );
                } else {
                  if (!toggle) {
                    showCustomBottomSheet(
                      child: CustomConfirmationBottomSheet(
                        title: 'go_offline'.tr,
                        description: 'are_you_sure_to_offline'.tr,
                        image: ManagerAssets.dmOfflineIcon,
                        buttonWidget: Padding(
                          padding: const EdgeInsets.only(
                            left: 40,
                            right: 40,
                            bottom: 20,
                            top: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomButtonWidget(
                                  onPressed: () {
                                    profileController.updateActiveStatus();
                                  },
                                  buttonText: 'yes_proceed'.tr,
                                ),
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeDefault),
                              Expanded(
                                child: CustomButtonWidget(
                                  onPressed: () => Get.back(),
                                  buttonText: 'cancel'.tr,
                                  backgroundColor: Theme.of(context)
                                      .disabledColor
                                      .withOpacity(0.1),
                                  fontColor: Theme.of(context).disabledColor,
                                  isBorder: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    _checkPermission(
                        () => profileController.updateActiveStatus());
                  }
                }
              },
            ),
          ],
        ),
      );
    });
  }
}
