import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/util/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final String selectedIcon;
  final String unSelectedIcon;
  final String? label;
  final Function? onTap;
  final bool isSelected;
  final int? pageIndex;
  final bool showBadge;

  const BottomNavItemWidget({
    super.key,
    required this.selectedIcon,
    required this.unSelectedIcon,
    this.label,
    this.onTap,
    this.isSelected = false,
    this.pageIndex,
    this.showBadge = false,
  });
  @override
  Widget build(BuildContext context) {
    // حساب حجم الأيقونة بناءً على حجم الشاشة
    final iconSize = Get.width < 360 ? 20.0 : (isSelected ? 24.0 : 22.0);
    final String iconPath = isSelected ? selectedIcon : unSelectedIcon;
    final Color iconColor = isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).textTheme.bodyMedium!.color!;

    return Expanded(
      child: InkWell(
        onTap: onTap as void Function()?,
        splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 56, // الحد الأدنى للارتفاع
          ),
          padding: EdgeInsets.symmetric(
            vertical: Get.width < 360 ? 6 : 8,
            horizontal: 2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الأيقونة مع Badge
              SizedBox(
                height: iconSize + 4,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(iconPath,
                        height: iconSize, width: iconSize, color: iconColor),
                    if (showBadge && pageIndex == 1)
                      Positioned(
                        top: -4,
                        right: -6,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 1.5,
                            ),
                          ),
                          child: GetBuilder<OrderController>(
                            builder: (orderController) {
                              return Text(
                                orderController.latestOrderList?.length
                                        .toString() ??
                                    '0',
                                textAlign: TextAlign.center,
                                style: textRegular().copyWith(
                                  fontSize: 9,
                                  color: Colors.white,
                                  height: 1.2,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // النص
              if (label != null) SizedBox(height: Get.width < 360 ? 2 : 3),
              if (label != null)
                Flexible(
                  child: Text(
                    label!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: isSelected
                        ? textSemiBold().copyWith(
                            fontSize: Get.width < 360 ? 9.5 : 10.5,
                            color: Theme.of(context).primaryColor,
                            height: 1.1,
                          )
                        : textRegular().copyWith(
                            fontSize: Get.width < 360 ? 9 : 10,
                            color: Theme.of(context).hintColor,
                            height: 1.1,
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
