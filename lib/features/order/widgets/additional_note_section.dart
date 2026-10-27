import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';


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
      padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
      margin: EdgeInsets.only(bottom: Dimensions.h16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'additional_note'.tr,
            style: textSemiBold().copyWith(
              fontSize: Dimensions.fs16,
            ),
          ),
          SizedBox(height: Dimensions.h8),

          // Note Content
          Text(
            note,
            style: textRegular().copyWith(
              fontSize: Dimensions.fs13,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
