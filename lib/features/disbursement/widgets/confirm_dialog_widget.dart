import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/disbursement/controllers/disbursement_controller.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';

class ConfirmDialogWidget extends StatelessWidget {
  final int id;
  const ConfirmDialogWidget({super.key, required this.id, });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DisbursementController>(builder: (disbursementController) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.r4)),
        insetPadding: EdgeInsets.all(30),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.w20, vertical: Dimensions.h20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              Icon(Icons.error_outlined, color: Theme.of(context).colorScheme.error, size: 54),
              SizedBox(height: Dimensions.h20),

              Text(
                'are_you_sure_to_delete_this_method'.tr,
                style: textMedium(),
              ),
              SizedBox(height: Dimensions.h25),

              !disbursementController.isDeleteLoading ? Row(children: [
                Expanded(
                  child: CustomButtonWidget(
                    buttonText: 'cancel'.tr,
                    backgroundColor: Theme.of(context).disabledColor,
                    onPressed: () => Get.back(),
                  ),
                ),
                SizedBox(width: Dimensions.w10),

                Expanded(
                  child: CustomButtonWidget(
                    buttonText: 'ok'.tr,
                    onPressed: () => disbursementController.deleteMethod(id),
                  ),
                ),
              ]) : const Center(child: CircularProgressIndicator()),

            ]),
          ),
        ),
      );
    });
  }
}