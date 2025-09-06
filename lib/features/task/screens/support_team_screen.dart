import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/util/theme_extension.dart';
import 'package:get/get.dart';

class SupportTeamScreen extends StatefulWidget {
  const SupportTeamScreen({super.key});

  @override
  State<SupportTeamScreen> createState() => _SupportTeamScreenState();
}

class _SupportTeamScreenState extends State<SupportTeamScreen> {
  String? selectedIssue; // مبدئياً ما في اختيار

  final List<String> issues = [
    "the_title_still_wrong",
    "beneficiary_not_found",
    "phone_not_working",
    "security_problem",
    "difficulty_accessing",
    "other",
  ];

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'inform_support_team'.tr,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Beneficiary Card
                  CustomCard(
                    padding: const EdgeInsets.all(Dimensions.p16),
                    borderRadius: Dimensions.r12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'beneficiary'.tr,
                          style: robotoBold.copyWith(fontSize: Dimensions.fs17),
                        ),
                        const SizedBox(height: Dimensions.p12),
                        CustomCard(
                          padding: const EdgeInsets.all(Dimensions.p16),
                          borderRadius: Dimensions.r12,
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Noura Abdullah Ibrahim',
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fs17,
                                ),
                              ),
                              const SizedBox(height: Dimensions.p8),
                              Text(
                                'manually_updated_task'.tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fs13,
                                  color: customColor.naturalBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Dimensions.p12),

                  /// Issue Type
                  CustomCard(
                    padding: const EdgeInsets.all(Dimensions.p16),
                    borderRadius: Dimensions.r12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'type_of_issue'.tr,
                          style: robotoBold.copyWith(fontSize: Dimensions.fs17),
                        ),
                        const SizedBox(height: Dimensions.p12),
                        Column(
                          children: issues
                              .map(
                                (issueKey) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: selectableCard(
                                    text: issueKey.tr,
                                    isSelected: selectedIssue == issueKey,
                                    onTap: () {
                                      setState(() {
                                        selectedIssue = issueKey;
                                      });
                                    },
                                    context: context,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        SizedBox(height: Dimensions.p16),
                        Text(
                          "more_details".tr,
                          style: robotoBold.copyWith(fontSize: Dimensions.fs17),
                        ),
                        const SizedBox(height: Dimensions.p12),
                        TextField(
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "write_details_here".tr,
                            hintStyle: robotoRegular.copyWith(
                                color: Theme.of(context).hintColor),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.r12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.r12),
                              borderSide: BorderSide(
                                color: customColor.strock2,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.r12),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.p16),
                        CustomCard(
                          padding: const EdgeInsets.all(Dimensions.p16),
                          borderRadius: Dimensions.r12,
                          fillColor: customColor.blueBg,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "info_sent_automatically".tr,
                                style: robotoBold.copyWith(
                                    fontSize: Dimensions.fs16,
                                    color: customColor.darkBlue),
                              ),
                              const SizedBox(height: Dimensions.p10),
                              infoRow('${'task_id'.tr} 646848646'),
                              infoRow('${'current_location'.tr}: 31.154, 34.546'),
                              infoRow('${'reporting_time'.tr} 3/8/2025 - PM 8:04:12'),
                              infoRow('${'last_update_date'.tr}  yesterday, 03:15 PM'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: const Offset(0, -3),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.r8),
                  topRight: Radius.circular(Dimensions.r8),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButtonWidget(
                      onPressed: selectedIssue == null
                          ? null
                          : () {
                              print("Report sent with issue: $selectedIssue");
                            },
                      buttonText: 'send_report'.tr,
                      backgroundColor: ManagerColors.blueLightMode,
                      radius: Dimensions.r12,
                    ),
                  ),
                  const SizedBox(width: Dimensions.p12),
                  Expanded(
                    child: CustomButtonWidget(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      buttonText: 'cancel'.tr,
                      fontColor: Theme.of(context).textTheme.bodyMedium?.color,
                      backgroundColor: customColor.disabledButton,
                      radius: Dimensions.r12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String text) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: customColor.blue,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: Dimensions.p6),
          Expanded(
            child: Text(
              text,
              style:
                  robotoSemiBold.copyWith(fontSize: Dimensions.fs14, color: customColor.blue),
            ),
          ),
        ],
      ),
    );
  }
}

Widget selectableCard({
  required String text,
  required bool isSelected,
  VoidCallback? onTap,
  required BuildContext context,
}) {
  return GestureDetector(
    onTap: onTap,
    child: CustomCard(
      padding: const EdgeInsets.all(Dimensions.p16),
      borderRadius: Dimensions.r12,
      borderColor: isSelected ? Theme.of(context).primaryColor : null,
      fillColor: Theme.of(context).scaffoldBackgroundColor,
      borderwidth: isSelected ? 1.5 : null,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context)
                        .extension<CustomColorsExtension>()!
                        .strock1,
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
          const SizedBox(width: Dimensions.p10),
          Text(
            text,
            style: robotoRegular.copyWith(fontSize: Dimensions.fs16),
          ),
        ],
      ),
    ),
  );
}
