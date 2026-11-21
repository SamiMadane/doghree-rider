import 'package:doghree_rider/common/models/load_failure.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The compact failure state for a screen whose first load failed (D-13).
/// It sits inside the screen (the app bar stays) and retries in place.
///
/// One tap sends one request: taps while a retry runs are ignored, and the
/// button is usable again when it ends. No toast and no connectivity check,
/// so this state is the only message the rider sees.
class LoadFailedWidget extends StatefulWidget {
  final LoadFailure failure;
  final Future<void> Function() onRetry;

  const LoadFailedWidget(
      {super.key, required this.failure, required this.onRetry});

  @override
  State<LoadFailedWidget> createState() => _LoadFailedWidgetState();
}

class _LoadFailedWidgetState extends State<LoadFailedWidget> {
  bool _busy = false;

  Future<void> _retry() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onRetry();
    } catch (_) {
      // The screen's controller owns the result; nothing to show here.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool noInternet = widget.failure == LoadFailure.noInternet;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.w20, vertical: Dimensions.h20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              noInternet ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
              size: Dimensions.w60,
              color: theme.hintColor,
            ),
            SizedBox(height: Dimensions.h16),
            Text(
              (noInternet ? 'no_connection' : 'server_problem').tr,
              textAlign: TextAlign.center,
              style: textBold().copyWith(
                fontSize: Dimensions.fs18,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: Dimensions.h8),
            Text(
              (noInternet
                      ? 'please_check_your_internet_and_try_again'
                      : 'server_problem_try_again')
                  .tr,
              textAlign: TextAlign.center,
              style: textRegular().copyWith(
                fontSize: Dimensions.fs14,
                color: theme.hintColor,
              ),
            ),
            SizedBox(height: Dimensions.h20),
            CustomButtonWidget(
              buttonText: 'retry'.tr,
              isLoading: _busy,
              onPressed: _retry,
            ),
          ],
        ),
      ),
    );
  }
}
