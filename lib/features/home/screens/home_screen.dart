import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
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
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
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
        title:
            '${profileController.profileModel?.fName} ${profileController.profileModel?.lName}',
        centerTitle: false,
        isBackButtonExist: false,
        leadingWidget: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          child: ClipOval(
            child: CustomImageWidget(
                
              fit: BoxFit.cover,
              image: profileController.profileModel!.imageFullUrl,
            ),
          ),
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
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
          child: Container(
            color: Theme.of(context).cardColor,
            child: Column(children: [
              if (!_isNotificationPermissionGranted)
                permissionWarning(
                    isBatteryPermission: false,
                    onTap: requestNotificationPermission,
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
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
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

  Widget permissionWarning(
      {required bool isBatteryPermission,
      required Function() onTap,
      required Function() closeOnTap}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .textTheme
            .bodyLarge!
            .color
            ?.withValues(alpha: 0.7),
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Row(children: [
                if (isBatteryPermission)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.warning_rounded,
                      color: Colors.yellow,
                    ),
                  ),
                Expanded(
                  child: Row(children: [
                    Flexible(
                      child: Text(
                        isBatteryPermission
                            ? 'for_better_performance_allow_notification_to_run_in_background'
                                .tr
                            : 'notification_is_disabled_please_allow_notification'
                                .tr,
                        maxLines: 2,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    const Icon(
                      Icons.arrow_circle_right_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ]),
                ),
                const SizedBox(width: 20),
              ]),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: InkWell(
                onTap: closeOnTap,
                child: const Icon(Icons.clear, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
