import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/common/widgets/custom_image_widget.dart';
import 'package:wefrh_rider/common/widgets/image_diaglog_widget.dart';
import 'package:wefrh_rider/helper/responsive_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';

class PrescriptionSection extends StatelessWidget {
  final List<String> attachments;
  final VoidCallback? onImageTap;

  const PrescriptionSection({
    super.key,
    required this.attachments,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return CustomCard(
      padding: const EdgeInsets.all(Dimensions.p16),
      margin: const EdgeInsets.only(bottom: Dimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'prescription'.tr,
            style: robotoSemiBold.copyWith(
              fontSize: Dimensions.fs16,
            ),
          ),
          const SizedBox(height: Dimensions.p12),

          // Images Grid
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1,
              crossAxisCount: ResponsiveHelper.isTab(context) ? 5 : 3,
              mainAxisSpacing: Dimensions.p8,
              crossAxisSpacing: Dimensions.p8,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attachments.length,
            itemBuilder: (BuildContext context, index) {
              return InkWell(
                onTap: () => showDialog(
                  context: context,
                  builder: (ctx) =>
                      ImageDialogWidget(imageUrl: attachments[index]),
                ),
                borderRadius: BorderRadius.circular(Dimensions.r8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.r8),
                  child: CustomImageWidget(
                    image: attachments[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
