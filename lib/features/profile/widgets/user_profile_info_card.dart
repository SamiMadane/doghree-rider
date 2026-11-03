import 'package:doghree_rider/common/widgets/brand_dot_widget.dart';
import 'package:doghree_rider/features/profile/widgets/profile_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class UserProfileInfoCard extends StatelessWidget {
  final ProfileController profileController;

  const UserProfileInfoCard({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    final profile = profileController.profileModel;
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        ProfileCard(
          child: Row(
            children: [
              _Avatar(imageUrl: profile?.imageFullUrl),
              SizedBox(width: Dimensions.w16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profile?.fName ?? ''} ${profile?.lName ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textBold().copyWith(
                        fontSize: Dimensions.fs16,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: Dimensions.h4),
                    Text(
                      profile?.phone ?? '',
                      textDirection: TextDirection.ltr,
                      style: textRegular().copyWith(
                        fontSize: Dimensions.fs14,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Dimensions.w8),
              CustomButtonWidget(
                width: Dimensions.w80,
                height: Dimensions.h40,
                transparent: true,
                isBorder: true,
                radius: Dimensions.r50,
                borderColor: cs.onSurface,
                textColor: cs.onSurface,
                fontSize: Dimensions.fs14,
                buttonText: 'edit'.tr,
                onPressed: () =>
                    Get.toNamed(RouteHelper.getUpdateProfileRoute()),
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.h16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ProfileCard(
                  radius: Dimensions.r20,
                  child: _Stat(
                    label: 'since_joining'.tr,
                    value: '${profile?.memberSinceDays ?? 0} ${'days'.tr}',
                  ),
                ),
              ),
              SizedBox(width: Dimensions.w12),
              Expanded(
                child: ProfileCard(
                  radius: Dimensions.r20,
                  child: _Stat(
                    label: 'total_orders'.tr,
                    value: profile?.orderCount.toString() ?? '0',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Network photo when available, otherwise a local avatar.
class _Avatar extends StatelessWidget {
  final String? imageUrl;

  const _Avatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final double size = Dimensions.w50;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cs.primaryContainer,
        ),
        child: Icon(
          Icons.person_rounded,
          size: size * 0.6,
          color: cs.onPrimaryContainer,
        ),
      );
    }

    return ClipOval(
      child: CustomImageWidget(
        width: size,
        height: size,
        fit: BoxFit.cover,
        image: imageUrl!,
      ),
    );
  }
}

/// Yellow dot + label on top, big value below.
class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const BrandDot(),
            SizedBox(width: Dimensions.w8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textMedium().copyWith(
                  fontSize: Dimensions.fs13,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Dimensions.h12),
        Text(
          value,
          style: textBold().copyWith(
            fontSize: Dimensions.fs20,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}
