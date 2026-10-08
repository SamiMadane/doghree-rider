import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/styles.dart';


class DottedBorderWidget extends StatelessWidget {
  final Function() onTap;
  final String? text;
  final bool showErrorBorder;
  const DottedBorderWidget(
      {super.key,
      required this.onTap,
      this.showErrorBorder = false,
      this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: const [8, 4],
          strokeWidth: 1,
          color: showErrorBorder
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).dividerTheme.color!,
          radius:  Radius.circular(Dimensions.r20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                ManagerAssets.uploadIcon,
                color: showErrorBorder
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).disabledColor,
                height: 24,
                width: 24,
              ),
               SizedBox(
                height: Dimensions.h10,
              ),
              Text(
                text ?? "upload_file".tr,
                textAlign: TextAlign.center,
                style: textMedium().copyWith(
                  fontSize: 12,
                  color: showErrorBorder
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
