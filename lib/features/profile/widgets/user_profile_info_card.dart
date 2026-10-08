import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/common/widgets/custom_image_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/features/profile/controllers/profile_controller.dart';
import 'package:wefrh_rider/features/profile/widgets/profile_card_widget.dart';
import 'package:wefrh_rider/helper/route_helper.dart';

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
          padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
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

              SizedBox(width: Dimensions.w16),

              /// اسم ورقم الهاتف
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profile?.fName ?? ""} ${profile?.lName ?? ""}',
                      style: textSemiBold().copyWith(
                          fontSize: Dimensions.fs16),
                    ),
                    SizedBox(height: Dimensions.h4),
                    Text(
                      profile?.phone ?? "",
                      style: textRegular().copyWith(
                          fontSize: Dimensions.fs14),
                    ),
                  ],
                ),
              ),

              /// زر تعديل الملف الشخصي
              CustomButtonWidget(
                width: 100,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                fontColor: Theme.of(context).textTheme.bodyMedium!.color,
                radius: Dimensions.r24,
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

        SizedBox(height: Dimensions.h16),

        // صف المعلومات الإضافية (عدد الأيام + إجمالي الطلبات)
        Row(
          children: [
            ProfileCardWidget(
              title: 'since_joining'.tr,
              data: '${profile?.memberSinceDays ?? 0} ${'days'.tr}',
            ),
            SizedBox(width: Dimensions.w10),
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
