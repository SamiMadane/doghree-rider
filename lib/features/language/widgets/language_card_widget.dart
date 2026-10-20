import 'package:get/get.dart';
import 'package:doghree_rider/features/language/domain/models/language_model.dart';
import 'package:doghree_rider/features/splash/screens/splash_screen.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:doghree_rider/features/language/controllers/language_controller.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:doghree_rider/util/dimensions.dart';

class LanguageCardWidget extends StatelessWidget {
  final LanguageModel languageModel;
  final LocalizationController localizationController;
  final int index;
  final bool fromBottomSheet; // إذا كانت البطاقة داخل Bottom Sheet
  final bool isFromInitScreen; // إذا كانت من بداية التطبيق

  const LanguageCardWidget({
    super.key,
    required this.languageModel,
    required this.localizationController,
    required this.index,
    this.fromBottomSheet = false,
    this.isFromInitScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = localizationController.selectedLanguageIndex == index;

    return InkWell(
      onTap: () {
        final selectedLocale = Locale(
          AppConstants.languages[index].languageCode!,
          AppConstants.languages[index].countryCode,
        );

        // تحديث اللغة داخلياً
        localizationController.setSelectLanguageIndex(index);

        // إذا جئنا من البداية → حفظ اللغة والتوجيه
        if (isFromInitScreen) {
          localizationController.saveLanguage(selectedLocale);

          // تأجيل التوجيه بعد اكتمال إطار البناء
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAll(() => const SplashScreen(body: null));
          });
        }

        // تعيين اللغة
        localizationController.setLanguage(
          selectedLocale,
          fromBottomSheet: fromBottomSheet,
        );

        // إذا من الإعدادات → اغلاق الـ Bottom Sheet
        if (fromBottomSheet && !isFromInitScreen) {
          localizationController.saveCacheLanguage(selectedLocale);
          Get.back();
        }
      },
      child: Container(
        height: 70,
        padding: EdgeInsets.symmetric(horizontal: Dimensions.w20, vertical: Dimensions.h20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.r16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).textTheme.bodyMedium!.color!
                : Theme.of(context).dividerTheme.color!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).textTheme.bodyMedium!.color!,
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
            SizedBox(width: Dimensions.w20),
            Image.asset(languageModel.imageUrl!, width: 36, height: 36),
            SizedBox(width: Dimensions.w10),
            Text(
              languageModel.languageName!,
              style: textRegular().copyWith(fontSize: Dimensions.fs16),
            ),
          ],
        ),
      ),
    );
  }
}
