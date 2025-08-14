import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_drop_down_button.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_text_field_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/field_with_label.dart';
import 'package:sixam_mart_delivery/features/address/controllers/address_controller.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/auth/widgets/condition_check_box_widget.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class DmRegistrationStep2 extends StatelessWidget {
  final TextEditingController identityNumberController;
  final FocusNode identityNumberNode;

  const DmRegistrationStep2({
    super.key,
    required this.identityNumberController,
    required this.identityNumberNode,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final addressController = Get.find<AddressController>();

    return Visibility(
      visible: authController.dmStatus != 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'identity_information'.tr,
                style:
                    robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              SizedBox(
                height: Dimensions.paddingSizeDefault,
              ),
              // Delivery Type
              WidgetWithLabel(
                label: 'select_delivery_type'.tr,
                textField: CustomDropdownButton(
                  hintText: 'select_delivery_type'.tr,
                  items: authController.dmTypeList,
                  selectedValue: authController.selectedDmType,
                  onChanged: (value) {
                    authController.setSelectedDmType(value);
                  },
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Delivery Zone
              addressController.zoneList != null
                  ? WidgetWithLabel(
                      label: 'main_zone'.tr,
                      textField: CustomDropdownButton(
                        hintText: 'select_delivery_zone'.tr,
                        dropdownMenuItems: addressController.zoneList!
                            .map(
                              (zone) => DropdownMenuItem<String>(
                                value: zone.id.toString(),
                                child: Text(
                                  zone.name ?? '',
                                  style: robotoRegular.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontSize: Dimensions.fontSizeDefault,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        selectedValue: addressController.selectedDeliveryZoneId,
                        onChanged: (value) {
                          addressController.setSelectedDeliveryZone(
                            zoneId: value,
                          );
                        },
                      ),
                    )
                  : Shimmer(
                      child: Container(
                        height: 50,
                        color: Theme.of(context).shadowColor,
                      ),
                    ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Vehicle Type
              authController.vehicleIds != null
                  ? WidgetWithLabel(
                      label: 'vehicle_type'.tr,
                      textField: CustomDropdownButton(
                        hintText: 'select_vehicle_type'.tr,
                        dropdownMenuItems: authController.vehicles!
                            .map(
                              (vehicle) => DropdownMenuItem<String>(
                                value: vehicle.id.toString(),
                                child: Text(
                                  vehicle.type ?? '',
                                  style: robotoRegular.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontSize: Dimensions.fontSizeDefault,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        selectedValue: authController.selectedVehicleId,
                        onChanged: (value) {
                          authController.setSelectedVehicleType(
                              vehicleId: value);
                        },
                      ),
                    )
                  : Shimmer(
                      child: Container(
                        height: 50,
                        color: Theme.of(context).shadowColor,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Column(
            children: [
              // Identity Type Dropdown
              WidgetWithLabel(
                label: 'id_type'.tr,
                textField: CustomDropdownButton(
                  hintText: 'select_identity_type'.tr,
                  items: authController.identityTypeList,
                  selectedValue: authController.selectedIdentityType,
                  onChanged: (value) {
                    authController.setSelectedIdentityType(value);
                  },
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Identity Number TextField
              WidgetWithLabel(
                label: authController.selectedIdentityType != null
                    ? '${authController.selectedIdentityType?.tr} ${'number'.tr}'
                    : 'id_number'.tr,
                textField: CustomTextFieldWidget(
                  hintText: 'Ex: xxx-xxxx-xxxxx',
                  labelText: 'id_number'.tr,
                  controller: identityNumberController,
                  focusNode: identityNumberNode,
                  inputAction: TextInputAction.done,
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetWithLabel(
                label: 'upload_id_picture'.tr,
                textField: Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisExtent: 130,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: authController.pickedIdentities.length + 1,
                      itemBuilder: (context, index) {
                        XFile? file =
                            index == authController.pickedIdentities.length
                                ? null
                                : authController.pickedIdentities[index];

                        // زر رفع الصورة
                        if (file == null) {
                          return InkWell(
                            onTap: () {
                              if (authController.pickedIdentities.length < 6) {
                                authController.pickDmImageForRegistration(
                                    false, false);
                              } else {
                                showCustomSnackBar(
                                    'maximum_image_limit_is_6'.tr);
                              }
                            },
                            child: DottedBorder(
                              options: RoundedRectDottedBorderOptions(
                                color: Get.isDarkMode
                                    ? Colors.white.withOpacity(0.2)
                                    : Theme.of(context).dividerTheme.color!,
                                strokeWidth: 1,
                                strokeCap: StrokeCap.butt,
                                dashPattern: const [8, 4],
                                padding: const EdgeInsets.all(5),
                                radius: const Radius.circular(
                                    Dimensions.radiusExtraLarge),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(ManagerAssets.uploadIcon),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeDefault),
                                    Text(
                                      'upload_id_picture'.tr,
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).hintColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        // عرض الصور المرفوعة
                        return DottedBorder(
                          options: RoundedRectDottedBorderOptions(
                            color: const Color(0xFFE5E5E5),
                            strokeWidth: 1,
                            strokeCap: StrokeCap.butt,
                            dashPattern: const [8, 5],
                            padding: const EdgeInsets.all(5),
                            radius:
                                const Radius.circular(Dimensions.radiusDefault),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                  child: GetPlatform.isWeb
                                      ? Image.network(
                                          file.path,
                                          height: 130,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(file.path),
                                          height: 130,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: InkWell(
                                    onTap: () {
                                      authController.removeIdentityImage(index);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(
                                          Dimensions.paddingSizeSmall),
                                      child: Icon(Icons.delete_forever,
                                          color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              ConditionCheckBoxWidget(
                authController: authController,
                fromSignUp: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
