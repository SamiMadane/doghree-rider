import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixam_mart_delivery/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_delivery/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/features/navigation_handler/widgets/loading_dots.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/navigation_handler/controllers/navigation_handler_controller.dart';
import 'package:sixam_mart_delivery/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class NavigationHandlerScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  const NavigationHandlerScreen({super.key, required this.body});

  @override
  NavigationHandlerScreenState createState() => NavigationHandlerScreenState();
}

class NavigationHandlerScreenState extends State<NavigationHandlerScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  bool _loadFailed = false; // حالة الفشل

  @override
  void initState() {
    super.initState();
    print("NavigationHandler: initState started");

    if (Get.find<AuthController>().isLoggedIn()) {
      print("NavigationHandler: User is logged in, fetching profile");
      Get.find<ProfileController>().getProfile();
    } else {
      print("NavigationHandler: User is NOT logged in");
    }

    bool firstTime = true;
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);
      print(
          "NavigationHandler: Connectivity changed - isConnected: $isConnected");

      if (!firstTime) {
        if (isConnected && _loadFailed) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(
            isConnected ? 'connected'.tr : 'no_connection'.tr,
            textAlign: TextAlign.center,
          ),
        ));
        if (isConnected && _loadFailed) {
          _loadConfig();
        }
      }

      firstTime = false;
    });

    print("NavigationHandler: Initializing shared data");
    Get.find<NavigationHandlerController>().initSharedData();

    // بدء تحميل البيانات فور الدخول
    print("NavigationHandler: Calling _loadConfig()");
    _loadConfig();
  }

  @override
  void dispose() {
    print(
        "NavigationHandler: dispose called, cancelling connectivity subscription");
    _onConnectivityChanged?.cancel();
    super.dispose();
  }

  void _loadConfig() async {
    setState(() {
      _loadFailed = false;
    });

    bool success =
        await Get.find<NavigationHandlerController>().getConfigData();

    if (success) {
      _route(); // التوجيه بعد تحميل البيانات
    } else {
      setState(() {
        _loadFailed = true;
      });
    }
  }

  void _route() async {
    print("NavigationHandler: Starting _route()");

    final localizationController = Get.find<LocalizationController>();

    if (localizationController.selectedLanguageIndex == -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLanguageBottomSheet();
      });
      return;
    }

    Timer(const Duration(seconds: 1), () async {
      double? minimumVersion = _getMinimumVersion();
      bool isMaintenanceMode =
          Get.find<NavigationHandlerController>().configModel!.maintenanceMode!;
      bool needsUpdate = AppConstants.appVersion < minimumVersion!;

      if (needsUpdate || isMaintenanceMode) {
        Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
      } else {
        if (widget.body != null) {
          await _handleNotificationRouting(widget.body);
        } else {
          _handleDefaultRouting();
        }
      }
    });
  }

  double? _getMinimumVersion() {
    if (GetPlatform.isAndroid) {
      return Get.find<NavigationHandlerController>()
          .configModel!
          .appMinimumVersionAndroid;
    } else if (GetPlatform.isIOS) {
      return Get.find<NavigationHandlerController>()
          .configModel!
          .appMinimumVersionIos;
    }
    return 0;
  }

  Future<void> _handleNotificationRouting(
      NotificationBodyModel? notificationBody) async {
    final notificationType = notificationBody?.notificationType;

    final Map<NotificationType, Function> notificationActions = {
      NotificationType.order: () => Get.toNamed(
          RouteHelper.getOrderDetailsRoute(notificationBody?.orderId,
              fromNotification: true)),
      NotificationType.order_request: () =>
          Get.toNamed(RouteHelper.getMainRoute('order-request')),
      NotificationType.block: () =>
          Get.offAllNamed(RouteHelper.getSignInRoute()),
      NotificationType.unblock: () =>
          Get.offAllNamed(RouteHelper.getSignInRoute()),
      NotificationType.otp: () => print("OTP notification - no navigation"),
      NotificationType.unassign: () =>
          Get.to(const DashboardScreen(pageIndex: 1)),
      NotificationType.message: () => Get.toNamed(RouteHelper.getChatRoute(
          notificationBody: notificationBody,
          conversationId: notificationBody?.conversationId,
          fromNotification: true)),
      NotificationType.general: () =>
          Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
    };

    notificationActions[notificationType]?.call();
  }

  void _handleDefaultRouting() async {
    final localizationController = Get.find<LocalizationController>();

    if (localizationController.selectedLanguageIndex == -1) {
      _showLanguageBottomSheet();
      return;
    }

    if (Get.find<AuthController>().isLoggedIn()) {
      await Get.find<AuthController>().updateToken();
      await Get.find<ProfileController>().getProfile();
      Get.offNamed(RouteHelper.getInitialRoute());
    } else {
      Get.offNamed(RouteHelper.getSignInRoute());
    }
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => const LanguageBottomSheetWidget(),
    ).then((_) async {
      if (Get.find<AuthController>().isLoggedIn()) {
        await Get.find<AuthController>().updateToken();
        await Get.find<ProfileController>().getProfile();
        Get.offNamed(RouteHelper.getInitialRoute());
      } else {
        Get.offNamed(RouteHelper.getSignInRoute());
      }
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      key: _globalKey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height:50),
              Image.asset(
                ManagerAssets.logo,
                width: 180,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "delivery".tr,
                    style:robotoSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  LoadingDots(color: Theme.of(context).textTheme.bodyMedium!.color!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
