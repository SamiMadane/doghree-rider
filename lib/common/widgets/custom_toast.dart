import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class CustomToast extends StatelessWidget {
  final String text;
  final bool isError;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets? padding;

  const CustomToast({
    super.key,
    required this.text,
    this.textColor = Colors.white,
    this.borderRadius = 30,
    this.padding, required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(bottom: 40.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF334257),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding ?? EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            margin: EdgeInsets.only(
              right:Dimensions.w20,
              left: Dimensions.w20,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(isError ? CupertinoIcons.multiply_circle_fill : Icons.check_circle, color: isError ? const Color(0xffFF9090).withValues(alpha: 0.5) : const Color(0xff039D55), size: 20),
              SizedBox(width: Dimensions.w10),

              Flexible(child: Text(text, style: textRegular().copyWith(color: textColor), maxLines: 3, overflow: TextOverflow.ellipsis)),
            ]),
          ),
        ),
      ),
    );
  }
}