import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';

class CustomImageWidget extends StatelessWidget {
  final String? image;
  final double? height;
  final double? width;
  final BoxFit fit;
  final bool isNotification;

  const CustomImageWidget({
    super.key,
    this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.isNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    // إذا الصورة null أو فارغة، عرض placeholder ثابت أو أيقونة
    if (image == null || image!.isEmpty) {
      return Image.asset(
        isNotification
            ? ManagerAssets.notificationPlaceholder
            : ManagerAssets.placeholder,
        height: height,
        width: width,
        fit: fit,
      );
    }

    return CachedNetworkImage(
      imageUrl: image!,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) => Shimmer(
        duration: const Duration(seconds: 2),
        color: Theme.of(context).cardColor ,
        colorOpacity: 0.3,
        enabled: true,
        direction: const ShimmerDirection.fromLTRB(),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: ManagerColors.shimmer,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Image.asset(
        isNotification
            ? ManagerAssets.notificationPlaceholder
            : ManagerAssets.placeholder,
        height: height,
        width: width,
        fit: fit,
      ),
    );
  }
}
