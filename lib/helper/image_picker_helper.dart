import 'package:doghree_rider/util/manager_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/helper/image_upload_rules.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  // Native crop screen settings (plugin units, not Flutter layout sizes).
  static const int _cropFrameStrokeWidth = 3;
  static const int _cropGridStrokeWidth = 1;
  static const int _cropGridLines = 3;
  static const double _iosMinimumAspectRatio = 0.5;

  /// Pick and crop image - Main method
  static Future<XFile?> pickAndCropImage({
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
    CropStyle cropStyle = CropStyle.rectangle,
    bool lockAspectRatio = false,
    List<CropAspectRatioPreset>? aspectRatioPresets,
    CropAspectRatio? aspectRatio, // نسبة ثابتة للقص (مثلاً الهوية). null = حر
  }) async {
    try {
      // 1. Pick image
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: ImageUploadRules.pickJpegQuality,
        maxWidth: ImageUploadRules.pickMaxDimension.toDouble(),
        maxHeight: ImageUploadRules.pickMaxDimension.toDouble(),
      );

      if (image == null) return null;

      // 2. Crop image with PREMIUM UI
      if (!context.mounted) return null;

      final croppedFile = await _cropImage(
        context: context,
        imagePath: image.path,
        cropStyle: cropStyle,
        lockAspectRatio: lockAspectRatio,
        aspectRatioPresets: aspectRatioPresets,
        aspectRatio: aspectRatio,
      );

      if (croppedFile == null) return null;

      // 3. Return XFile from cropped path
      return XFile(croppedFile.path);
    } catch (e) {
      // One message per failure (permission, no camera, other). A cancel
      // never reaches here: it returns null above (audit row 46).
      if (kDebugMode) debugPrint('pickAndCropImage failed: ${e.runtimeType}');
      showCustomSnackBar(pickFailureKey(classifyPickError(e)).tr);
      return null;
    }
  }

  /// Show bottom sheet - KEPT AS IS (NO CHANGES)
  static Future<XFile?> showImageSourceBottomSheet({
    required BuildContext context,
    CropStyle cropStyle = CropStyle.circle,
    bool lockAspectRatio = false,
    List<CropAspectRatioPreset>? aspectRatioPresets,
    CropAspectRatio? aspectRatio,
  }) async {
    final ImageSource? source = await Get.bottomSheet<ImageSource>(
      Container(
        padding: EdgeInsets.symmetric(
          vertical: Dimensions.h16,
          horizontal: Dimensions.w20,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Dimensions.r20),
          ),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الخط العلوي للـ drag
            Container(
              height: Dimensions.h4,
              width: Dimensions.w50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.r10),
                color: Theme.of(context).disabledColor,
              ),
            ),
            SizedBox(height: Dimensions.h20),

            // العنوان في الوسط
            Text(
              'upload_a_photo'.tr,
              style: textBold().copyWith(fontSize: Dimensions.fs16),
            ),

            SizedBox(height: Dimensions.h20),

            // اختيار من المعرض
            InkWell(
              onTap: () => Get.back(result: ImageSource.gallery),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.h16,
                  horizontal: Dimensions.w16,
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      ManagerAssets.galleryIcon,
                      height: Dimensions.w35,
                      width: Dimensions.w35,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: Dimensions.w16),
                    Text(
                      'from_gallery'.tr,
                      style: textMedium().copyWith(fontSize: Dimensions.fs14),
                    ),
                  ],
                ),
              ),
            ),

            // اختيار من الكاميرا
            InkWell(
              onTap: () => Get.back(result: ImageSource.camera),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.h16,
                  horizontal: Dimensions.w16,
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      ManagerAssets.cameraIcon,
                      height: Dimensions.w35,
                      width: Dimensions.w35,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onSurface,
                          BlendMode.srcIn),
                    ),
                    SizedBox(width: Dimensions.w16),
                    Text(
                      'from_camera'.tr,
                      style: textMedium().copyWith(fontSize: Dimensions.fs14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );

    if (source == null) return null;
    if (!context.mounted) return null;

    return await pickAndCropImage(
      context: context,
      source: source,
      cropStyle: cropStyle,
      lockAspectRatio: lockAspectRatio,
      aspectRatioPresets: aspectRatioPresets,
      aspectRatio: aspectRatio,
    );
  }

  // ======== PREMIUM CROP UI - تصميم احترافي من الصفر ========
  static Future<CroppedFile?> _cropImage({
    required BuildContext context,
    required String imagePath,
    CropStyle cropStyle = CropStyle.rectangle,
    bool lockAspectRatio = false,
    List<CropAspectRatioPreset>? aspectRatioPresets,
    CropAspectRatio? aspectRatio, 
  }) async {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF0D0D0D) 
        : const Color(0xFFF8F8F8); 

    final toolbarColor = isDark
        ? const Color(0xFF1C1C1C) 
        : const Color(0xFFFFFFFF);

    final gridColor = primaryColor;
    final frameColor = primaryColor;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: aspectRatio, 
      compressQuality: ImageUploadRules.pickJpegQuality,
      compressFormat: ImageCompressFormat.jpg,
      maxWidth: ImageUploadRules.pickMaxDimension,
      maxHeight: ImageUploadRules.pickMaxDimension,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'crop_image'.tr,
          toolbarColor: toolbarColor,
          toolbarWidgetColor: isDark ? Colors.white : const Color(0xFF1A1A1A),

          statusBarLight: !isDark,
          backgroundColor: backgroundColor,

          activeControlsWidgetColor:
              isDark ? primaryColor : ManagerColors.onPrimary,
      
          dimmedLayerColor: isDark
              ? Colors.black.withValues(alpha: 0.40)
              : Colors.black.withValues(alpha: 0.40), 

  
          cropFrameColor: frameColor,
          cropFrameStrokeWidth: _cropFrameStrokeWidth,

          cropGridColor: gridColor.withValues(alpha: 0.30),
          cropGridStrokeWidth: _cropGridStrokeWidth,

          cropGridRowCount: _cropGridLines,
          cropGridColumnCount: _cropGridLines,
          showCropGrid: true,

          hideBottomControls: false,

          cropStyle: cropStyle,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: lockAspectRatio,

          aspectRatioPresets: aspectRatioPresets ??
              [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2, 
                CropAspectRatioPreset.ratio5x3, 
                CropAspectRatioPreset.ratio16x9, 
                CropAspectRatioPreset.ratio5x4,
              ],
        ),
        IOSUiSettings(
          title: 'crop_image'.tr,
          doneButtonTitle: 'done'.tr,
          cancelButtonTitle: 'cancel'.tr,

          minimumAspectRatio: _iosMinimumAspectRatio,
          rectX: 0.0,
          rectY: 0.0,
          rectWidth: 1.0,
          rectHeight: 1.0,

          cropStyle: cropStyle,
          aspectRatioLockEnabled: lockAspectRatio,

          // ===== FEATURES =====
          resetAspectRatioEnabled: true,
          rotateButtonsHidden: false,
          rotateClockwiseButtonHidden: false,
          hidesNavigationBar: false,

          aspectRatioPresets: aspectRatioPresets ??
              [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio16x9,
                CropAspectRatioPreset.ratio5x4,
              ],
        ),
      ],
    );

    return croppedFile;
  }
}
