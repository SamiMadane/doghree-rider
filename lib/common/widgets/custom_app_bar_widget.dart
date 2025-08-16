import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final Widget? actionWidget;
  final double? elevation;
  final Widget? leadingWidget;
  final bool? centerTitle;

  const CustomAppBarWidget({
    super.key,
    this.title,
    this.isBackButtonExist = true,
    this.onBackPressed,
    this.actionWidget,
    this.elevation,
    this.leadingWidget,
    this.centerTitle = true,

  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color),
            )
          : null,
      centerTitle: centerTitle,
      leadingWidth: leadingWidget != null ? 55 : null,
      leading: Container(
        padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        child: leadingWidget ??
            (isBackButtonExist
                ? IconButton(
                    icon: SvgPicture.asset(
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
      ),
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
