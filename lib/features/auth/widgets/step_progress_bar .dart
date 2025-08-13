import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';

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
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: status != 0.4
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor.withAlpha(128),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        const Divider(
          height: 1, // ارتفاع الخط الخفيف
          thickness: 1, // سماكة الخط
          color: Color(0xFFE5E8F4), // لون الخط
        ),
      ],
    );
  }
}
