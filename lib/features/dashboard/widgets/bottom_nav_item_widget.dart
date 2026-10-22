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
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool small = Get.width < 360;
    final double iconSize = small ? 22 : 24;
    final String iconPath = isSelected ? selectedIcon : unSelectedIcon;

    // نشط: أسفلت على الفاتح / أصفر على الداكن. غير نشط: رمادي الثيم.
    final Color activeColor = cs.onPrimaryContainer;
    final Color iconColor = isSelected ? activeColor : cs.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap as void Function()?,
        splashColor: cs.primary.withValues(alpha: 0.12),
        highlightColor: Colors.transparent,
        child: Padding(
       padding: EdgeInsets.only(
  top: small ? 14 : 16,
  bottom: small ? 4 : 6,
  left: 2,
  right: 2,
),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الحبة خلف الأيقونة
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: 56,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:  Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      iconPath,
                      height: iconSize,
                      width: iconSize,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                    if (showBadge && pageIndex == 1)
                      PositionedDirectional(
                        top: -2,
                        end: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          constraints: const BoxConstraints(
                              minWidth: 16, minHeight: 16),
                          decoration: BoxDecoration(
                            color: cs.error,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).cardColor,
                              width: 1.5,
                            ),
                          ),
                          child: GetBuilder<OrderController>(
                            builder: (orderController) => Text(
                              orderController.latestOrderList?.length
                                      .toString() ??
                                  '0',
                              textAlign: TextAlign.center,
                              style: textBold().copyWith(
                                fontSize: 9,
                                color: cs.onError,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (label != null) SizedBox(height: small ? 2 : 3),
              if (label != null)
                Flexible(
                  child: Text(
                    label!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: (isSelected ? textBold() : textMedium()).copyWith(
                      fontSize: small ? 9.5 : 10.5,
                      color: iconColor,
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