import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

/// Asked after the server refused a delivery request because its photos were
/// too large (D-09, B-02). Answers true (deliver without photos) or false.
/// The first tap answers; any later tap does nothing, so the route below the
/// dialog is never popped by a double tap.
class DeliverWithoutPhotosDialog extends StatefulWidget {
  const DeliverWithoutPhotosDialog({super.key});

  @override
  State<DeliverWithoutPhotosDialog> createState() =>
      _DeliverWithoutPhotosDialogState();
}

class _DeliverWithoutPhotosDialogState
    extends State<DeliverWithoutPhotosDialog> {
  bool _answered = false;

  void _answer(bool value) {
    if (_answered) return;
    _answered = true;
    Get.back(result: value);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.r12)),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.w20, vertical: Dimensions.h20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.no_photography_outlined,
                size: Dimensions.w60, color: scheme.error),
            SizedBox(height: Dimensions.h16),
            Text(
              'photos_upload_failed_deliver_without'.tr,
              textAlign: TextAlign.center,
              style: textMedium().copyWith(fontSize: Dimensions.fs16),
            ),
            SizedBox(height: Dimensions.h20),
            Row(children: [
              Expanded(
                child: CustomButtonWidget(
                  key: const ValueKey('deliver_without_photos_no'),
                  buttonText: 'no'.tr,
                  transparent: true,
                  isBorder: true,
                  height: Dimensions.h40,
                  onPressed: () => _answer(false),
                ),
              ),
              SizedBox(width: Dimensions.w10),
              Expanded(
                child: CustomButtonWidget(
                  key: const ValueKey('deliver_without_photos_yes'),
                  buttonText: 'deliver_without_photos'.tr,
                  height: Dimensions.h40,
                  onPressed: () => _answer(true),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
