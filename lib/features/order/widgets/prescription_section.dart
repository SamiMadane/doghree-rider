import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';
import 'package:doghree_rider/common/widgets/image_diaglog_widget.dart';
import 'package:doghree_rider/helper/responsive_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/theme_extension.dart';

class PrescriptionSection extends StatelessWidget {
  final List<String> attachments;
  final String? prescriptionNote;
  final VoidCallback? onImageTap;

  const PrescriptionSection({
    super.key,
    required this.attachments,
    this.prescriptionNote,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    final hasImages = attachments.isNotEmpty;
    final hasNote = prescriptionNote?.trim().isNotEmpty == true;

    if (!hasImages && !hasNote) {
      return SizedBox.shrink();
    }

    // تحديد العنوان حسب المحتوى
    String getTitle() {
      if (hasImages && hasNote) {
        return 'prescription'.tr;
      } else if (hasImages) {
        return 'prescription_image'.tr;
      } else {
        return 'prescription_note'.tr;
      }
    }

    return CustomCard(
      padding: EdgeInsets.symmetric(
          vertical: Dimensions.h16, horizontal: Dimensions.w16),
      margin: EdgeInsets.only(bottom: Dimensions.h16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            getTitle(),
            style: textSemiBold().copyWith(
              fontSize: Dimensions.fs16,
            ),
          ),
          SizedBox(height: Dimensions.h12),

          // ✅ Images Grid (لو موجود صور)
          if (hasImages) ...[
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1,
                crossAxisCount: ResponsiveHelper.isTab(context) ? 5 : 3,
                mainAxisSpacing: Dimensions.h8,
                crossAxisSpacing: Dimensions.w8,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attachments.length,
              itemBuilder: (BuildContext context, index) {
                return InkWell(
                  onTap: () => showDialog(
                    context: context,
                    builder: (ctx) => ImageDialogWidget(
                      imageUrl: attachments[index],
                    ),
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
            if (hasNote) SizedBox(height: Dimensions.h16),
          ],

          // ✅ Divider (لو صور + نص)
          if (hasImages && hasNote) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: customColor.strock2,
            ),
            SizedBox(height: Dimensions.h16),
          ],

          // ✅ Prescription Note
          if (hasNote) ...[
            // لو في صور ونص، حط CustomCard
            if (hasImages)
              CustomCard(
                padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.w16, vertical: Dimensions.h16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'prescription_note'.tr,
                      style: textMedium().copyWith(
                        height: 1.4,
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.h10,
                    ),
                    Text(
                      prescriptionNote!.trim(),
                      style: textRegular().copyWith(
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              )
            else
              // لو بس نص بدون صور، اعرض النص مباشرة بدون CustomCard جوانية
              Text(
                prescriptionNote!.trim(),
                style: textRegular().copyWith(
                  height: 1.4,
                ),
              ),
          ],
        ],
      ),
    );
  }
}