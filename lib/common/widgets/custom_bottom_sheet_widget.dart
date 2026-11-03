import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/util/dimensions.dart';

Future<T?> showCustomBottomSheet<T>({
  required Widget child,
  double? maxHeight,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: Get.context!,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(Get.context!).cardColor,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    constraints: BoxConstraints(
      maxHeight:
          maxHeight ?? MediaQuery.of(Get.context!).size.height * 0.85,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(Dimensions.r24),
      ),
    ),
    builder: (BuildContext context) => SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Handle(),
          Flexible(child: child),
        ],
      ),
    ),
  );
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Dimensions.h10, bottom: Dimensions.h12),
      child: Container(
        width: Dimensions.w40,
        height: Dimensions.h4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outline,
          borderRadius: BorderRadius.circular(Dimensions.r50),
        ),
      ),
    );
  }
}