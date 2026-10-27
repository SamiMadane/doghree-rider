import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/profile/widgets/profile_card_widget.dart';
import 'package:doghree_rider/helper/route_helper.dart';

class UserProfileInfoCard extends StatelessWidget {
  final ProfileController profileController;

  const UserProfileInfoCard({super.key, required this.profileController});

  /// Network photo when available, otherwise a local (offline) avatar.
  Widget _buildAvatar(BuildContext context, String? imageUrl) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double size = Dimensions.w50;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.primaryContainer,
        ),
        child: Icon(
          Icons.person_rounded,
          size: size * 0.6,
          color: scheme.tertiary,
        ),
      );
    }

    return ClipOval(
      child: CustomImageWidget(
        width: size,
        height: size,
        fit: BoxFit.cover,
        image: imageUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = profileController.profileModel;

    return Column(
      children: [
        CustomCard(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.w16,
            vertical: Dimensions.h16,
          ),
          isBorder: false,
          child: Row(
            children: [
              /// صورة المستخدم
              _buildAvatar(context, profile?.imageFullUrl),

              SizedBox(width: Dimensions.w16),

              /// اسم ورقم الهاتف
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profile?.fName ?? ""} ${profile?.lName ?? ""}',
                      style: textSemiBold().copyWith(fontSize: Dimensions.fs16),
                    ),
                    SizedBox(height: Dimensions.h4),
                    Text(
                      profile?.phone ?? "",
                      style: textRegular().copyWith(fontSize: Dimensions.fs14),
                    ),
                  ],
                ),
              ),

              /// زر تعديل الملف الشخصي
              CustomButtonWidget(
                width: Dimensions.w100,
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