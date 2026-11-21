import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

/// The bottom row of a paged list (My Orders, audit row 26; withdrawal
/// requests, audit row 42): a spinner while the next page loads, or a
/// message with Retry when that page failed.
class HistoryPageFooterWidget extends StatelessWidget {
  final bool isLoading;
  final bool failed;
  final VoidCallback onRetry;

  /// Text of the failed state. Defaults to `load_more_failed` (orders).
  final String? failedText;

  const HistoryPageFooterWidget({
    super.key,
    required this.isLoading,
    required this.failed,
    required this.onRetry,
    this.failedText,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    if (failed && !isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: Dimensions.h16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              failedText ?? 'load_more_failed'.tr,
              textAlign: TextAlign.center,
              style: textRegular()
                  .copyWith(fontSize: Dimensions.fs14, color: scheme.onSurface),
            ),
            SizedBox(height: Dimensions.h8),
            TextButton(onPressed: onRetry, child: Text('retry'.tr)),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.h16),
      child: Center(child: CircularProgressIndicator(color: scheme.onSurface)),
    );
  }
}
