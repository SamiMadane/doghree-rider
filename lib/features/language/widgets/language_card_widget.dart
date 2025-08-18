import 'package:get/get.dart';
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
    final isSelected = localizationController.selectedLanguageIndex == index;
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
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).textTheme.bodyMedium!.color!
                : Theme.of(context).dividerTheme.color!,
            width: 1,
          ),
        ),
        child: Row(children: [
          // دائرة الاختيار
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .color!, 
                width: isSelected ? 6 : 1.5, 
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: Dimensions.paddingSizeLarge),
          Image.asset(languageModel.imageUrl!, width: 36, height: 36),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Text(languageModel.languageName!,
              style:
                  robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
        ]),
      ),
    );
  }
}
