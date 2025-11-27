import 'package:wefrh_rider/features/language/widgets/language_card_widget.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:wefrh_rider/features/language/controllers/language_controller.dart';
import 'package:wefrh_rider/util/dimensions.dart';
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
        padding: const EdgeInsets.only(top: Dimensions.p20),
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
          const SizedBox(height: Dimensions.p20),

          Text('choose_your_language'.tr,
              style: robotoSemiBold.copyWith(
                  fontSize: Dimensions.fs18)),
          const SizedBox(height: Dimensions.p25),

          Flexible(
            child: SingleChildScrollView(
              child: ListView.builder(
                itemCount: localizationController.languages.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.p20),
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
                              .p10), // المسافة بين البطاقات
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: Dimensions.p16), // فاصل آمن
        ]),
      );
    });
  }
}
