import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/disbursement/controllers/disbursement_controller.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/features/disbursement/widgets/withdraw_method_attention_dialog_widget.dart';

class DisbursementHelper {

  Future<bool> enableDisbursementWarningMessage(bool fromDashboard, {bool canShowDialog = true}) async {

    bool showWarning = false;

    Get.find<SplashController>().configModel!.disbursementType == 'automated' && (Get.find<ProfileController>().profileModel!.type! != 'store_wise' && Get.find<ProfileController>().profileModel!.earnings != 0)
        ? showWarning = true : showWarning = false;

    if(Get.find<SplashController>().configModel!.disbursementType == 'automated' && (Get.find<ProfileController>().profileModel!.type! != 'store_wise' && Get.find<ProfileController>().profileModel!.earnings != 0)){
      await Get.find<DisbursementController>().getDisbursementMethodList().then((success) {
        if(success){
          if(Get.find<DisbursementController>().disbursementMethodBody!.methods!.isNotEmpty) {
            for (var method in Get.find<DisbursementController>().disbursementMethodBody!.methods!) {
              if (method.isDefault == true) {
                showWarning = false;
                break;
              } else {
                showWarning = true;
              }
            }
          } else {
            showWarning = true;
          }
        }
      });
    } else {
      showWarning = false;
    }

    if(showWarning && canShowDialog) {
      Get.dialog(
        Dialog(
          alignment: Alignment.bottomCenter,
          backgroundColor: const Color(0xfffff1f1),
          insetPadding: EdgeInsets.only(bottom: Dimensions.h10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.r10)), //this right here
          child: WithdrawMethodAttentionDialogWidget(isFromDashboard: fromDashboard),
        ),
      );
    }
    return showWarning;
  }

}