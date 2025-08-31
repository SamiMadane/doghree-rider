import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/disbursement/controllers/disbursement_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';

class ConfirmDialogWidget extends StatelessWidget {
  final int id;
  const ConfirmDialogWidget({super.key, required this.id, });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DisbursementController>(builder: (disbursementController) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.r4)),
        insetPadding: const EdgeInsets.all(30),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.p20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              Icon(Icons.error_outlined, color: Theme.of(context).colorScheme.error, size: 54),
              const SizedBox(height: Dimensions.p20),

              Text(
                'are_you_sure_to_delete_this_method'.tr,
                style: robotoMedium,
              ),
              const SizedBox(height: Dimensions.p25),

              !disbursementController.isDeleteLoading ? Row(children: [
                Expanded(
                  child: CustomButtonWidget(
                    buttonText: 'cancel'.tr,
                    backgroundColor: Theme.of(context).disabledColor,
                    onPressed: () => Get.back(),
                  ),
                ),
                const SizedBox(width: Dimensions.p10),

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