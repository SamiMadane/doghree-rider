import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';

class StepProgressBar extends StatelessWidget {
  final double status;
  const StepProgressBar({super.key, required this.status});

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
                        ? ManagerColors.darkGreen
                        : ManagerColors.darkGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              SizedBox(width: Dimensions.p10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: status != 0.4
                        ? ManagerColors.darkGreen
                        : Theme.of(context).disabledColor.withAlpha(128),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.p10),
        Divider(),
      ],
    );
  }
}
