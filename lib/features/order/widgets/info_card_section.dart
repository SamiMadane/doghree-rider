import 'package:flutter_svg/svg.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class InfoCardSection extends StatelessWidget {
  final String title;
  final String image;
  final String? name;
  final DeliveryAddress? address;
  final String? phone;
  final String? latitude;
  final String? longitude;
  final bool showButton;
  final bool isStore;
  final Function? messageOnTap;
  final OrderModel order;
  final bool isChatAllow;

  const InfoCardSection({
    super.key,
    required this.title,
    required this.image,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.showButton,
    this.messageOnTap,
    this.isStore = false,
    required this.order,
    required this.isChatAllow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final Color? ink = theme.textTheme.bodyMedium?.color;

    TextStyle detail() => textMedium().copyWith(
          fontSize: Dimensions.fs11,
          color: muted,
        );

    return CustomCard(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w16,
        vertical: Dimensions.h16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textSemiBold().copyWith(fontSize: Dimensions.fs16),
          ),
          SizedBox(height: Dimensions.h16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: CustomImageWidget(
                  width: Dimensions.w50,
                  height: Dimensions.w50,
                  fit: BoxFit.cover,
                  image: image,
                ),
              ),
              SizedBox(width: Dimensions.w16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name != null && name!.isNotEmpty)
                      Text(
                        name!,
                        style: textSemiBold().copyWith(
                          fontSize: Dimensions.fs14,
                        ),
                      ),
                    SizedBox(height: Dimensions.h4),
                    if (address != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (address!.address != null &&
                              address!.address!.isNotEmpty)
                            Text(
                              address!.address!,
                              style: textMedium().copyWith(
                                fontSize: Dimensions.fs12,
                                color: muted,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          SizedBox(height: Dimensions.h4),
                          Wrap(
                            children: [
                              if (address!.streetNumber != null &&
                                  address!.streetNumber!.isNotEmpty)
                                Text(
                                  '${'street_number'.tr}: ${address!.streetNumber!}, ',
                                  style: detail(),
                                ),
                              if (address!.house != null &&
                                  address!.house!.isNotEmpty)
                                Text(
                                  '${'house'.tr}: ${address!.house!}, ',
                                  style: detail(),
                                ),
                              if (address!.floor != null &&
                                  address!.floor!.isNotEmpty)
                                Text(
                                  '${'floor'.tr}: ${address!.floor!}',
                                  style: detail(),
                                ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: Dimensions.h16),

          if (showButton)
            Row(
              children: [
                if (phone != null && phone!.isNotEmpty)
                  Expanded(
                    child: CustomButtonWidget(
                      onPressed: () async {
                        if (await canLaunchUrlString('tel:$phone')) {
                          await launchUrlString('tel:$phone',
                              mode: LaunchMode.externalApplication);
                        } else {
                          showCustomSnackBar('invalid_phone_number_found'.tr);
                        }
                      },
                      buttonText: 'call'.tr,
                      fontColor: ink,
                      transparent: true,
                      isBorder: true,
                      borderColor: ink,
                      height: Dimensions.h45,
                      icon: SvgPicture.asset(
                        ManagerAssets.callIcon,
                        height: Dimensions.h22,
                        width: Dimensions.w22,
                        colorFilter: ColorFilter.mode(
                          ink ?? ManagerColors.onPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                SizedBox(width: Dimensions.w16),
                if (isStore && isChatAllow && !order.isGuest!)
                  Expanded(
                    child: CustomButtonWidget(
                      onPressed: messageOnTap as void Function()?,
                      buttonText: 'chat'.tr,
                      height: Dimensions.h45,
                      icon: SvgPicture.asset(
                        ManagerAssets.messageIcon,
                        height: Dimensions.h22,
                        width: Dimensions.w22,
                        colorFilter: const ColorFilter.mode(
                          ManagerColors.onPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

          if ((name == null || name!.isEmpty) && (address == null))
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: Dimensions.h10),
                child: Text(
                  'no_store_data_found'.tr,
                  style: textRegular().copyWith(fontSize: Dimensions.fs12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}