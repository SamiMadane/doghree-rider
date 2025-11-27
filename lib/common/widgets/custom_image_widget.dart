import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/manager_colors.dart';


class CustomImageWidget extends StatelessWidget {
  final String? image;
  final double? height;
  final double? width;
  final BoxFit fit;
  final bool isNotification;
  final String? placeholder;

  const CustomImageWidget({
    super.key,
    this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.isNotification = false,
    this.placeholder,
  });

  // دالة للتحقق إذا كانت الصورة أصل محلي أو URL
  bool _isAssetImage(String? path) {
    if (path == null || path.isEmpty) return false;
    return !path.startsWith('http://') && 
           !path.startsWith('https://') &&
           !path.startsWith('www.');
  }

  @override
  Widget build(BuildContext context) {
    final String placeholderToUse = placeholder ??
        (isNotification
            ? ManagerAssets.notificationPlaceholder
            : ManagerAssets.placeholder);

    // إذا كانت الصورة فارغة
    if (image == null || image!.isEmpty) {
      return Image.asset(
        placeholderToUse,
        height: height,
        width: width,
        fit: fit,
      );
    }

    // إذا كانت الصورة أصل محلي
    if (_isAssetImage(image)) {
      return Image.asset(
        image!,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          placeholderToUse,
          height: height,
          width: width,
          fit: fit,
        ),
      );
    }

    // إذا كانت الصورة URL
    return CachedNetworkImage(
      imageUrl: image!,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) => Shimmer(
        duration: const Duration(seconds: 2),
        color: Theme.of(context).cardColor,
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
        placeholderToUse,
        height: height,
        width: width,
        fit: fit,
      ),
    );
  }
}