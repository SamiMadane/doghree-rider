import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final Widget? actionWidget;
  final double? elevation;
  final bool? centerTitle;

  const CustomAppBarWidget({
    super.key,
    this.title,
    this.titleWidget,
    this.isBackButtonExist = true,
    this.onBackPressed,
    this.actionWidget,
    this.elevation,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: robotoSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                )
              : null),
      centerTitle: centerTitle,
      leadingWidth: 50,
      leading: (isBackButtonExist
          ? IconButton(
              icon: Get.locale?.languageCode ==
                      AppConstants.languages[1].languageCode
                  ? SvgPicture.asset(
                      ManagerAssets.arrowRightIcon,
                      color: Theme.of(context).iconTheme.color,
                    )
                  : SvgPicture.asset(
                      ManagerAssets.arrowBackIcon,
                      color: Theme.of(context).iconTheme.color,
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
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Theme.of(context).cardColor,
      shadowColor: Theme.of(context).disabledColor.withAlpha(128),
      elevation: elevation ?? 0,
      scrolledUnderElevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
          child: actionWidget ?? const SizedBox(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size(1170, GetPlatform.isDesktop ? 70 : 50);
}
