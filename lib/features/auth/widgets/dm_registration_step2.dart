import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:wefrh_rider/common/widgets/custom_drop_down_button.dart';
import 'package:wefrh_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_text_field_widget.dart';
import 'package:wefrh_rider/common/widgets/image_picker_widget.dart';
import 'package:wefrh_rider/common/widgets/widget_with_label.dart';
import 'package:wefrh_rider/features/address/controllers/address_controller.dart';
import 'package:wefrh_rider/features/auth/controllers/auth_controller.dart';
import 'package:wefrh_rider/features/auth/widgets/condition_check_box_widget.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';

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
                style: robotoSemiBold.copyWith(fontSize: Dimensions.fs16),
              ),
              SizedBox(
                height: Dimensions.p16,
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
              const SizedBox(height: Dimensions.p16),

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
                                    fontSize: Dimensions.fs14,
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
              const SizedBox(height: Dimensions.p16),

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
                                    fontSize: Dimensions.fs14,
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
          const SizedBox(height: Dimensions.p16),
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
              const SizedBox(height: Dimensions.p16),

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
          const SizedBox(height: Dimensions.p20),
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
                        mainAxisExtent: 200,
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

                        // استخدام ImagePickerWidget
                        return ImagePickerWidget(
                          pickedImagePath: file?.path,
                          placeholderText: 'upload_id_picture'.tr,
                          height: 180,
                          onPickImage: () {
                            if (authController.pickedIdentities.length < 6) {
                              authController.pickDmImageForRegistration(
                                  false, false);
                            } else {
                              showCustomSnackBar('maximum_image_limit_is_6'.tr);
                            }
                          },
                          onRemoveImage: () {
                            if (file != null) {
                              authController.removeIdentityImage(index);
                            }
                          },
                          showErrorBorder: false,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.p16),
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
