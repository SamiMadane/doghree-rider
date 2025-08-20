import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/features/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
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
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Text(
            title,
            style: robotoSemiBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // صورة واسم وعنوان رئيسي
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: CustomImageWidget(
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  image: image.isNotEmpty ? image : '',
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name != null && name!.isNotEmpty)
                      Text(
                        name!,
                        style: robotoSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    if (address != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // العنوان الرئيسي
                          Text(
                            address!.address ?? '',
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall),

                          // التفاصيل الأخرى
                          Wrap(
                            children: [
                              if (address!.streetNumber != null &&
                                  address!.streetNumber!.isNotEmpty)
                                Text(
                                  '${'street_number'.tr}: ${address!.streetNumber!}, ',
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              if (address!.house != null &&
                                  address!.house!.isNotEmpty)
                                Text(
                                  '${'house'.tr}: ${address!.house!}, ',
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              if (address!.floor != null &&
                                  address!.floor!.isNotEmpty)
                                Text(
                                  '${'floor'.tr}: ${address!.floor!}',
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
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
          if (showButton) const SizedBox(height: Dimensions.paddingSizeDefault),

          // أزرار Call, Chat, Direction
          if (showButton)
            Row(
              children: [
                if (phone != null && phone!.isNotEmpty)
                  TextButton.icon(
                    onPressed: () async {
                      if (await canLaunchUrlString('tel:$phone')) {
                        await launchUrlString('tel:$phone',
                            mode: LaunchMode.externalApplication);
                      } else {
                        showCustomSnackBar('invalid_phone_number_found'.tr);
                      }
                    },
                    icon: Icon(Icons.call,
                        color: Theme.of(context).primaryColor, size: 20),
                    label: Text('call'.tr,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).primaryColor)),
                  ),
                if (isStore && isChatAllow && !order.isGuest!)
                  TextButton.icon(
                    onPressed: messageOnTap as void Function()?,
                    icon: Icon(Icons.message,
                        color: Theme.of(context).primaryColor, size: 20),
                    label: Text('chat'.tr,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).primaryColor)),
                  ),
                TextButton.icon(
                  onPressed: () async {
                    String url =
                        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&mode=d';
                    if (await canLaunchUrlString(url)) {
                      await launchUrlString(url,
                          mode: LaunchMode.externalApplication);
                    } else {
                      showCustomSnackBar('${'could_not_launch'.tr} $url');
                    }
                  },
                  icon: Icon(Icons.directions,
                      color: Theme.of(context).disabledColor, size: 20),
                  label: Text('direction'.tr,
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor)),
                ),
              ],
            ),
          if (!showButton)
            const SizedBox(height: Dimensions.paddingSizeDefault),

          // رسالة عند عدم وجود بيانات
          if ((name == null || name!.isEmpty) && (address == null))
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeSmall),
                child: Text('no_store_data_found'.tr,
                    style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall)),
              ),
            ),
        ],
      ),
    );
  }
}
