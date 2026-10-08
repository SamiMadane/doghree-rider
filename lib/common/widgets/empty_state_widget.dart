import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_image_widget.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';

class EmptyStateWidget extends StatelessWidget {
  final String image;
  final String? title;
  final String? description;
  final double? imageHeight;
  final double? imageWidth;
  final double? spacing; // المسافة الافتراضية بين العناصر
  final bool isFullScreen;
  final BoxFit imageFit;
  final double? imageWidthPercent;
  final double? imageScale;

  final String? buttonText;
  final VoidCallback? onButtonPressed;

  // 🔹 إضافات جديدة لتخصيص الحجم
  final double? titleFontSize;
  final double? descriptionFontSize;
  final double? horizontalPaddingOverride;

  const EmptyStateWidget({
    super.key,
    required this.image,
    this.title,
    this.description,
    this.imageHeight,
    this.imageWidth,
    this.spacing,
    this.isFullScreen = true,
    this.imageFit = BoxFit.contain,
    this.imageWidthPercent,
    this.imageScale,
    this.buttonText,
    this.onButtonPressed,
    this.titleFontSize,
    this.descriptionFontSize,
    this.horizontalPaddingOverride,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double finalImageWidth;
    double finalImageHeight;

    if (imageWidth != null && imageHeight != null) {
      finalImageWidth = imageWidth!;
      finalImageHeight = imageHeight!;
    } else if (imageWidthPercent != null) {
      finalImageWidth = screenWidth * imageWidthPercent!;
      finalImageHeight = finalImageWidth;
    } else {
      if (isFullScreen) {
        finalImageWidth = (screenWidth * 0.5).clamp(180.0, 300.0);
        finalImageHeight = finalImageWidth;
      } else {
        finalImageWidth = (screenWidth * 0.3).clamp(100.0, 150.0);
        finalImageHeight = finalImageWidth;
      }
    }

    final double finalSpacing =
        spacing ?? (isFullScreen ? Dimensions.h16 : Dimensions.h12);

    final double titleSize =
        titleFontSize ?? (isFullScreen ? Dimensions.fs20 : Dimensions.fs16);

    final double descriptionSize =
        descriptionFontSize ?? (isFullScreen ? Dimensions.fs15 : Dimensions.fs13);

    final double horizontalPadding =
        horizontalPaddingOverride ?? (isFullScreen ? Dimensions.w20 : Dimensions.w12);

    final bool hasTitle = title != null && title!.trim().isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: Dimensions.h20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: finalImageWidth,
              height: finalImageHeight,
              child: Transform.scale(
                scale: imageScale ?? 1.0,
                child: CustomImageWidget(
                  image: image,
                  fit: imageFit,
                ),
              ),
            ),

            if (hasTitle) ...[
              SizedBox(height: finalSpacing),
              Text(
                title!.tr,
                style: textSemiBold().copyWith(
                  fontSize: titleSize,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (description != null) ...[
              SizedBox(
                height: hasTitle ? finalSpacing * 0.75 : finalSpacing,
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isFullScreen ? screenWidth * 0.8 : screenWidth * 0.7,
                ),
                child: Text(
                  description!.tr,
                  style: textRegular().copyWith(
                    fontSize: descriptionSize,
                    color: Theme.of(context).hintColor,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            if (buttonText != null && onButtonPressed != null) ...[
              SizedBox(height: finalSpacing * 1.2),
              CustomButtonWidget(
                onPressed: onButtonPressed,
                buttonText: buttonText!.tr,
                transparent: true,
                isBorder: true,
                fontColor: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
