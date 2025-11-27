import 'package:flutter_svg/svg.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/features/order/domain/models/order_model.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/common/widgets/custom_image_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_snackbar_widget.dart';
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
    return CustomCard(
      padding: const EdgeInsets.all(Dimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Text(
            title,
            style: robotoSemiBold.copyWith(
              fontSize: Dimensions.fs16,
            ),
          ),
          const SizedBox(height: Dimensions.p16),

          // صورة واسم وعنوان رئيسي
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: CustomImageWidget(
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  image: image.isNotEmpty ? image : ManagerAssets.storeImage,
                ),
              ),
              const SizedBox(width: Dimensions.p16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name != null && name!.isNotEmpty)
                      Text(
                        name!,
                        style: robotoSemiBold.copyWith(
                          fontSize: Dimensions.fs14,
                        ),
                      ),
                    const SizedBox(height: Dimensions.p4),
                    if (address != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // العنوان الرئيسي
                          if (address!.address != null &&
                              address!.address!.isNotEmpty)
                            Text(
                              address!.address!,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fs12,
                                color: Theme.of(context).disabledColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: Dimensions.p4),

                          // التفاصيل الأخرى
                          Wrap(
                            children: [
                              if (address!.streetNumber != null &&
                                  address!.streetNumber!.isNotEmpty)
                                Text(
                                  '${'street_number'.tr}: ${address!.streetNumber!}, ',
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fs10,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              if (address!.house != null &&
                                  address!.house!.isNotEmpty)
                                Text(
                                  '${'house'.tr}: ${address!.house!}, ',
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fs10,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              if (address!.floor != null &&
                                  address!.floor!.isNotEmpty)
                                Text(
                                  '${'floor'.tr}: ${address!.floor!}',
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fs10,
                                    color: Theme.of(context).disabledColor,
                                  ),
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
          if (showButton) const SizedBox(height: Dimensions.p16),

          // أزرار Call, Chat, Direction
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
                      fontColor: Theme.of(context).textTheme.bodyMedium!.color,
                      transparent: true,
                      isBorder: true,
                      borderColor:
                          Theme.of(context).textTheme.bodyMedium!.color,
                      height: 45,
                      icon: SvgPicture.asset(
                        ManagerAssets.callIcon,
                        height: 22,
                        width: 22,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                SizedBox(
                  width: Dimensions.p16,
                ),
                if (isStore && isChatAllow && !order.isGuest!)
                  Expanded(
                    child: CustomButtonWidget(
                      onPressed: messageOnTap as void Function()?,
                      buttonText: 'chat'.tr,
                      height: 45,
                      icon: SvgPicture.asset(
                        ManagerAssets.messageIcon,
                        height: 22,
                        width: 22,
                        color: ManagerColors.white,
                      ),
                    ),
                  ),
              ],
            ),
          if (!showButton) const SizedBox(height: Dimensions.p16),

          // رسالة عند عدم وجود بيانات
          if ((name == null || name!.isEmpty) && (address == null))
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.p10),
                child: Text('no_store_data_found'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fs12)),
              ),
            ),
        ],
      ),
    );
  }
}
