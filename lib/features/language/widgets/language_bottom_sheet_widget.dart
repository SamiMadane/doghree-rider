import 'package:sixam_mart_delivery/features/language/widgets/language_card_widget.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:get/get.dart';

class LanguageBottomSheetWidget extends StatefulWidget {
  final bool isFromInitScreen;
  LanguageBottomSheetWidget({
    super.key,
    this.isFromInitScreen = false,
  });

  @override
  State<LanguageBottomSheetWidget> createState() =>
      _LanguageBottomSheetWidgetState();
}

class _LanguageBottomSheetWidgetState extends State<LanguageBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
        builder: (localizationController) {
      return Container(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            height: 5,
            width: 35,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text('choose_your_language'.tr,
              style: robotoSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge)),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          Flexible(
            child: SingleChildScrollView(
              child: ListView.builder(
                itemCount: localizationController.languages.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      LanguageCardWidget(
                        languageModel: localizationController.languages[index],
                        localizationController: localizationController,
                        index: index,
                        fromBottomSheet: true,
                        isFromInitScreen: widget.isFromInitScreen,
                      ),
                      const SizedBox(
                          height: Dimensions
                              .paddingSizeSmall), // المسافة بين البطاقات
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault), // فاصل آمن
        ]),
      );
    });
  }
}
