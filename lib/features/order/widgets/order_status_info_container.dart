import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/styles.dart';

class OrderStatusInfoContainer extends StatelessWidget {
  final bool processing;

  const OrderStatusInfoContainer({super.key, required this.processing});

  @override
  Widget build(BuildContext context) {

    final Color mainColor = processing ? ManagerColors.darkGreen : ManagerColors.orangeLightMode;
    final String text =
        processing ? 'order_is_preparing'.tr : 'order_waiting_for_process'.tr;
    final IconData icon =
        processing ? Icons.delivery_dining : Icons.timer_outlined;

    return CustomCard(
      padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
      child: Row(
        children: [
          // أيقونة داخل دائرة ملونة
          CircleAvatar(
            radius: 22,
            backgroundColor: mainColor.withOpacity(0.15),
            child: Icon(icon, color: mainColor, size: 26),
          ),

          SizedBox(width: 14),

          // النصوص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  processing ? 'Processing'.tr : 'Pending'.tr,
                  style: textSemiBold().copyWith(
                    fontSize: Dimensions.fs14,
                    color: mainColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: textMedium().copyWith(
                    fontSize: Dimensions.fs12,
                    color: Theme.of(context).hintColor
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
