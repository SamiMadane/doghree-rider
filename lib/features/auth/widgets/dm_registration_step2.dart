import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:doghree_rider/common/widgets/custom_drop_down_button.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/common/widgets/custom_text_field_widget.dart';
import 'package:doghree_rider/common/widgets/image_picker_widget.dart';
import 'package:doghree_rider/common/widgets/widget_with_label.dart';
import 'package:doghree_rider/features/address/controllers/address_controller.dart';
import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/auth/widgets/condition_check_box_widget.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class DmRegistrationStep2 extends StatelessWidget {
  final TextEditingController identityNumberController;
  final FocusNode identityNumberNode;

  const DmRegistrationStep2({
    super.key,
    required this.identityNumberController,
    required this.identityNumberNode,
  });

  /// رسالة الخطأ تحت الحقل (للقوائم المنسدلة والصور)
  Widget _errorText(BuildContext context, AuthController auth, String key) {
    final String? message = auth.fieldError(key);
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: Dimensions.h4),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          message,
          textAlign: TextAlign.start,
          style: textRegular().copyWith(
            fontSize: Dimensions.fs12,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }

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
                style: textSemiBold().copyWith(fontSize: Dimensions.fs16),
              ),
              SizedBox(
                height: Dimensions.h16,
              ),
              // Delivery Type (مخفي حالياً: المندوب مستقل دائماً)
              if (AppConstants.allowDmTypeSelection) ...[
                WidgetWithLabel(
                  label: 'select_delivery_type'.tr,
                  textField: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomDropdownButton(
                        hintText: 'select_delivery_type'.tr,
                        items: authController.dmTypeList,
                        selectedValue: authController.selectedDmType,
                        onChanged: (value) {
                          authController.clearFieldError('delivery_type');
                          authController.setSelectedDmType(value);
                        },
                      ),
                      _errorText(context, authController, 'delivery_type'),
                    ],
                  ),
                ),
                SizedBox(height: Dimensions.h16),
              ],

              // Delivery Zone
              addressController.zoneList != null
                  ? WidgetWithLabel(
                      label: 'main_zone'.tr,
                      textField: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomDropdownButton(
                            hintText: 'select_delivery_zone'.tr,
                            dropdownMenuItems: addressController.zoneList!
                                .map(
                                  (zone) => DropdownMenuItem<String>(
                                    value: zone.id.toString(),
                                    child: Text(
                                      zone.name ?? '',
                                      style: textRegular().copyWith(
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
                            selectedValue:
                                addressController.selectedDeliveryZoneId,
                            onChanged: (value) {
                              authController.clearFieldError('zone_id');
                              addressController.setSelectedDeliveryZone(
                                zoneId: value,
                              );
                            },
                          ),
                          _errorText(context, authController, 'zone_id'),
                        ],
                      ),
                    )
                  : Shimmer(
                      child: Container(
                        height: 50,
                        color: Theme.of(context).shadowColor,
                      ),
                    ),
              SizedBox(height: Dimensions.h16),

              // Vehicle Type
              authController.vehicleIds != null
                  ? WidgetWithLabel(
                      label: 'vehicle_type'.tr,
                      textField: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomDropdownButton(
                            hintText: 'select_vehicle_type'.tr,
                            dropdownMenuItems: authController.vehicles!
                                .map(
                                  (vehicle) => DropdownMenuItem<String>(
                                    value: vehicle.id.toString(),
                                    child: Text(
                                      vehicle.type ?? '',
                                      style: textRegular().copyWith(
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
                              authController.clearFieldError('vehicle_id');
                              authController.setSelectedVehicleType(
                                  vehicleId: value);
                            },
                          ),
                          _errorText(context, authController, 'vehicle_id'),
                        ],
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
          SizedBox(height: Dimensions.h16),
          Column(
            children: [
              // Identity Type Dropdown
              WidgetWithLabel(
                label: 'id_type'.tr,
                textField: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDropdownButton(
                      hintText: 'select_identity_type'.tr,
                      items: authController.identityTypeList,
                      selectedValue: authController.selectedIdentityType,
                      onChanged: (value) {
                        authController.clearFieldError('identity_type');
                        authController.setSelectedIdentityType(value);
                      },
                    ),
                    _errorText(context, authController, 'identity_type'),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.h16),

              // Identity Number TextField
              WidgetWithLabel(
                label: authController.selectedIdentityType != null
                    ? '${authController.selectedIdentityType?.tr}'
                    : 'id_number'.tr,
                textField: CustomTextFieldWidget(
                  hintText: 'Ex: xxx-xxxx-xxxxx',
                  labelText:
                      '${authController.selectedIdentityType?.tr} ${'number'.tr}',
                  controller: identityNumberController,
                  focusNode: identityNumberNode,
                  inputAction: TextInputAction.done,
                  isRequired: true,
                  errorText: authController.fieldError('identity_number'),
                  onChanged: (_) =>
                      authController.clearFieldError('identity_number'),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.h20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetWithLabel(
                label: 'upload_identity_picture'.trParams({
                  'identity': authController.selectedIdentityType?.tr ?? '',
                }),
                textField: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: LayoutBuilder(builder: (context, constraints) {
                          final double cardHeight =
                              constraints.maxWidth * 540 / 856;
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              mainAxisExtent: cardHeight,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:
                                authController.pickedIdentities.length + 1,
                            itemBuilder: (context, index) {
                              XFile? file = index ==
                                      authController.pickedIdentities.length
                                  ? null
                                  : authController.pickedIdentities[index];
                              return ImagePickerWidget(
                                pickedImagePath: file?.path,
                                placeholderText:
                                    'upload_identity_picture'.trParams({
                                  'identity':
                                      authController.selectedIdentityType?.tr ??
                                          '',
                                }),
                                height: cardHeight,
                                onPickImage: () async {
                                  authController
                                      .clearFieldError('identity_image');
                                  if (authController.pickedIdentities.length <
                                      6) {
                                    await authController
                                        .pickIdentityImageWithCrop(context);
                                  } else {
                                    showCustomSnackBar(
                                        'maximum_image_limit_is_6'.tr);
                                  }
                                },
                                onRemoveImage: () {
                                  if (file != null) {
                                    authController.removeIdentityImage(index);
                                  }
                                },
                                // الإطار الأحمر لما ما في صورة وفي خطأ
                                showErrorBorder: file == null &&
                                    authController
                                            .fieldError('identity_image') !=
                                        null,
                              );
                            },
                          );
                        }),
                      ),
                    ),
                    _errorText(context, authController, 'identity_image'),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.h16),
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
