import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('list_of_beneficiaries'.tr,
            style: robotoBold.copyWith(fontSize: Dimensions.fs18)),
        const SizedBox(height: Dimensions.p16),
        Row(
          children: [
            Text('remaining_task'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fs16)),
            Spacer(),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: '$completed', // الرقم الأول
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fs18,
                          color: ManagerColors.textBlue)),
                  TextSpan(
                      text: '/', // الفاصل
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fs18,
                          color:
                              Theme.of(context).textTheme.bodyMedium?.color)),
                  TextSpan(
                      text: '$total', // الرقم الثاني
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fs18,
                          color:
                              Theme.of(context).textTheme.bodyMedium?.color)),
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: Dimensions.p12,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.r8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            color: ManagerColors.lightGreen,
            backgroundColor: ManagerColors.grayBg,
          ),
        ),
        SizedBox(
          height: Dimensions.p12,
        ),
        Row(
          children: [
            _legendCircle(ManagerColors.green, '$completed ${'completed'.tr}'),
            _legendCircle(ManagerColors.orange, '$remaining ${'remaining'.tr}'),
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
          const SizedBox(width: Dimensions.p5),
          Text(
            text,
            style: robotoMedium,
          ),
        ],
      ),
    );
  }
}
