import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class Tip {
  final String text;
  final Color color;

  Tip({required this.text, required this.color});
}

class TipCardWidget extends StatelessWidget {
  final String title;
  final Color titleColor;
  final List<Tip> tips;
  final Color? backgroundColor;

  const TipCardWidget({
    super.key,
    required this.title,
    required this.titleColor,
    required this.tips,
    this.backgroundColor,
  });

  Widget _tipRow(Tip tip) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: tip.color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: Dimensions.p8),
        Expanded(
          child: Text(
            tip.text,
            style: robotoSemiBold.copyWith(color: tip.color),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      fillColor: backgroundColor ?? Theme.of(context).cardColor,
      padding: const EdgeInsets.all(Dimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fs16,
              color: titleColor,
            ),
          ),
          SizedBox(height: Dimensions.p10),
          ...tips.expand((tip) sync* {
            yield _tipRow(tip);
            if (tip != tips.last) yield SizedBox(height: Dimensions.p8);
          }),
        ],
      ),
    );
  }
}
