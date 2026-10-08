import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_colors.dart';

class OrderShimmerWidget extends StatelessWidget {
  final bool isEnabled;
  const OrderShimmerWidget({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
      margin: EdgeInsetsDirectional.only(end: Dimensions.w16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID + حالة الدفع
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Shimmer(
                      enabled: isEnabled,
                      color: ManagerColors.shimmer,
                      child: Container(
                        height: 14,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Shimmer(
                enabled: isEnabled,
                color: ManagerColors.shimmer,
                child: Container(
                  height: 24,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(Dimensions.r20),
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
                  // Store Image
                  Shimmer(
                    enabled: isEnabled,
                    color: ManagerColors.shimmer,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Dotted Line
                  SizedBox(
                    height: 40,
                    child: DottedLine(
                      direction: Axis.vertical,
                      lineLength: double.infinity,
                      dashLength: 6,
                      dashColor: Theme.of(context).disabledColor,
                    ),
                  ),
                  // Location Icon
                  Shimmer(
                    enabled: isEnabled,
                    color: ManagerColors.shimmer,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store Name
                    Shimmer(
                      enabled: isEnabled,
                      color: ManagerColors.shimmer,
                      child: Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Store Address
                    Shimmer(
                      enabled: isEnabled,
                      color: ManagerColors.shimmer,
                      child: Container(
                        height: 12,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    SizedBox(height: Dimensions.h10),
                    // Delivery Location
                    Shimmer(
                      enabled: isEnabled,
                      color: ManagerColors.shimmer,
                      child: Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Location Label
                    Shimmer(
                      enabled: isEnabled,
                      color: ManagerColors.shimmer,
                      child: Container(
                        height: 12,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),

          SizedBox(height: Dimensions.h16),

          // Actions - Buttons
          Shimmer(
            enabled: isEnabled,
            color: ManagerColors.shimmer,
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}