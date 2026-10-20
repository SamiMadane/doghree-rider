import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';
import 'package:doghree_rider/common/widgets/image_diaglog_widget.dart';
import 'package:doghree_rider/helper/responsive_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class OrderProofSection extends StatelessWidget {
  final List<String> proofImages;
  final String orderStatus;

  const OrderProofSection({
    super.key,
    required this.proofImages,
    required this.orderStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (orderStatus.toLowerCase() != 'delivered' || proofImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
      margin: EdgeInsets.only(bottom: Dimensions.h16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'order_proof'.tr,
                style: textSemiBold().copyWith(
                  fontSize: Dimensions.fs16,
                ),
              ),
              SizedBox(width: Dimensions.w8),
              Icon(
                Icons.verified,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: Dimensions.h12),

          // Images Grid
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.5,
              crossAxisCount: ResponsiveHelper.isTab(context) ? 5 : 3,
              mainAxisSpacing: Dimensions.h8,
              crossAxisSpacing: Dimensions.w8,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: proofImages.length,
            itemBuilder: (BuildContext context, index) {
              return InkWell(
                onTap: () => showDialog(
                  context: context,
                  builder: (ctx) =>
                      ImageDialogWidget(imageUrl: proofImages[index]),
                ),
                borderRadius: BorderRadius.circular(Dimensions.r8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.r8),
                  child: CustomImageWidget(
                    image: proofImages[index],
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
