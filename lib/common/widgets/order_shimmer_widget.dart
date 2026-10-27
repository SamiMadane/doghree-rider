import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';

class OrderShimmerWidget extends StatelessWidget {
  final bool isEnabled;
  final EdgeInsetsGeometry? margin;

  const OrderShimmerWidget({
    super.key,
    required this.isEnabled,
    this.margin,
  });

  /// كتلة شيمر بحجم ثابت
  Widget _block({
    required double height,
    double? width,
    double radius = 4,
    bool circle = false,
  }) {
    return Shimmer(
      enabled: isEnabled,
      color: ManagerColors.shimmer,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(radius),
        ),
      ),
    );
  }

  /// سطر شيمر ارتفاعه = ارتفاع النص الحقيقي بنفس الـ style
  Widget _textLine({required TextStyle style, double? width}) {
    return Shimmer(
      enabled: isEnabled,
      color: ManagerColors.shimmer,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          ' ',
          maxLines: 1,
          style: style.copyWith(color: Colors.transparent),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle title = textSemiBold().copyWith(fontSize: Dimensions.fs14);
    final TextStyle subtitle = textRegular().copyWith(fontSize: Dimensions.fs14);

    return CustomCard(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w16,
        vertical: Dimensions.h16,
      ),
      margin: margin ?? EdgeInsetsDirectional.only(end: Dimensions.w16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID + حالة الدفع
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _textLine(style: title, width: 90),
                ),
              ),
              // نفس padding وشكل شارة الدفع
              Shimmer(
                enabled: isEnabled,
                color: ManagerColors.shimmer,
                child: Container(
                  width: 70,
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.w12,
                    vertical: Dimensions.h4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(Dimensions.r20),
                  ),
                  child: Text(
                    ' ',
                    maxLines: 1,
                    style: textBold().copyWith(
                      fontSize: Dimensions.fs12,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.h16),

          // أيقونات + خطوط
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _block(
                    height: Dimensions.h28,
                    width: Dimensions.w28,
                    circle: true,
                  ),
                  SizedBox(
                    height: Dimensions.h40,
                    child: DottedLine(
                      direction: Axis.vertical,
                      lineLength: double.infinity,
                      dashLength: 8,
                      dashColor: Theme.of(context).disabledColor,
                    ),
                  ),
                  _block(
                    height: Dimensions.h24,
                    width: Dimensions.w24,
                    circle: true,
                  ),
                ],
              ),
              SizedBox(width: Dimensions.w8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المتجر
                    _textLine(style: title, width: 140),
                    // عنوان المتجر
                    _textLine(style: subtitle, width: 200),
                    SizedBox(height: Dimensions.h4),
                    SizedBox(height: Dimensions.h20),
                    // عنوان التوصيل / المتجر
                    _textLine(style: title, width: 170),
                    // Label
                    _textLine(style: subtitle, width: 110),
                  ],
                ),
              )
            ],
          ),

          const Spacer(),

          // زر التفاصيل
          _block(height: 40, width: double.infinity, radius: 8),
        ],
      ),
    );
  }
}