import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/profile/widgets/profile_card_widget.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';

class UserProfileInfoCard extends StatelessWidget {
  final ProfileController profileController;

  const UserProfileInfoCard({super.key, required this.profileController});
  @override
  Widget build(BuildContext context) {
    final profile = profileController.profileModel;
    return Column(
      children: [
        // الكارد الرئيسي (صورة، اسم، رقم، زر تعديل)
        CustomCard(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          isBorder: false,
          child: Row(
            children: [
              /// صورة المستخدم
              profile?.imageFullUrl != null
                  ? ClipOval(
                      child: CustomImageWidget(
                        width: 50,
                        height: 50,
                        image: profile!.imageFullUrl!,
                      ),
                    )
                  : ClipOval(
                      child: CustomImageWidget(
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        image:
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRU1ftWhltEa8iosdj8uKtRnm5fE-Sd_oKQaA&s',
                      ),
                    ),

              const SizedBox(width: Dimensions.paddingSizeDefault),

              /// اسم ورقم الهاتف
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profile?.fName ?? ""} ${profile?.lName ?? ""}',
                      style: robotoSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      profile?.phone ?? "",
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault),
                    ),
                  ],
                ),
              ),

              /// زر تعديل الملف الشخصي
              CustomButtonWidget(
                width: 100,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                fontColor: Theme.of(context).textTheme.bodyMedium!.color,
                radius: Dimensions.radiusOverLarge,
                buttonText: 'edit'.tr,
                isBorder: true,
                isBold: false,
                onPressed: () {
                  Get.toNamed(RouteHelper.getUpdateProfileRoute());
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: Dimensions.paddingSizeDefault),

        // صف المعلومات الإضافية (عدد الأيام + إجمالي الطلبات)
        Row(
          children: [
            ProfileCardWidget(
              title: 'since_joining'.tr,
              data: '${profile?.memberSinceDays ?? 0} ${'days'.tr}',
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            ProfileCardWidget(
              title: 'total_orders'.tr,
              data: profile?.orderCount.toString() ?? '0',
            ),
          ],
        ),
      ],
    );
  }
}
