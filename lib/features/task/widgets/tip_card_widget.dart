import 'package:flutter/material.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';

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
        SizedBox(width: Dimensions.w8),
        Expanded(
          child: Text(
            tip.text,
            style: textSemiBold().copyWith(color: tip.color),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      fillColor: backgroundColor ?? Theme.of(context).cardColor,
      padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textBold().copyWith(
              fontSize: Dimensions.fs16,
              color: titleColor,
            ),
          ),
          SizedBox(height: Dimensions.h10),
          ...tips.expand((tip) sync* {
            yield _tipRow(tip);
            if (tip != tips.last) yield SizedBox(height: Dimensions.h8);
          }),
        ],
      ),
    );
  }
}
