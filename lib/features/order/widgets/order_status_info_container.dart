import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class OrderStatusInfoContainer extends StatelessWidget {
  final bool processing;

  const OrderStatusInfoContainer({super.key, required this.processing});

  @override
  Widget build(BuildContext context) {

    final Color mainColor = processing ? ManagerColors.darkGreen : ManagerColors.orange;
    final String text =
        processing ? 'order_is_preparing'.tr : 'order_waiting_for_process'.tr;
    final IconData icon =
        processing ? Icons.delivery_dining : Icons.timer_outlined;

    return CustomCard(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Row(
        children: [
          // أيقونة داخل دائرة ملونة
          CircleAvatar(
            radius: 22,
            backgroundColor: mainColor.withOpacity(0.15),
            child: Icon(icon, color: mainColor, size: 26),
          ),

          const SizedBox(width: 14),

          // النصوص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  processing ? 'Processing' : 'Pending',
                  style: robotoSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: mainColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
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
