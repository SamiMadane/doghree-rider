import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';

class ImageDialogWidget extends StatelessWidget {
  final String imageUrl;
  const ImageDialogWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          /// صورة محددة الحجم
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomImageWidget(
                image: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),

          /// زر الإغلاق (X)
          Positioned(
            top: 8,
            left: 8,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(200),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.clear, color: Colors.black, size: 12),
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
