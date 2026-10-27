import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';

class CameraButtonSheetWidget extends StatelessWidget {
  const CameraButtonSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: Dimensions.h16,
          horizontal: Dimensions.w20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
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
        SizedBox(height: Dimensions.h20),

        // العنوان في الوسط
        Text(
          'upload_a_photo'.tr,
          style: textBold().copyWith(fontSize: Dimensions.fs16),
        ),

        SizedBox(height: Dimensions.h20),

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
                padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      ManagerAssets.galleryIcon,
                      height: 35,
                      width: 35,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    SizedBox(width: Dimensions.w16),
                    Text('from_gallery'.tr,
                        style: textMedium().copyWith(
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
                padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
                child: Row(
                  children: [
                   SvgPicture.asset(
                      ManagerAssets.cameraIcon,
                      height: 35,
                      width: 35,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    SizedBox(width: Dimensions.w16),
                    Text('from_camera'.tr,
                        style: textMedium().copyWith(
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
