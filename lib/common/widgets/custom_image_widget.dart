import 'package:cached_network_image/cached_network_image.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:flutter/cupertino.dart';

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit fit;
  final bool isNotification;
  const CustomImageWidget({super.key, required this.image, this.height, this.width, this.fit = BoxFit.cover, this.isNotification = false});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image, height: height, width: width, fit: fit,
      placeholder: (context, url) => Image.asset(isNotification ? ManagerAssets.notificationPlaceholder : ManagerAssets.placeholder, height: height, width: width, fit: fit),
      errorWidget: (context, url, error) => Image.asset(isNotification ? ManagerAssets.notificationPlaceholder : ManagerAssets.placeholder, height: height, width: width, fit: fit),
    );
  }
}
