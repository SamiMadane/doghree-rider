import 'package:flutter/material.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/common/widgets/step_progress_bar%20.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/util/theme_extension.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class RescheduleBottomSheet extends StatefulWidget {
  const RescheduleBottomSheet({super.key});

  @override
  State<RescheduleBottomSheet> createState() => _RescheduleBottomSheetState();
}

class _RescheduleBottomSheetState extends State<RescheduleBottomSheet> {
  int currentStep = 0;
  String? selectedReason;
  String? selectedDay;
  String? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: Dimensions.p20,
        left: Dimensions.p16,
        right: Dimensions.p16,
        top: Dimensions.p10,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildStep(),
      ),
    );
  }

  Widget _buildStep() {
    switch (currentStep) {
      case 0:
        return _buildReasonStep();
      case 1:
        return _buildDateStep();
      case 2:
        return _buildConfirmStep();
      default:
        return const SizedBox();
    }
  }

  /// STEP 1: Reason
  Widget _buildReasonStep() {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return _BottomSheetContainer(
      title: "reschedule_delivery".tr,
      subtitle: "last_reason_rescheduling".tr,
      name: 'Youssef Mahmoud Abdel Rahman',
      statusForStepProgressBar: 0.4,
      children: [
        SelectableButton(
          text: "lack_of_beneficiary".tr,
          selected: selectedReason == "lack_of_beneficiary".tr,
          onTap: () =>
              setState(() => selectedReason = "lack_of_beneficiary".tr),
        ),
        SelectableButton(
          text: "invalid_address".tr,
          selected: selectedReason == "invalid_address".tr,
          onTap: () => setState(() => selectedReason = "invalid_address".tr),
        ),
        SelectableButton(
          text: "refusal_to_receive".tr,
          selected: selectedReason == "refusal_to_receive".tr,
          onTap: () => setState(() => selectedReason = "refusal_to_receive".tr),
        ),
        SelectableButton(
          text: "other_conditions".tr,
          selected: selectedReason == "other_conditions".tr,
          onTap: () => setState(() => selectedReason = "other_conditions".tr),
        ),
        const SizedBox(height: Dimensions.p23),
        Row(
          children: [
            Expanded(
              child: CustomButtonWidget(
                onPressed: () => Navigator.pop(context),
                buttonText: 'cancel'.tr,
                radius: Dimensions.r12,
                backgroundColor: customColor.disabledButton,
                fontColor: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(width: Dimensions.p16),
            Expanded(
              child: CustomButtonWidget(
                onPressed: selectedReason != null
                    ? () => setState(() => currentStep = 1)
                    : null,
                buttonText: 'next'.tr,
                radius: Dimensions.r12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// STEP 2: Date & Time
  Widget _buildDateStep() {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return _BottomSheetContainer(
      title: "choose_date_time".tr,
      subtitle: "${'reason'.tr} $selectedReason",
      statusForStepProgressBar: 0.8,
      children: [
        Row(
          children: [
            Expanded(
              child: SelectableButton(
                text: "tomorrow".tr,
                selected: selectedDay == "tomorrow".tr,
                onTap: () => setState(() => selectedDay = "tomorrow".tr),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SelectableButton(
                text: "next_day".tr,
                selected: selectedDay == "next_day".tr,
                onTap: () => setState(() => selectedDay = "next_day".tr),
              ),
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: Dimensions.p8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: Dimensions.p8,
          mainAxisSpacing: Dimensions.p8,
          childAspectRatio: 3.2,
          children: [
            SelectableButton(
              text: "09.00 am",
              selected: selectedTime == "09.00 am",
              onTap: () => setState(() => selectedTime = "09.00 am"),
              isTimeButton: true,
            ),
            SelectableButton(
              text: "11.00 am",
              selected: selectedTime == "11.00 am",
              onTap: () => setState(() => selectedTime = "11.00 am"),
              isTimeButton: true,
            ),
            SelectableButton(
              text: "01.00 pm",
              selected: selectedTime == "01.00 pm",
              onTap: () => setState(() => selectedTime = "01.00 pm"),
              isTimeButton: true,
            ),
            SelectableButton(
              text: "03.00 pm",
              selected: selectedTime == "03.00 pm",
              onTap: () => setState(() => selectedTime = "03.00 pm"),
              isTimeButton: true,
            ),
          ],
        ),
        const SizedBox(height: Dimensions.p23),
        Row(
          children: [
            Expanded(
              child: CustomButtonWidget(
                onPressed: () => Navigator.pop(context),
                buttonText: 'cancel'.tr,
                fontSize: Dimensions.fs15,
                radius: Dimensions.r12,
                backgroundColor: customColor.disabledButton,
                fontColor: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButtonWidget(
                onPressed: (selectedDay != null && selectedTime != null)
                    ? () => setState(() => currentStep = 2)
                    : null,
                buttonText: 'confirm_rescheduling'.tr,
                fontSize: Dimensions.fs15,
                radius: Dimensions.r12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// STEP 3: Confirmation
  Widget _buildConfirmStep() {
    return Column(
      children: [
        const SizedBox(height: Dimensions.p30),
        Image.asset(
          ManagerAssets.confirmedImage,
        ),
        const SizedBox(height: Dimensions.p30),
        Text(
          'rescheduling_confirmed'.tr,
          style: robotoBold.copyWith(fontSize: Dimensions.fs20),
        ),
        const SizedBox(height: Dimensions.p16),
        ConfirmInfoRow(
            title: "beneficiary".tr, value: "Youssef Mahmoud Abdel Rahman"),
        ConfirmInfoRow(title: "reason".tr, value: selectedReason ?? "-"),
        ConfirmInfoRow(title: "new_date".tr, value: selectedDay ?? "-"),
        ConfirmInfoRow(title: "time".tr, value: selectedTime ?? "-"),
        const SizedBox(height: Dimensions.p40),
        CustomButtonWidget(
          onPressed: () => Navigator.pop(context),
          buttonText: 'done'.tr,
          backgroundColor: ManagerColors.greenLightMode,
          radius: Dimensions.r12,
        ),
      ],
    );
  }
}

//// ---------------- SHARED WIDGETS -----------------

class _BottomSheetContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? name;
  final List<Widget> children;
  final double statusForStepProgressBar;

  const _BottomSheetContainer({
    required this.title,
    required this.children,
    required this.statusForStepProgressBar,
    this.name,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: Dimensions.p20,
          ),
          StepProgressBar(
            status: statusForStepProgressBar,
            showDivider: false,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(
            height: Dimensions.p20,
          ),
          Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fs20)),
          if (subtitle != null) ...[
            const SizedBox(height: Dimensions.p16),
            Text(subtitle!,
                style: robotoRegular.copyWith(fontSize: Dimensions.fs16)),
          ],
          if (name != null) ...[
            const SizedBox(height: Dimensions.p4),
            Text(name!, style: robotoBold.copyWith(fontSize: Dimensions.fs16)),
          ],
          const SizedBox(height: Dimensions.p25),
          ...children,
        ],
      ),
    );
  }
}

class SelectableButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final bool isTimeButton;

  const SelectableButton({
    required this.text,
    required this.selected,
    required this.onTap,
    this.isTimeButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.p8),
      child: CustomButtonWidget(
        onPressed: onTap,
        isBorder: true,
        radius: Dimensions.r8,
        borderColor:
            selected ? Theme.of(context).primaryColor : customColor.strock1,
        backgroundColor:
            selected ? customColor.primaryBg : Theme.of(context).cardColor,
        transparent: selected ? false : true,
        buttonText: text,
        fontColor: selected && !isTimeButton
            ? Theme.of(context).primaryColor
            : Theme.of(context).textTheme.bodyMedium?.color,
        isBold: selected,
      ),
    );
  }
}

class ConfirmInfoRow extends StatelessWidget {
  final String title;
  final String value;

  const ConfirmInfoRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.p8),
      child: Row(
        children: [
          Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fs16)),
          const SizedBox(width: Dimensions.p4),
          Text(value, style: robotoRegular.copyWith(fontSize: Dimensions.fs16)),
        ],
      ),
    );
  }
}
