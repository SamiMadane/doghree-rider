import 'package:wefrh_rider/common/widgets/empty_state_widget.dart';
import 'package:wefrh_rider/features/notification/controllers/notification_controller.dart';
import 'package:wefrh_rider/helper/date_converter_helper.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_image_widget.dart';
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

        List<DateTime> dateTimeList = [];

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
                DateTime originalDateTime =
                    DateConverterHelper.dateTimeStringToDate(notification.createdAt!);
                DateTime convertedDate = DateTime(
                    originalDateTime.year, originalDateTime.month, originalDateTime.day);

                bool addTitle = false;
                if (!dateTimeList.contains(convertedDate)) {
                  addTitle = true;
                  dateTimeList.add(convertedDate);
                }

                // ✅ Server-side isRead مش SharedPreferences
                bool isSeen = notification.isRead;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (addTitle)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
                        child: Text(
                          DateConverterHelper.convertTodayYesterdayDate(notification.createdAt!),
                          style: textRegular().copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withAlpha(180),
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
                            padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
                            // ✅ Background color بناءً على isRead
                            color: isSeen
                                ? null
                                : Theme.of(context).primaryColor.withAlpha(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (notification.imageFullUrl != null &&
                                    notification.imageFullUrl!.isNotEmpty)
                                  ClipOval(
                                    child: CustomImageWidget(
                                      image: notification.imageFullUrl!,
                                      height: 60,
                                      width: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else if (!isSeen)
                                  Container(
                                    height: 12,
                                    width: 12,
                                    margin: EdgeInsets.only(top: 4),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                else
                                  SizedBox(width: 12),
                                SizedBox(width: Dimensions.w16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                                    ? Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color
                                                        ?.withAlpha(128)
                                                    : null,
                                                fontWeight: isSeen
                                                    ? FontWeight.w500
                                                    : FontWeight.w600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: Dimensions.w10),
                                          Text(
                                            DateConverterHelper.convertTimeDifference(
                                                notification.createdAt!),
                                            style: textMedium().copyWith(
                                              fontSize: Dimensions.fs12,
                                              color: Theme.of(context).hintColor,
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
                                              ? Theme.of(context).disabledColor
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color
                                                  ?.withAlpha(180),
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
