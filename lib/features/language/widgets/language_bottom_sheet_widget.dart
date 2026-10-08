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
        padding: EdgeInsets.only(top: Dimensions.h20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
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
          SizedBox(height: Dimensions.h20),

          Text('choose_your_language'.tr,
              style: textSemiBold().copyWith(
                  fontSize: Dimensions.fs18)),
          SizedBox(height: Dimensions.h25),

          Flexible(
            child: SingleChildScrollView(
              child: ListView.builder(
                itemCount: localizationController.languages.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.w20),
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
                       SizedBox(
                          height: Dimensions
                              .h10), // المسافة بين البطاقات
                    ],
                  );
                },
              ),
            ),
          ),

          SizedBox(height: Dimensions.h16), // فاصل آمن
        ]),
      );
    });
  }
}
