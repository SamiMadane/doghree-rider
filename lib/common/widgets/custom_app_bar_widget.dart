import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/app_constants.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/styles.dart';
class CustomAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final Widget? actionWidget;
  final double? elevation;
  final bool? centerTitle;
  final PreferredSizeWidget? bottom;
  final Color? backGroundColor;
  final Color? titleColor;
  final Color? iconColor;

  const CustomAppBarWidget({
    super.key,
    this.title,
    this.titleWidget,
    this.isBackButtonExist = true,
    this.onBackPressed,
    this.actionWidget,
    this.elevation,
    this.centerTitle = true,
    this.backGroundColor,
    this.bottom,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedTitleColor =
        titleColor ?? Theme.of(context).textTheme.bodyMedium!.color!;

    final Color resolvedIconColor =
        iconColor ?? Theme.of(context).iconTheme.color!;

    return AppBar(
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: robotoSemiBold.copyWith(
                    fontSize: Dimensions.fs18,
                    color: resolvedTitleColor,
                  ),
                )
              : null),
      bottom: bottom,
      centerTitle: centerTitle,
      leadingWidth: 50,
      leading: (isBackButtonExist
          ? IconButton(
              icon: Get.locale?.languageCode ==
                      AppConstants.languages[1].languageCode
                  ? SvgPicture.asset(
                      ManagerAssets.arrowRightIcon,
                      color: resolvedIconColor,
                    )
                  : SvgPicture.asset(
                      ManagerAssets.arrowBackIcon,
                      color: resolvedIconColor,
                    ),
              onPressed: () {
                if (onBackPressed != null) {
                  onBackPressed!();
                } else if (Get.previousRoute.isNotEmpty) {
                  Get.back();
                } else {
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                }
              },
            )
          : null),
      backgroundColor: backGroundColor ?? Theme.of(context).cardColor,
      surfaceTintColor: Theme.of(context).cardColor,
      shadowColor: Theme.of(context).disabledColor.withAlpha(128),
      elevation: elevation ?? 0,
      scrolledUnderElevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: Dimensions.p16),

          child: actionWidget ?? const SizedBox(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize {
    final double baseHeight = GetPlatform.isDesktop ? 70 : kToolbarHeight;
    final double bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(baseHeight + bottomHeight);
  }
}
