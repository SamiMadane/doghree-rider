import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wefrh_rider/common/widgets/custom_image_widget.dart';
import 'package:wefrh_rider/util/dimensions.dart';

class ImageDialogWidget extends StatelessWidget {
  final String imageUrl;
  const ImageDialogWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Blur background
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(color: Colors.black.withOpacity(0)),
              ),
            ),

            // Image container
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.r12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.r12),
                child: CustomImageWidget(
                  image: imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(200),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.clear,
                          color: Colors.black,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }
}
