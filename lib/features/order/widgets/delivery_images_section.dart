import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/widgets/camera_button_sheet_widget.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/theme_extension.dart';

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
    final theme = Theme.of(context);
    final customColor = theme.extension<CustomColorsExtension>()!;
    final orderController = Get.find<OrderController>();

    if (!showDeliveryConfirmImage || order.orderStatus == 'delivered') {
      return const SizedBox();
    }

    final double tile = Dimensions.w100;

    return Container(
      padding: EdgeInsets.only(top: Dimensions.h16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'completed_after_delivery_picture'.tr,
            style: textSemiBold().copyWith(fontSize: Dimensions.fs16),
          ),
          SizedBox(height: Dimensions.h16),
          SizedBox(
            height: tile,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
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
                      padding: EdgeInsets.all(Dimensions.w5),
                      radius: Radius.circular(Dimensions.r10),
                    ),
                    child: SizedBox(
                      height: tile,
                      width: tile,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            ManagerAssets.cameraIcon,
                            height: Dimensions.w30,
                            width: Dimensions.w30,
                            colorFilter: ColorFilter.mode(
                              theme.textTheme.bodyMedium?.color ??
                                  ManagerColors.onPrimary,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(height: Dimensions.h6),
                          Text(
                            'add_a_photo'.tr,
                            style: textRegular().copyWith(
                              fontSize: Dimensions.fs14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Dimensions.w10),
                ...orderController.pickedPrescriptions.map((file) {
                  return Stack(
                    children: [
                      Container(
                        margin: EdgeInsetsDirectional.only(
                            end: Dimensions.w10),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(Dimensions.r10),
                          child: GetPlatform.isWeb
                              ? Image.network(
                                  file.path,
                                  width: tile,
                                  height: tile,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(file.path),
                                  width: tile,
                                  height: tile,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      PositionedDirectional(
                        top: Dimensions.h4,
                        end: Dimensions.w14,
                        child: InkWell(
                          onTap: () =>
                              orderController.removePrescriptionImage(file),
                          child: Container(
                            padding: EdgeInsets.all(Dimensions.w4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: ManagerColors.onPrimary,
                            ),
                            child: Icon(
                              Icons.close,
                              color: ManagerColors.white,
                              size: Dimensions.fs16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}