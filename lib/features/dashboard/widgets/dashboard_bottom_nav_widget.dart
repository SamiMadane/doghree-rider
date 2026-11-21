import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:doghree_rider/features/dashboard/widgets/bottom_nav_road_indicator.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';

/// The dashboard's floating bottom nav (home, requests, my orders, profile).
/// [onTap] receives the tapped tab index; the dashboard decides what happens.
class DashboardBottomNavWidget extends StatelessWidget {
  final int pageIndex;
  final int itemCount;
  final ValueChanged<int> onTap;

  const DashboardBottomNavWidget({
    super.key,
    required this.pageIndex,
    required this.itemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            Dimensions.w16, 0, Dimensions.w16, Dimensions.h10),
        child: Container(
          height: Dimensions.h76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.r24),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.0 : 0.12,
                ),
                blurRadius: Dimensions.r18,
                offset: Offset(0, Dimensions.h6),
              ),
            ],
          ),
          child: Material(
            color: theme.cardColor,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.r24),
              side: BorderSide(color: cs.outline),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Row(
                    children: [
                      BottomNavItemWidget(
                        label: 'home'.tr,
                        isSelected: pageIndex == 0,
                        onTap: () => onTap(0),
                        selectedIcon: ManagerAssets.homeSelectedIcon,
                        unSelectedIcon: ManagerAssets.homeIcon,
                      ),
                      BottomNavItemWidget(
                        label: 'orders'.tr,
                        isSelected: pageIndex == 1,
                        pageIndex: 1,
                        onTap: () => onTap(1),
                        selectedIcon: ManagerAssets.orderSelectedIcon,
                        unSelectedIcon: ManagerAssets.orderIcon,
                      ),
                      BottomNavItemWidget(
                        label: 'my_orders'.tr,
                        isSelected: pageIndex == 2,
                        onTap: () => onTap(2),
                        selectedIcon: ManagerAssets.myOrderSelectedIcon,
                        unSelectedIcon: ManagerAssets.myOrderIcon,
                      ),
                      BottomNavItemWidget(
                        label: 'profile'.tr,
                        isSelected: pageIndex == 3,
                        onTap: () => onTap(3),
                        selectedIcon: ManagerAssets.profileSelectedIcon,
                        unSelectedIcon: ManagerAssets.userIcon,
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: BottomNavRoadIndicator(
                    index: pageIndex,
                    count: itemCount,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
