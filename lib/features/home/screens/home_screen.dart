import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/home/widgets/active_order_section.dart';
import 'package:sixam_mart_delivery/features/home/widgets/cash_in_hand_section.dart';
import 'package:sixam_mart_delivery/features/home/widgets/earning_grid_section.dart';
import 'package:sixam_mart_delivery/features/home/widgets/online_status_section.dart';
import 'package:sixam_mart_delivery/features/home/widgets/profile_order_section.dart';
import 'package:sixam_mart_delivery/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart_delivery/features/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
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
        padding: EdgeInsets.all(Dimensions.p30),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
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
                  SizedBox(width: Dimensions.p16),
                  Expanded(
                    child: Text(
                      'Make Your Work Easier with Notifications!',
                      style: robotoBold.copyWith(fontSize: Dimensions.fs20),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),

              SizedBox(height: Dimensions.p16),

              // Description
              Text(
                'Enable notifications to get new orders instantly and stay updated on every step.',
                style: robotoRegular.copyWith(
                    fontSize: Dimensions.fs14),
                maxLines: 2,
              ),

              SizedBox(height: Dimensions.p30),

              // Subheading
              Text(
                'Why enable notifications?',
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fs18),
              ),

              SizedBox(height: Dimensions.p16),

              // Features list
              _buildFeatureRow(
                  ManagerAssets.newOrderIcon, 'Receive new orders right away'),
              SizedBox(height: Dimensions.p10),
              _buildFeatureRow(ManagerAssets.trakingIcon,
                  'Track delivery status step by step'),
              SizedBox(height: Dimensions.p10),
              _buildFeatureRow(ManagerAssets.offersIcon,
                  'Get special offers & incentives for drivers'),
              SizedBox(height: Dimensions.p10),
              _buildFeatureRow(ManagerAssets.alertsIcon,
                  'Important alerts from the management'),

              SizedBox(height: Dimensions.p30),

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
                      buttonText: 'Allow Notifications',
                    ),
                  ),
                  SizedBox(width: Dimensions.p16),
                  Expanded(
                    flex: 1,
                    child: CustomButtonWidget(
                      isBorder: true,
                      transparent: true,
                      borderColor:
                          Theme.of(context).textTheme.bodyMedium?.color,
                      fontColor: Theme.of(context).textTheme.bodyMedium?.color,
                      onPressed: () => Get.back(),
                      buttonText: 'Later',
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
        SvgPicture.asset(iconPath),
        SizedBox(width: Dimensions.p8),
        Expanded(
          child: Text(
            text,
            style: robotoRegular.copyWith(fontSize: Dimensions.fs14),
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
    final notificationController = Get.find<NotificationController>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
        centerTitle: false,
        isBackButtonExist: false,
        titleWidget: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(Dimensions.p4),
              child: ClipOval(
                child: CustomImageWidget(
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  image: profileController.profileModel!.imageFullUrl,
                ),
              ),
            ),
            SizedBox(width: Dimensions.p8),
            Text(
              '${profileController.profileModel?.fName} ${profileController.profileModel?.lName}',
              style: robotoSemiBold.copyWith(
                fontSize: Dimensions.fs18,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            )
          ],
        ),
        actionWidget: IconButton(
          icon: Stack(
            children: [
              SvgPicture.asset(
                ManagerAssets.notificationIcon, // مسار الأيقونة

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
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          return await _loadData();
        },
        child: Padding(
          padding: const EdgeInsets.only(top: Dimensions.p16),
          child: Container(
            color: Theme.of(context).cardColor,
            child: Column(children: [
              if (!_isNotificationPermissionGranted)
                permissionWarning(
                    isBatteryPermission: false,
                    onTap: showNotificationPermissionBottomSheet,
                    closeOnTap: () {
                      setState(() {
                        _isNotificationPermissionGranted = true;
                      });
                    }),
              if (!_isBatteryOptimizationGranted)
                permissionWarning(
                    isBatteryPermission: true,
                    onTap: requestBatteryOptimization,
                    closeOnTap: () {
                      setState(() {
                        _isBatteryOptimizationGranted = true;
                      });
                    }),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.p16),
                  child: GetBuilder<ProfileController>(
                      builder: (profileController) {
                    return Column(children: [
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
                    ]);
                  }),
                ),
              ),
            ]),
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
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color bgColor =
        Theme.of(context).colorScheme.surface.withOpacity(0.6);
    var isArabic =
        Get.locale?.languageCode == AppConstants.languages[1].languageCode;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
          horizontal: Dimensions.p10,
          vertical: Dimensions.p4),
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
              padding: const EdgeInsets.all(Dimensions.p10),
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(
                          Dimensions.p4),
                      decoration: BoxDecoration(
                        color: ManagerColors.orangeLightMode
                            .withOpacity(0.2), // أصفر فاتح شفاف
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        ManagerAssets.warningIcon,
                        color: ManagerColors.orangeLightMode,
                      )),
                  const SizedBox(width: 10),
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
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fs12,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.p10),
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
                  const SizedBox(width: 20),
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
