import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_image_widget.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';

class EmptyStateWidget extends StatelessWidget {
  final String image;
  final String title;
  final String? description;
  final double? imageHeight;
  final double? imageWidth;
  final double? spacing;
  final bool isFullScreen;

  const EmptyStateWidget({
    super.key,
    required this.image,
    required this.title,
    this.description,
    this.imageHeight,
    this.imageWidth,
    this.spacing,
    this.isFullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد المقاسات حسب نوع العرض
    final double finalImageHeight = imageHeight ?? (isFullScreen ? 200 : 120);
    final double finalImageWidth = imageWidth ?? (isFullScreen ? 200 : 120);
    final double finalSpacing =
        spacing ?? (isFullScreen ? Dimensions.p16 : Dimensions.p8);
    final double titleSize = isFullScreen ? Dimensions.fs20 : Dimensions.fs16;
    final double descriptionSize =
        isFullScreen ? Dimensions.fs18 : Dimensions.fs14;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.p20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomImageWidget(
              image: image,
              height: finalImageHeight,
              width: finalImageWidth,
            ),
            SizedBox(height: finalSpacing),
            Text(
              title.tr,
              style: robotoSemiBold.copyWith(
                fontSize: titleSize,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              SizedBox(height: finalSpacing),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isFullScreen ? Dimensions.p24 : Dimensions.p12,
                ),
                child: Text(
                  description!.tr,
                  style: robotoRegular.copyWith(
                    fontSize: descriptionSize,
                    color: Theme.of(context).hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
