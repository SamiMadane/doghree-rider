import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sixam_mart_delivery/features/language/domain/models/language_model.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';

class LanguageCardWidget extends StatelessWidget {
  final LanguageModel languageModel;
  final LocalizationController localizationController;
  final int index;
  final bool fromBottomSheet;

  const LanguageCardWidget(
      {super.key,
      required this.languageModel,
      required this.localizationController,
      required this.index,
      this.fromBottomSheet = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // تحديد اللغة وحفظها مباشرة عند الضغط
        localizationController.setSelectLanguageIndex(index);
        localizationController.setLanguage(
            Locale(
              AppConstants.languages[index].languageCode!,
              AppConstants.languages[index].countryCode,
            ),
            fromBottomSheet: fromBottomSheet);

        if (fromBottomSheet) {
          localizationController.saveCacheLanguage(Locale(
            AppConstants.languages[index].languageCode!,
            AppConstants.languages[index].countryCode,
          ));
          Get.back(); // اغلاق الـ Bottom Sheet
        }
      },
      child: Container(
        height: 70,
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        decoration: BoxDecoration(
          color: localizationController.selectedLanguageIndex == index
              ? Theme.of(context).primaryColor.withOpacity(0.05)
              : null,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(
            color: localizationController.selectedLanguageIndex == index
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(children: [
          Image.asset(languageModel.imageUrl!, width: 36, height: 36),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Text(languageModel.languageName!,
              style:
                  robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const Spacer(),
          localizationController.selectedLanguageIndex == index
              ? Icon(Icons.check_circle,
                  color: Theme.of(context).primaryColor, size: 25)
              : const SizedBox(),
        ]),
      ),
    );
  }
}
