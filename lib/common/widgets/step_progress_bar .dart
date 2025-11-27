import 'package:flutter/material.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_colors.dart';

class StepProgressBar extends StatelessWidget {
  final double status;
  final bool showDivider;
  final Color? color;
  const StepProgressBar(
      {super.key, required this.status, this.showDivider = true, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          height: 6,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: status == 0.4
                        ? color ?? ManagerColors.darkGreen
                        : color ?? ManagerColors.darkGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              SizedBox(width: Dimensions.p10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: status != 0.4
                        ? color ?? ManagerColors.darkGreen
                        : Theme.of(context).disabledColor.withAlpha(128),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) ...[
          const SizedBox(height: Dimensions.p10),
          Divider(),
        ]
      ],
    );
  }
}
