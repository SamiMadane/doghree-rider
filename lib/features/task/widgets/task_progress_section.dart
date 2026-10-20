import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/theme_extension.dart';

class TaskProgressSection extends StatelessWidget {
  final int completed;
  final int remaining;
  final int issue;

  const TaskProgressSection({
    super.key,
    required this.completed,
    required this.remaining,
    required this.issue,
  });

  @override
  Widget build(BuildContext context) {
    final int total = completed + remaining + issue;
    final double progress = total > 0 ? completed / total : 0;
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('list_of_beneficiaries'.tr,
            style: textBold().copyWith(fontSize: Dimensions.fs18)),
        SizedBox(height: Dimensions.h16),
        Row(
          children: [
            Text('remaining_task'.tr,
                style: textBold().copyWith(fontSize: Dimensions.fs16)),
            Spacer(),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: '$completed', // الرقم الأول
                      style: textBold().copyWith(
                          fontSize: Dimensions.fs18,
                          color: customColor.naturalBlue)),
                  TextSpan(
                      text: '/', // الفاصل
                      style: textBold().copyWith(
                          fontSize: Dimensions.fs18,
                          color:
                              Theme.of(context).textTheme.bodyMedium?.color)),
                  TextSpan(
                      text: '$total', // الرقم الثاني
                      style: textBold().copyWith(
                          fontSize: Dimensions.fs18,
                          color:
                              Theme.of(context).textTheme.bodyMedium?.color)),
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: Dimensions.h12,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.r8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            color: ManagerColors.lightGreen,
            backgroundColor: customColor.gray,
          ),
        ),
        SizedBox(
          height: Dimensions.h12,
        ),
        Row(
          children: [
            _legendCircle(ManagerColors.oliveGreen, '$completed ${'completed'.tr}'),
            _legendCircle(ManagerColors.orangeLightMode, '$remaining ${'remaining'.tr}'),
            _legendCircle(ManagerColors.red, '$issue ${'issue'.tr}'),
          ],
        ),
      ],
    );
  }

  Widget _legendCircle(Color color, String text) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: Dimensions.w4),
          Text(
            text,
            style: textMedium(),
          ),
        ],
      ),
    );
  }
}
