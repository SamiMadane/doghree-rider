// file: widgets/connection_bottom_sheet_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/features/task/controllers/task_controller.dart';
import 'package:sixam_mart_delivery/features/task/widgets/tip_card_widget.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/util/theme_extension.dart';

class ConnectionBottomSheet extends StatelessWidget {
  final TaskController controller;

  const ConnectionBottomSheet({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Obx(() => Padding(
          padding: const EdgeInsets.all(Dimensions.p16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: Dimensions.p16),
              Text('data_management'.tr,
                  style: robotoSemiBold.copyWith(fontSize: Dimensions.fs18)),
              const SizedBox(height: 16),
              CustomCard(
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: Dimensions.r16,
                padding: EdgeInsets.all(Dimensions.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Connection Status Header ---
                    Row(
                      children: [
                        Text('connection_status'.tr,
                            style: robotoRegular.copyWith(
                                fontSize: Dimensions.fs16)),
                        const Spacer(),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: controller.connectionColor.value,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: Dimensions.p8),
                        Text(controller.connectionStatusText,
                            style: robotoSemiBold.copyWith(
                                color: controller.connectionColor.value)),
                      ],
                    ),
                    SizedBox(height: Dimensions.p16),
                    if (controller.connectionLabel.value == '2G')
                      Column(
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                ManagerAssets.networkCellIcon,
                                height: 18,
                                width: 18,
                                color: ManagerColors.red,
                              ),
                              const SizedBox(width: Dimensions.p8),
                              Text(
                                'consumption_of_packages'.tr,
                                style: robotoSemiBold.copyWith(
                                    color: ManagerColors.red),
                              ),
                            ],
                          ),
                          SizedBox(height: Dimensions.p16),
                        ],
                      ),
                    // --- Connection Options ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _connectionOption(context,
                            label: 'wifi'.tr,
                            circleColor: ManagerColors.oliveGreen,
                            selectedBg: ManagerColors.oliveGreen,
                            selectedCircleColor: ManagerColors.greenCircle),
                        _connectionOption(context,
                            label: '2g'.tr,
                            circleColor: ManagerColors.red,
                            selectedBg: ManagerColors.red,
                            selectedCircleColor: ManagerColors.redCircle),
                        _connectionOption(context,
                            label: 'without'.tr,
                            circleColor: ManagerColors.grayCirule,
                            selectedBg: ManagerColors.darkGray,
                            selectedCircleColor:
                                ManagerColors.grayCiruleSelected),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.p16),
              // --- Pending Data Section ---
              Row(
                children: [
                  Text(
                    'pending_data'.tr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fs17),
                  ),
                  const Spacer(),
                  CustomCard(
                    fillColor: customColor.primaryBg,
                    padding: EdgeInsets.all(Dimensions.p16),
                    borderRadius: Dimensions.r8,
                    isBorder: false,
                    height: 55,
                    width: 100,
                    child: Center(
                      child: Text('${'0'} ${'items'.tr}',
                          style: robotoSemiBold.copyWith(
                            fontSize: Dimensions.fs16,
                            color: Theme.of(context).primaryColor,
                          )),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.p30),
              // --- Data Up To Date Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    ManagerAssets.checkIcon,
                    height: 22,
                    width: 22,
                    color: ManagerColors.oliveGreen,
                  ),
                  SizedBox(width: Dimensions.p8),
                  Text(
                    'all_data_up_to_date'.tr,
                    style: robotoBold.copyWith(
                        color: ManagerColors.oliveGreen,
                        fontSize: Dimensions.fs16),
                  )
                ],
              ),
              SizedBox(height: Dimensions.p80),
              // --- Data Saving Tips ---
              TipCardWidget(
                title: 'data_saving_tips'.tr,
                titleColor: customColor.darkBlue,
                backgroundColor: customColor.blueBg,
                tips: [
                  Tip(
                      text: 'use_wifi_upload_photos'.tr,
                      color: customColor.blue),
                  Tip(
                      text: 'packages_emergency_texts'.tr,
                      color: customColor.blue),
                  Tip(text: 'data_saved_locally'.tr, color: customColor.blue),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _connectionOption(BuildContext context,
      {required String label,
      required Color circleColor,
      required Color selectedBg,
      required Color selectedCircleColor}) {
    final bool isSelected = controller.connectionLabel.value == label;
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Expanded(
      child: InkWell(
        onTap: () {
          controller.setConnectionState(label, circleColor);
          Get.back();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.p4),
          padding: EdgeInsets.all(Dimensions.p10),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : customColor.grayBg,
            borderRadius: BorderRadius.circular(Dimensions.r8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isSelected ? selectedCircleColor : circleColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: Dimensions.p8),
              Text(label,
                  style: isSelected
                      ? robotoMedium.copyWith(
                          fontSize: Dimensions.fs16,
                          color: ManagerColors.white,
                        )
                      : robotoRegular.copyWith(
                          fontSize: Dimensions.fs16,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        )),
            ],
          ),
        ),
      ),
    );
  }
}
