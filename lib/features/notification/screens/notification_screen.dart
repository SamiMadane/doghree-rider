import 'package:doghree_rider/common/widgets/empty_state_widget.dart';
import 'package:doghree_rider/features/notification/controllers/notification_controller.dart';
import 'package:doghree_rider/helper/date_converter_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  final bool fromNotification;
  const NotificationScreen({super.key, this.fromNotification = false});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ جلب البيانات من API مع تأكد من الاستدعاء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<NotificationController>().getNotificationList(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'notifications'.tr,
        onBackPressed: () {
          if (widget.fromNotification) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          } else {
            Get.back();
          }
        },
      ),
      body: GetBuilder<NotificationController>(builder: (controller) {
        final notifications = controller.notificationList;

        // ✅ Loading state
        if (controller.isLoading || notifications == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // ✅ Empty state
        if (notifications.isEmpty) {
          return Container(
            margin: EdgeInsets.only(top: Dimensions.h16),
            color: Theme.of(context).cardColor,
            child: EmptyStateWidget(
              image: ManagerAssets.noNotificationImage,
              imageScale: 1.1,
              title: 'no_notifications'.tr,
              description: 'no_new_notifications_yet'.tr,
              buttonText: 'back_to_home_screen'.tr,
              onButtonPressed: () {
                Get.offAllNamed(RouteHelper.getInitialRoute());
              },
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.getNotificationList(true);
          },
          child: Container(
            color: Theme.of(context).cardColor,
            margin: EdgeInsets.only(top: Dimensions.h16),
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final DateTime date = DateConverterHelper.dateTimeStringToDate(
                    notification.createdAt!);

                // ✅ عنوان التاريخ: يظهر لما يختلف يوم الإشعار عن اللي قبله.
                // (بدل قائمة تتراكم أثناء البناء وكانت تخفي العنوان بعد السكرول)
                bool addTitle = true;
                if (index > 0) {
                  final DateTime prev =
                      DateConverterHelper.dateTimeStringToDate(
                          notifications[index - 1].createdAt!);
                  addTitle = !(prev.year == date.year &&
                      prev.month == date.month &&
                      prev.day == date.day);
                }

                // ✅ Server-side isRead مش SharedPreferences
                bool isSeen = notification.isRead;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (addTitle)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.w16,
                          vertical: Dimensions.h16,
                        ),
                        child: Text(
                          DateConverterHelper.convertTodayYesterdayDate(
                              notification.createdAt!),
                          style: textRegular().copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    InkWell(
                      onTap: () async {
                        // ✅ Mark as read + Navigation
                        await controller.handleNotificationTap(notification);
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.w16,
                              vertical: Dimensions.h16,
                            ),
                            // ✅ Background color بناءً على isRead
                            color: isSeen
                                ? null
                                : scheme.primaryContainer
                                    .withValues(alpha: 0.6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (notification.imageFullUrl != null &&
                                    notification.imageFullUrl!.isNotEmpty)
                                  ClipOval(
                                    child: CustomImageWidget(
                                      image: notification.imageFullUrl!,
                                      height: Dimensions.w60,
                                      width: Dimensions.w60,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else if (!isSeen)
                                  Container(
                                    height: Dimensions.w14,
                                    width: Dimensions.w14,
                                    margin: EdgeInsets.only(top: Dimensions.h4),
                                    decoration: BoxDecoration(
                                      color: scheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            scheme.brightness == Brightness.dark
                                                ? Colors.white
                                                : scheme.onPrimary,
                                        width: 2,
                                      ),
                                    ),
                                  )
                                else
                                  SizedBox(width: Dimensions.w14),
                                SizedBox(width: Dimensions.w16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notification.title ?? '',
                                              style: textSemiBold().copyWith(
                                                fontSize: Dimensions.fs14,
                                                // ✅ Title style بناءً على isRead
                                                color: isSeen
                                                    ? scheme.onSurfaceVariant
                                                    : scheme.onSurface,
                                                fontWeight: isSeen
                                                    ? FontWeight.w500
                                                    : FontWeight.w700,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: Dimensions.w10),
                                          Text(
                                            DateConverterHelper
                                                .convertTimeDifference(
                                                    notification.createdAt!),
                                            style: textMedium().copyWith(
                                              fontSize: Dimensions.fs12,
                                              color: scheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: Dimensions.h4),
                                      Text(
                                        notification.description ?? '',
                                        style: textRegular().copyWith(
                                          fontSize: Dimensions.fs14,
                                          // ✅ Description style بناءً على isRead
                                          color: isSeen
                                              ? scheme.onSurfaceVariant
                                                  .withValues(alpha: 0.8)
                                              : scheme.onSurface,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
