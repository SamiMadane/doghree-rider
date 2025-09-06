import 'package:sixam_mart_delivery/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
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
    // جلب البيانات من API
    Get.find<NotificationController>().getNotificationList();
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
        if (notifications == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (notifications.isEmpty) {
          return Center(child: Text('no_notification_found'.tr));
        }

        List<DateTime> dateTimeList = [];

        return RefreshIndicator(
          onRefresh: () async {
            await controller.getNotificationList();
          },
          child: Container(
            color: Theme.of(context).cardColor,
            margin: EdgeInsets.only(top: Dimensions.p16),
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                DateTime originalDateTime =
                    DateConverterHelper.dateTimeStringToDate(
                        notification.createdAt!);
                DateTime convertedDate = DateTime(originalDateTime.year,
                    originalDateTime.month, originalDateTime.day);

                bool addTitle = false;
                if (!dateTimeList.contains(convertedDate)) {
                  addTitle = true;
                  dateTimeList.add(convertedDate);
                }

                bool isSeen = controller
                        .getSeenNotificationIdList()
                        ?.contains(notification.id) ??
                    false;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (addTitle)
                      Padding(
                        padding:
                            const EdgeInsets.all(Dimensions.p16),
                        child: Text(
                          DateConverterHelper.convertTodayYesterdayDate(
                              notification.createdAt!),
                          style: robotoRegular.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color
                                  ?.withAlpha(180)),
                        ),
                      ),
                    InkWell(
                      onTap: () {
                        controller.addSeenNotificationId(notification.id!);
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                                Dimensions.p16),
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
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                else
                                  const SizedBox(width: 12),
                                const SizedBox(
                                    width: Dimensions.p16),
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
                                              style: robotoSemiBold.copyWith(
                                                  fontSize: Dimensions
                                                      .fs14),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  Dimensions.p10),
                                          Text(
                                            DateConverterHelper
                                                .convertTimeDifference(
                                                    notification.createdAt!),
                                            style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fs12,
                                                color: Theme.of(context)
                                                    .hintColor),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height:
                                              Dimensions.p4),
                                      Text(
                                        notification.description ?? '',
                                        style: robotoRegular.copyWith(
                                            fontSize:
                                                Dimensions.fs14),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                )
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
