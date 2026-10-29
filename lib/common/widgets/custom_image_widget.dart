import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:doghree_rider/common/widgets/app_shimmer.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';

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

  Widget _placeholderImage(String path) =>
      Image.asset(path, height: height, width: width, fit: fit);

  @override
  Widget build(BuildContext context) {
    final String placeholderToUse = placeholder ??
        (isNotification
            ? ManagerAssets.notificationPlaceholder
            : ManagerAssets.placeholder);

    // إذا كانت الصورة فارغة
    if (image == null || image!.isEmpty) {
      return _placeholderImage(placeholderToUse);
    }

    // إذا كانت الصورة أصل محلي
    if (_isAssetImage(image)) {
      return Image.asset(
        image!,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            _placeholderImage(placeholderToUse),
      );
    }

    // إذا كانت الصورة URL
    return CachedNetworkImage(
      imageUrl: image!,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) => AppShimmerBlock(
        width: width,
        height: height,
        radius: Dimensions.r8,
      ),
      errorWidget: (context, url, error) => _placeholderImage(placeholderToUse),
    );
  }
}