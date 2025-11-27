import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/helper/price_converter_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/util/theme_extension.dart';

class FinishShiftScreen extends StatefulWidget {
  const FinishShiftScreen({super.key});

  @override
  State<FinishShiftScreen> createState() => _FinishShiftScreenState();
}

class _FinishShiftScreenState extends State<FinishShiftScreen> {
  bool isOption1Selected = false;
  bool isOption2Selected = false;
  bool isOption3Selected = false;

  bool get isAnyOptionSelected =>
      isOption1Selected || isOption2Selected || isOption3Selected;

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'finish_shift'.tr,
      ),
      body: Container(
        padding: EdgeInsets.all(Dimensions.p16),
        margin: EdgeInsets.only(
          top: Dimensions.p16,
        ),
        height: double.infinity,
        color: Theme.of(context).cardColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ملخص الشفت
              CustomCard(
                padding: EdgeInsets.all(Dimensions.p16),
                isBorder: false,
                fillColor:Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    SizedBox(height: Dimensions.p4),
                    Text(
                      'shift_summary'.tr,
                      style: robotoBold.copyWith(fontSize: Dimensions.fs18),
                    ),
                    SizedBox(height: Dimensions.p20),
                    Row(
                      children: [
                        _statusBox('3', 'delivered'.tr, customColor.primaryBg,
                            Theme.of(context).primaryColor),
                        SizedBox(width: Dimensions.p12),
                        _statusBox('3', 'remaining'.tr, customColor.orangeBg,
                            ManagerColors.orangeLightMode),
                        SizedBox(width: Dimensions.p12),
                        _statusBox('1', 'problem'.tr, customColor.redBg,
                            customColor.red),
                      ],
                    ),
                    SizedBox(height: Dimensions.p30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              ManagerAssets.flagIcon,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(width: Dimensions.p4),
                            Text(
                              'amount_to_be_delivered'.tr,
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fs16,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ],
                        ),
                        SizedBox(height: Dimensions.p8),
                        Text(PriceConverterHelper.convertPrice(47),
                            style: robotoSemiBold.copyWith(
                                fontSize: Dimensions.fs24,
                                color: Theme.of(context).primaryColor)),
                        SizedBox(height: Dimensions.p8),
                        Text(
                          'handover_message'.tr,
                          textAlign: TextAlign.center,
                          style:
                              robotoRegular.copyWith(fontSize: Dimensions.fs14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: Dimensions.p16),

              // خيارات التأكيد
              CustomCard(
                padding: EdgeInsets.all(Dimensions.p16),
                isBorder: false,
                fillColor:Theme.of(context).scaffoldBackgroundColor,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'confirmation_shift_termination'.tr,
                      style: robotoBold.copyWith(fontSize: Dimensions.fs18),
                    ),
                    SizedBox(height: Dimensions.p12),
                    selectableRow(
                      text: 'handover_funds'.tr,
                      isSelected: isOption1Selected,
                      onChanged: (val) {
                        setState(() {
                          isOption1Selected = val ?? false;
                        });
                      },
                      context: context,
                    ),
                    selectableRow(
                      text: 'reviewed_beneficiaries'.tr,
                      isSelected: isOption2Selected,
                      onChanged: (val) {
                        setState(() {
                          isOption2Selected = val ?? false;
                        });
                      },
                      context: context,
                    ),
                    selectableRow(
                      text: 'report_saved_sent'.tr,
                      isSelected: isOption3Selected,
                      onChanged: (val) {
                        setState(() {
                          isOption3Selected = val ?? false;
                        });
                      },
                      context: context,
                    ),
                    SizedBox(height: Dimensions.p30),

                    // زر التأكيد مع تفعيل/تعطيل
                    CustomButtonWidget(
                      buttonText: 'confirmation_shift_termination'.tr,
                      onPressed: isAnyOptionSelected
                          ? () {
                              // المنطق عند التأكيد
                            }
                          : null,
                      backgroundColor: isAnyOptionSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).disabledColor,
                    ),

                    SizedBox(height: Dimensions.p16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          ManagerAssets.downloadIcon,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(width: Dimensions.p8),
                        Text(
                          'download_final_report'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fs15,
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                            decorationColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimensions.p10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// صندوق الحالة
Widget _statusBox(String count, String title, Color bgColor, Color textColor) {
  return Expanded(
    child: CustomCard(
      padding: EdgeInsets.all(Dimensions.p12),
      fillColor: bgColor,
      isBorder: false,
      borderRadius: Dimensions.r8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(count,
              style: robotoBold.copyWith(
                  color: textColor, fontSize: Dimensions.fs18)),
          Text(title,
              style: robotoBold.copyWith(
                  color: textColor, fontSize: Dimensions.fs14)),
        ],
      ),
    ),
  );
}

// صف قابل للاختيار
Widget selectableRow({
  required String text,
  required bool isSelected,
  required ValueChanged<bool?> onChanged,
  required BuildContext context,
}) {
  return Row(
    children: [
      Checkbox(
        value: isSelected,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
        checkColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.r4),
        ),
      ),
      Expanded(
        child: Text(
          text,
          style: robotoRegular.copyWith(fontSize: Dimensions.fs15),
        ),
      ),
    ],
  );
}
