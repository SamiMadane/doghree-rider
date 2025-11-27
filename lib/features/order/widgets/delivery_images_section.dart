import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/features/order/controllers/order_controller.dart';
import 'package:wefrh_rider/features/order/widgets/camera_button_sheet_widget.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/util/theme_extension.dart';

class DeliveryImagesSection extends StatelessWidget {
  final dynamic order;
  final bool showDeliveryConfirmImage;

  const DeliveryImagesSection({
    super.key,
    required this.order,
    required this.showDeliveryConfirmImage,
  });

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;
    final orderController = Get.find<OrderController>();

    if (!showDeliveryConfirmImage || order.orderStatus == 'delivered') {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.only(top: Dimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'completed_after_delivery_picture'.tr,
            style:
                robotoSemiBold.copyWith(fontSize: Dimensions.fs16),
          ),
          const SizedBox(height: Dimensions.p16),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                // زر إضافة صورة دائمًا على اليسار
                InkWell(
                  onTap: () {
                    if (GetPlatform.isIOS) {
                      orderController.pickPrescriptionImage(
                          isRemove: false, isCamera: false);
                    } else {
                      Get.bottomSheet(const CameraButtonSheetWidget());
                    }
                  },
                  child: DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      color: customColor.strock1,
                      strokeWidth: 1,
                      strokeCap: StrokeCap.butt,
                      dashPattern: const [8, 5],
                      padding: const EdgeInsets.all(5),
                      radius: const Radius.circular(Dimensions.r10),
                    ),
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            ManagerAssets.cameraIcon,
                            height: 30,
                            width: 30,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'add_a_photo'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fs14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: Dimensions.p10),

                // الصور المضافة تظهر بعد زر الإضافة
                ...orderController.pickedPrescriptions.map((file) {
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            right: Dimensions.p10),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.r10),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(Dimensions.r10),
                          child: GetPlatform.isWeb
                              ? Image.network(
                                  file.path,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(file.path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      // زر الحذف
                      Positioned(
                        top: 4,
                        right: 12,
                        child: InkWell(
                          onTap: () {
                            orderController.removePrescriptionImage(file);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.7),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
