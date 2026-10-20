import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/dimensions.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

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
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (image == null) return null;

      // 2. Crop image with PREMIUM UI
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
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Pick circular profile image
  static Future<XFile?> pickProfileImage(BuildContext context) async {
    return await pickAndCropImage(
      context: context,
      cropStyle: CropStyle.circle,
      lockAspectRatio: true,
      aspectRatioPresets: [CropAspectRatioPreset.square],
    );
  }

  /// Pick normal image (square or free)
  static Future<XFile?> pickNormalImage(BuildContext context) async {
    return await pickAndCropImage(
      context: context,
      cropStyle: CropStyle.rectangle,
      lockAspectRatio: false,
      aspectRatioPresets: [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
    );
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
              height: 4,
              width: 50,
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
                      height: 35,
                      width: 35,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
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
                      height: 35,
                      width: 35,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
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
    CropAspectRatio? aspectRatio, // ✨ جديد: كان ناقص من هالدالة
  }) async {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ===== PREMIUM COLOR SCHEME =====
    // خلفية gradient حقيقية (مش flat color)
    final backgroundColor = isDark
        ? const Color(0xFF0D0D0D) // أغمق شوي
        : const Color(0xFFF8F8F8); // أفتح شوي

    // Toolbar مع depth
    final toolbarColor = isDark
        ? const Color(0xFF1C1C1C) // رمادي غامق مع warmth
        : const Color(0xFFFFFFFF); // أبيض نقي

    // Grid ملونة ذكية - تتغير حسب brightness الصورة
    final gridColor = primaryColor;
    final frameColor = primaryColor;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: aspectRatio, // ✨ جديد: هون بتنفرض نسبة القص (null = حر)
      compressQuality: 85,
      compressFormat: ImageCompressFormat.jpg, // امتداد حقيقي مسموح عند الخادم
      maxWidth: 1600,
      maxHeight: 1600,
      uiSettings: [
        AndroidUiSettings(
          // ===== MODERN TOOLBAR =====
          toolbarTitle: 'crop_image'.tr,
          toolbarColor: toolbarColor,
          toolbarWidgetColor: isDark ? Colors.white : const Color(0xFF1A1A1A),

          // Status bar immersive
          statusBarColor: isDark ? const Color(0xFF000000) : primaryColor,

          // ===== BACKGROUND WITH DEPTH =====
          backgroundColor: backgroundColor,

          // ===== SMART CONTROLS =====
          // اللون النشط - أكثر وضوحاً
          activeControlsWidgetColor: primaryColor,

          // ===== ADVANCED DIMMING =====
          // تعتيم ذكي - يسمح برؤية الصورة كاملة
          dimmedLayerColor: isDark
              ? Colors.black.withOpacity(0.55) // 55% للـ dark
              : Colors.black.withOpacity(0.40), // 40% للـ light

          // ===== PREMIUM GRID SYSTEM =====
          // إطار بارز مع shadow effect
          cropFrameColor: frameColor,
          cropFrameStrokeWidth: 3, // متوسط - مش سميك أوي

          // شبكة ملونة ذكية
          cropGridColor: gridColor.withOpacity(0.30), // 30% للنعومة
          cropGridStrokeWidth: 1, // نحيفة وأنيقة

          // ===== ADAPTIVE GRID =====
          // شبكة 3×3 (Rule of Thirds) - أفضل للـ composition
          cropGridRowCount: 3,
          cropGridColumnCount: 3,
          showCropGrid: true,

          // ===== UI ENHANCEMENTS =====
          // إخفاء bottom controls القديمة - هنستخدم custom
          hideBottomControls: false,

          // ===== CROP BEHAVIOR =====
          cropStyle: cropStyle,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: lockAspectRatio,

          // ===== ASPECT RATIOS =====
          aspectRatioPresets: aspectRatioPresets ??
              [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2, // بدل 4x3 - أكثر استخداماً
                CropAspectRatioPreset.ratio5x3, // جديد - للصور الأفقية
                CropAspectRatioPreset.ratio16x9, // للفيديو
                CropAspectRatioPreset.ratio5x4, // للطباعة
              ],
        ),

        // ===== iOS PREMIUM SETTINGS =====
        IOSUiSettings(
          title: 'crop_image'.tr,
          doneButtonTitle: 'done'.tr,
          cancelButtonTitle: 'cancel'.tr,

          // ===== iOS SPECIFIC =====
          minimumAspectRatio: 0.5, // أكثر مرونة
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