import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wefrh_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_image_widget.dart';
import 'package:wefrh_rider/features/auth/controllers/auth_controller.dart';
import 'package:wefrh_rider/features/home/widgets/active_order_section.dart';
import 'package:wefrh_rider/features/home/widgets/cash_in_hand_section.dart';
import 'package:wefrh_rider/features/home/widgets/earning_grid_section.dart';
import 'package:wefrh_rider/features/home/widgets/online_status_section.dart';
import 'package:wefrh_rider/features/home/widgets/profile_order_section.dart';
import 'package:wefrh_rider/features/notification/controllers/notification_controller.dart';
import 'package:wefrh_rider/features/order/controllers/order_controller.dart';
import 'package:wefrh_rider/features/profile/controllers/profile_controller.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/app_constants.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AppLifecycleListener _listener;
  bool _isNotificationPermissionGranted = true;
  bool _isBatteryOptimizationGranted = true;
  final RxBool showTotalEarnings = true.obs;

  @override
  void initState() {
    super.initState();

    _checkSystemNotification();

    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
    );

    _loadData();

    Future.delayed(const Duration(milliseconds: 200), () {
      checkPermission();
    });
  }

  Future<void> _loadData() async {
    Get.find<OrderController>().getIgnoreList();
    Get.find<OrderController>().removeFromIgnoreList();
    await Get.find<ProfileController>().getProfile();
    await Get.find<OrderController>().getCurrentOrders();
    await Get.find<NotificationController>().getNotificationList();
  }

  _checkSystemNotification() async {
    if (await Permission.notification.status.isDenied ||
        await Permission.notification.status.isPermanentlyDenied) {
      await Get.find<AuthController>().setNotificationActive(false);
    }
  }

  // Listen to the app lifecycle state changes
  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        checkPermission();
         if (Get.isRegistered<NotificationController>()) {
          Get.find<NotificationController>().getNotificationList(true);
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  Future<void> checkPermission() async {
    var notificationStatus = await Permission.notification.status;
    var batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    if (notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
      setState(() {
        _isNotificationPermissionGranted = false;
        _isBatteryOptimizationGranted = true;
      });

      await Get.find<AuthController>()
          .setNotificationActive(!notificationStatus.isDenied);
    } else if (batteryStatus.isDenied) {
      setState(() {
        _isBatteryOptimizationGranted = false;
        _isNotificationPermissionGranted = true;
      });
    } else {
      setState(() {
        _isNotificationPermissionGranted = true;
        _isBatteryOptimizationGranted = true;
      });
      Get.find<ProfileController>().setBackgroundNotificationActive(true);
    }

    if (batteryStatus.isDenied) {
      Get.find<ProfileController>().setBackgroundNotificationActive(false);
    }
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.request().isGranted) {
      checkPermission();
      return;
    } else {
      await openAppSettings();
    }

    checkPermission();
  }

  void requestBatteryOptimization() async {
    var status = await Permission.ignoreBatteryOptimizations.status;

    if (status.isGranted) {
      return;
    } else if (status.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    } else {
      openAppSettings();
    }

    checkPermission();
  }

  void showNotificationPermissionBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.w30, vertical: Dimensions.h30),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.r20),
            topRight: Radius.circular(Dimensions.r20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Image.asset(
                    ManagerAssets.logo,
                    height: 70,
                    width: 70,
                  ),
                  SizedBox(width: Dimensions.w16),
                  Expanded(
                    child: Text(
                      'make_work_easier_notifications'.tr,
                      style: textBold().copyWith(fontSize: Dimensions.fs20),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),

              SizedBox(height: Dimensions.h16),

              // Description
              Text(
                'enable_notifications_description'.tr,
                style: textRegular().copyWith(fontSize: Dimensions.fs14),
                maxLines: 2,
              ),

              SizedBox(height: Dimensions.h30),

              // Subheading
              Text(
                'why_enable_notifications'.tr,
                style: textBold().copyWith(fontSize: Dimensions.fs18),
              ),

              SizedBox(height: Dimensions.h16),

              // Features list
              _buildFeatureRow(
                  ManagerAssets.newOrderIcon, 'receive_new_orders'.tr),
              SizedBox(height: Dimensions.h10),
              _buildFeatureRow(
                  ManagerAssets.trakingIcon, 'track_delivery_status'.tr),
              SizedBox(height: Dimensions.h10),
              _buildFeatureRow(
                  ManagerAssets.offersIcon, 'get_special_offers'.tr),
              SizedBox(height: Dimensions.h10),
              _buildFeatureRow(
                  ManagerAssets.alertsIcon, 'important_management_alerts'.tr),

              SizedBox(height: Dimensions.h30),

              // Buttons
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomButtonWidget(
                      onPressed: () async {
                        requestNotificationPermission();
                        Get.back();
                      },
                      buttonText: 'allow_notifications'.tr,
                    ),
                  ),
                  SizedBox(width: Dimensions.w16),
                  Expanded(
                    flex: 1,
                    child: CustomButtonWidget(
                      isBorder: true,
                      transparent: true,
                      borderColor:
                          Theme.of(context).textTheme.bodyMedium?.color,
                      fontColor: Theme.of(context).textTheme.bodyMedium?.color,
                      onPressed: () => Get.back(),
                      buttonText: 'later'.tr,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isDismissible: true,
      backgroundColor: Colors.transparent,
    );
  }

// دالة مساعدة لبناء كل صف من المميزات
  Widget _buildFeatureRow(String iconPath, String text) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          color: Theme.of(context).primaryColor,
        ),
        SizedBox(width: Dimensions.w8),
        Expanded(
          child: Text(
            text,
            style: textRegular().copyWith(fontSize: Dimensions.fs14),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
        centerTitle: false,
        isBackButtonExist: false,
        titleWidget: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.w4,
                vertical: Dimensions.h4,
              ),
              child: ClipOval(
                child: CustomImageWidget(
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  image: profileController.profileModel!.imageFullUrl,
                ),
              ),
            ),
            SizedBox(width: Dimensions.w8),
            Text(
              '${profileController.profileModel?.fName} ${profileController.profileModel?.lName}',
              style: textSemiBold().copyWith(
                fontSize: Dimensions.fs18,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            )
          ],
        ),
        actionWidget: GetBuilder<NotificationController>(
          builder: (notificationController) {
            return IconButton(
              icon: Stack(
                children: [
                  SvgPicture.asset(
                    ManagerAssets.notificationIcon,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  if (notificationController.hasNotification)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 1, color: Theme.of(context).cardColor),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () => Get.toNamed(RouteHelper.getNotificationRoute()),
            );
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          return await _loadData();
        },
        child: Padding(
          padding: EdgeInsets.only(top: Dimensions.h16),
          child: Container(
            color: Theme.of(context).cardColor,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (!_isNotificationPermissionGranted)
                    permissionWarning(
                      isBatteryPermission: false,
                      onTap: showNotificationPermissionBottomSheet,
                      closeOnTap: () {
                        setState(() {
                          _isNotificationPermissionGranted = true;
                        });
                      },
                    ),
                  if (!_isBatteryOptimizationGranted)
                    permissionWarning(
                      isBatteryPermission: true,
                      onTap: requestBatteryOptimization,
                      closeOnTap: () {
                        setState(() {
                          _isBatteryOptimizationGranted = true;
                        });
                      },
                    ),
                  GetBuilder<ProfileController>(
                    builder: (profileController) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.w16,
                          vertical: Dimensions.h16,
                        ),
                        child: Column(
                          children: [
                            const StatusSwitchSection(),
                            EarningsGridSection(
                              profileController: profileController,
                              showEarnings: showTotalEarnings,
                            ),
                            ActiveOrderSection(),
                            ProfileOrdersSection(
                              profileController: profileController,
                            ),
                            CashInHandSection(
                              profileController: profileController,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget permissionWarning({
    required bool isBatteryPermission,
    required Function() onTap,
    required Function() closeOnTap,
  }) {
    final Color textColor = Theme.of(context).textTheme.bodyMedium!.color!;
    final Color bgColor =
        Theme.of(context).colorScheme.surface.withOpacity(0.6);
    var isArabic =
        Get.locale?.languageCode == AppConstants.languages[1].languageCode;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.w4,
        vertical: Dimensions.h4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.w10,
                vertical: Dimensions.h10,
              ),
              child: Row(
                children: [
                  Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.w4,
                        vertical: Dimensions.h4,
                      ),
                      decoration: BoxDecoration(
                        color: ManagerColors.orangeLightMode
                            .withOpacity(0.2), // أصفر فاتح شفاف
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        ManagerAssets.warningIcon,
                        color: ManagerColors.orangeLightMode,
                      )),
                  SizedBox(width: 10),
                  // النص + السهم
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            isBatteryPermission
                                ? 'for_better_performance_allow_notification_to_run_in_background'
                                    .tr
                                : 'notification_is_disabled_please_allow_notification'
                                    .tr,
                            maxLines: 2,
                            style: textRegular().copyWith(
                              fontSize: Dimensions.fs12,
                              color: textColor,
                            ),
                          ),
                        ),
                        SizedBox(width: Dimensions.w10),
                        Icon(
                          isArabic
                              ? Icons.arrow_circle_left_rounded
                              : Icons.arrow_circle_right_rounded,
                          color: textColor,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                ],
              ),
            ),
            // زر الإغلاق
            Positioned(
              top: 5,
              left: isArabic ? 5 : null,
              right: isArabic ? null : 5,
              child: InkWell(
                onTap: closeOnTap,
                borderRadius: BorderRadius.circular(20),
                child: Icon(
                  Icons.clear,
                  color: textColor.withOpacity(0.8),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
