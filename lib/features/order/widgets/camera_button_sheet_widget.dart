import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class CameraButtonSheetWidget extends StatelessWidget {
  const CameraButtonSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: Dimensions.p16,
          horizontal: Dimensions.p20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Dimensions.r20)),
        color: Theme.of(context).cardColor,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // الخط العلوي للـ drag
        Container(
          height: 4,
          width: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.r10),
              color: Theme.of(context).disabledColor),
        ),
        const SizedBox(height: Dimensions.p20),

        // العنوان في الوسط
        Text(
          'upload_a_photo'.tr,
          style: robotoBold.copyWith(fontSize: Dimensions.fs16),
        ),

        const SizedBox(height: Dimensions.p20),

        // العمود يحتوي على خيارين
        Column(
          children: [
            // اختيار من المعرض
            InkWell(
              onTap: () {
                if (Get.isBottomSheetOpen!) {
                  Get.back();
                }
                Get.find<OrderController>()
                    .pickPrescriptionImage(isRemove: false, isCamera: false);
              },
              child: Container(
                padding: const EdgeInsets.all(Dimensions.p16),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      ManagerAssets.galleryIcon,
                      height: 35,
                      width: 35,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    const SizedBox(width: Dimensions.p16),
                    Text('from_gallery'.tr,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fs14)),
                  ],
                ),
              ),
            ),

            // اختيار من الكاميرا
            InkWell(
              onTap: () {
                if (Get.isBottomSheetOpen!) {
                  Get.back();
                }
                Get.find<OrderController>()
                    .pickPrescriptionImage(isRemove: false, isCamera: true);
              },
              child: Container(
                padding: const EdgeInsets.all(Dimensions.p16),
                child: Row(
                  children: [
                   SvgPicture.asset(
                      ManagerAssets.cameraIcon,
                      height: 35,
                      width: 35,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    const SizedBox(width: Dimensions.p16),
                    Text('from_camera'.tr,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fs14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
