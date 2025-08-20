import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sixam_mart_delivery/features/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final IconData? iconData;
  final String? svgPath;
  final String? label;
  final Function? onTap;
  final bool isSelected;
  final int? pageIndex;
  final bool showBadge; 

  const BottomNavItemWidget({
    super.key,
    this.iconData,
    this.svgPath,
    this.label,
    this.onTap,
    this.isSelected = false,
    this.pageIndex,
    this.showBadge = false, 
  }) : assert(iconData != null || svgPath != null,
            'Either iconData or svgPath must be provided');

  @override
  Widget build(BuildContext context) {
    Widget displayedIcon = svgPath != null
        ? SvgPicture.asset(
            svgPath!,
            height: isSelected ? 25 : 24,
            width: isSelected ? 25 : 24,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).hintColor,
          )
        : Icon(
            iconData,
            size: isSelected ? 25 : 24,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).hintColor,
          );

    return Flexible(
      fit: FlexFit.tight,
      child: GestureDetector(
        onTap: onTap as void Function()?,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Stack فقط حول الأيقونة
            Stack(
              clipBehavior: Clip.none,
              children: [
                displayedIcon,
                if (showBadge && pageIndex == 1)
                  Positioned(
                    top: -5,
                    right: -5, // ثابت بالنسبة للأيقونة
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: GetBuilder<OrderController>(
                        builder: (orderController) {
                          return Text(
                            orderController.latestOrderList?.length
                                    .toString() ??
                                '0',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
            if (label != null) SizedBox(height: isSelected ? 2 : 3),
            if (label != null)
              Flexible(
                child: Text(
                  label!,
                  style: isSelected
                      ? robotoSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).primaryColor,
                        )
                      : robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).hintColor,
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
