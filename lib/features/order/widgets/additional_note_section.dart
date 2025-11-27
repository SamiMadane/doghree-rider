import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';


class AdditionalNoteSection extends StatelessWidget {
  final String note;

  const AdditionalNoteSection({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    if (note.isEmpty) return const SizedBox.shrink();

    return CustomCard(
      padding: const EdgeInsets.all(Dimensions.p16),
      margin: const EdgeInsets.only(bottom: Dimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'additional_note'.tr,
            style: robotoSemiBold.copyWith(
              fontSize: Dimensions.fs16,
            ),
          ),
          const SizedBox(height: Dimensions.p8),

          // Note Content
          Text(
            note,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fs13,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
