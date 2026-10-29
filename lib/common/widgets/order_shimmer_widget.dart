import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:doghree_rider/common/widgets/app_shimmer.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class OrderShimmerWidget extends StatelessWidget {
  final bool isEnabled;
  final EdgeInsetsGeometry? margin;

  const OrderShimmerWidget({
    super.key,
    required this.isEnabled,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle title = textSemiBold().copyWith(fontSize: Dimensions.fs14);
    final TextStyle subtitle =
        textRegular().copyWith(fontSize: Dimensions.fs14);

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
                  child: AppShimmerTextLine(
                    style: title,
                    width: 90,
                    enabled: isEnabled,
                  ),
                ),
              ),
              // نفس padding وشكل شارة الدفع
              AppShimmerBlock(
                width: 70,
                radius: Dimensions.r20,
                enabled: isEnabled,
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.w12,
                  vertical: Dimensions.h4,
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
            ],
          ),
          SizedBox(height: Dimensions.h16),

          // أيقونات + خطوط
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  AppShimmerBlock(
                    height: Dimensions.h28,
                    width: Dimensions.w28,
                    circle: true,
                    enabled: isEnabled,
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
                  AppShimmerBlock(
                    height: Dimensions.h24,
                    width: Dimensions.w24,
                    circle: true,
                    enabled: isEnabled,
                  ),
                ],
              ),
              SizedBox(width: Dimensions.w8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المتجر
                    AppShimmerTextLine(
                        style: title, width: 140, enabled: isEnabled),
                    // عنوان المتجر
                    AppShimmerTextLine(
                        style: subtitle, width: 200, enabled: isEnabled),
                    SizedBox(height: Dimensions.h4),
                    SizedBox(height: Dimensions.h20),
                    // عنوان التوصيل / المتجر
                    AppShimmerTextLine(
                        style: title, width: 170, enabled: isEnabled),
                    // Label
                    AppShimmerTextLine(
                        style: subtitle, width: 110, enabled: isEnabled),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // زر التفاصيل: بنفس ارتفاع الزر الحقيقي (حد أدنى أزرار الثيم 52)
          AppShimmerBlock(
            height: 52,
            width: double.infinity,
            radius: Dimensions.r20,
            enabled: isEnabled,
          ),
        ],
      ),
    );
  }
}