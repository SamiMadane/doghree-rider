import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doghree_rider/helper/upload_format.dart';

/// Result of checking a picked image before it is kept for upload.
enum ImageCheck { ok, tooLarge, unsupported, unreadable }

/// The one place for image upload limits (audit rows 46, 49).
class ImageUploadRules {
  ImageUploadRules._();

  /// 2 MB per image. The server limits are not documented (B-04 questions),
  /// so this stays the registration value until the owner confirms them.
  static const int maxImageBytes = 2 * 1024 * 1024;

  /// Never throws. A missing, empty or unreadable file is [ImageCheck.unreadable].
  static Future<ImageCheck> check(XFile file,
      {int maxBytes = maxImageBytes}) async {
    try {
      final int length = await file.length();
      if (length <= 0) return ImageCheck.unreadable;
      final List<int> head = <int>[];
      await for (final List<int> chunk
          in file.openRead(0, UploadFormats.headLength)) {
        head.addAll(chunk);
      }
      if (!UploadFormats.isUploadableImage(UploadFormats.sniff(head))) {
        return ImageCheck.unsupported;
      }
      if (length > maxBytes) return ImageCheck.tooLarge;
      return ImageCheck.ok;
    } catch (_) {
      return ImageCheck.unreadable;
    }
  }

  /// Translation key for a refused check.
  static String messageKey(ImageCheck c) {
    switch (c) {
      case ImageCheck.tooLarge:
        return 'please_upload_lower_size_file';
      case ImageCheck.unsupported:
        return 'photo_format_not_supported';
      case ImageCheck.ok:
      case ImageCheck.unreadable:
        return 'image_pick_failed';
    }
  }
}

/// Why picking an image failed. A cancel is not a failure (null result).
enum PickFailure { cameraDenied, galleryDenied, noCamera, failed }

/// Decided from the plugin error code only, never from its text.
PickFailure classifyPickError(Object error) {
  if (error is PlatformException) {
    switch (error.code) {
      case 'camera_access_denied':
        return PickFailure.cameraDenied;
      case 'photo_access_denied':
        return PickFailure.galleryDenied;
      case 'no_available_camera':
        return PickFailure.noCamera;
    }
  }
  return PickFailure.failed;
}

String pickFailureKey(PickFailure f) {
  switch (f) {
    case PickFailure.cameraDenied:
      return 'camera_permission_denied';
    case PickFailure.galleryDenied:
      return 'gallery_permission_denied';
    case PickFailure.noCamera:
      return 'no_camera_available';
    case PickFailure.failed:
      return 'image_pick_failed';
  }
}
