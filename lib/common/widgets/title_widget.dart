import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final Function? onTap;
  final bool showOrderCount;
  final int? orderCount;
  final TextStyle? titleStyle;
  final TextStyle? countStyle;

  const TitleWidget({
    super.key,
    required this.title,
    this.onTap,
    this.showOrderCount = false,
    this.orderCount,
    this.titleStyle,
    this.countStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:  Dimensions.paddingSizeExtraSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
      
          showOrderCount 
              ? Row(
                  children: [
                    Text(title, style: titleStyle ?? robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    CircleAvatar(
                      radius: Dimensions.radiusMedium,
                      backgroundColor: ManagerColors.darkGreen,
                      child: Text(
                        '$orderCount',
                        style: countStyle ?? robotoSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: ManagerColors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : Text(title, style: titleStyle ?? robotoMedium),
      
          onTap != null
              ? InkWell(
                  onTap: onTap as void Function()?,
                  child: Text(
                    'view_all'.tr,
                    style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: ManagerColors.darkGreen,),
                  ),
                )
              : const SizedBox(),
      
        ],
      ),
    );
  }
}
