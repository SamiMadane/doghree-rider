import 'package:doghree_rider/util/manager_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

/// Shown when the first page of earnings could not be loaded.
/// Retries in place, so the screen keeps its app bar and applied filter.
class EarningErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const EarningErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.w20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomImageWidget(
              image: ManagerAssets.earningErrorImage,
              height: Dimensions.h95 * 2,
              fit: BoxFit.contain,
            ),

            SizedBox(height: Dimensions.h20),

            Text(
              'earning_load_failed'.tr,
              textAlign: TextAlign.center,
              style: textBold().copyWith(
                fontSize: Dimensions.fs18,
                color: cs.onSurface,
              ),
            ),

            SizedBox(height: Dimensions.h8),

            Text(
              'earning_load_failed_desc'.tr,
              textAlign: TextAlign.center,
              style: textRegular().copyWith(
                fontSize: Dimensions.fs14,
                color: theme.hintColor,
              ),
            ),

            SizedBox(height: Dimensions.h20),

            CustomButtonWidget(
              buttonText: 'retry'.tr,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}