import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';

class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
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
    final ThemeData theme = Theme.of(context);

    final Color background = backGroundColor ?? theme.cardColor;
    final Color foreground = titleColor ?? theme.textTheme.bodyMedium!.color!;
    final Color resolvedIconColor = iconColor ?? foreground;

    // Status-bar icons follow the real background, even for custom colours.
    final bool lightBackground =
        ThemeData.estimateBrightnessForColor(background) == Brightness.light;
    final SystemUiOverlayStyle overlayStyle = (lightBackground
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light)
        .copyWith(statusBarColor: Colors.transparent);

    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    return AppBar(
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: textSemiBold().copyWith(
                    fontSize: Dimensions.fs18,
                    color: foreground,
                  ),
                )
              : null),
      bottom: bottom,
      centerTitle: centerTitle,
      leadingWidth: 50,
      leading: isBackButtonExist
          ? IconButton(
              icon: SvgPicture.asset(
                rtl
                    ? ManagerAssets.arrowRightIcon
                    : ManagerAssets.arrowBackIcon,
                colorFilter:
                    ColorFilter.mode(resolvedIconColor, BlendMode.srcIn),
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
          : null,
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      shadowColor: theme.shadowColor,
      systemOverlayStyle: overlayStyle,
      elevation: elevation ?? 0,
      scrolledUnderElevation: 0,
      actions: actionWidget == null
          ? null
          : [
              Padding(
                padding: EdgeInsetsDirectional.only(end: Dimensions.w16),
                child: actionWidget,
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
