import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixam_mart_delivery/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_delivery/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/navigation_handler/controllers/navigation_handler_controller.dart';
import 'package:sixam_mart_delivery/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';

class NavigationHandlerScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  const NavigationHandlerScreen({super.key, required this.body});

  @override
  NavigationHandlerScreenState createState() => NavigationHandlerScreenState();
}

class NavigationHandlerScreenState extends State<NavigationHandlerScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

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
        if (isConnected) {
          ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
          print("NavigationHandler: Connected - hiding snackbar");
        } else {
          print("NavigationHandler: Not connected");
        }
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(
            isConnected ? 'connected'.tr : 'no_connection'.tr,
            textAlign: TextAlign.center,
          ),
        ));
        if (isConnected) {
          print("NavigationHandler: Connected - calling _route()");
          _route();
        }
      }

      firstTime = false;
    });

    print("NavigationHandler: Initializing shared data");
    Get.find<NavigationHandlerController>().initSharedData();

    print("NavigationHandler: Calling _route()");
    _route();
  }

  @override
  void dispose() {
    print(
        "NavigationHandler: dispose called, cancelling connectivity subscription");
    _onConnectivityChanged?.cancel();
    super.dispose();
  }

  void _route() async {
  print("NavigationHandler: Starting _route()");

  final localizationController = Get.find<LocalizationController>();

  // إذا لم يتم اختيار لغة → عرض Bottom Sheet مباشرة
  if (localizationController.selectedLanguageIndex == -1) {
    print("NavigationHandler: No language selected, showing bottom sheet first");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLanguageBottomSheet();
    });
    return; // إيقاف أي توجيه آخر
  }

  // جلب إعدادات السيرفر
  bool isSuccess = await Get.find<NavigationHandlerController>().getConfigData();
  print("NavigationHandler: Config fetch isSuccess = $isSuccess");

  if (!isSuccess) return;

  Timer(const Duration(seconds: 1), () async {
    print("NavigationHandler: Inside Timer callback");
    double? minimumVersion = _getMinimumVersion();
    bool isMaintenanceMode = Get.find<NavigationHandlerController>()
        .configModel!
        .maintenanceMode!;
    bool needsUpdate = AppConstants.appVersion < minimumVersion!;
    print("NavigationHandler: minimumVersion=$minimumVersion, appVersion=${AppConstants.appVersion}");
    print("NavigationHandler: needsUpdate=$needsUpdate, isMaintenanceMode=$isMaintenanceMode");

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
    print("NavigationHandler: Getting minimum app version");
    if (GetPlatform.isAndroid) {
      print("NavigationHandler: Platform is Android");
      return Get.find<NavigationHandlerController>()
          .configModel!
          .appMinimumVersionAndroid;
    } else if (GetPlatform.isIOS) {
      print("NavigationHandler: Platform is iOS");
      return Get.find<NavigationHandlerController>()
          .configModel!
          .appMinimumVersionIos;
    }
    print("NavigationHandler: Platform unknown, returning 0");
    return 0;
  }

  Future<void> _handleNotificationRouting(
      NotificationBodyModel? notificationBody) async {
    print("NavigationHandler: _handleNotificationRouting called");
    final notificationType = notificationBody?.notificationType;
    print("NavigationHandler: Notification type: $notificationType");

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
      NotificationType.otp: () =>
          print("NavigationHandler: OTP notification - no navigation"),
      NotificationType.unassign: () =>
          Get.to(const DashboardScreen(pageIndex: 1)),
      NotificationType.message: () => Get.toNamed(RouteHelper.getChatRoute(
          notificationBody: notificationBody,
          conversationId: notificationBody?.conversationId,
          fromNotification: true)),
      NotificationType.general: () =>
          Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
    };

    if (notificationActions[notificationType] != null) {
      print("NavigationHandler: Executing action for notification type");
      notificationActions[notificationType]?.call();
    } else {
      print("NavigationHandler: No action defined for this notification type");
    }
  }

  void _handleDefaultRouting() async {
    print("NavigationHandler: _handleDefaultRouting called");

    final localizationController = Get.find<LocalizationController>();

    // إذا لم يتم اختيار لغة مسبقاً → عرض Bottom Sheet
    if (localizationController.selectedLanguageIndex == -1) {
      print("NavigationHandler: No language selected, showing bottom sheet");
      _showLanguageBottomSheet();
      return;
    }

    // إذا تم اختيار لغة مسبقاً → تابع التوجيه العادي
    if (Get.find<AuthController>().isLoggedIn()) {
      print(
          "NavigationHandler: User logged in, updating token and fetching profile");
      await Get.find<AuthController>().updateToken();
      await Get.find<ProfileController>().getProfile();
      print("NavigationHandler: Navigating to initial route");
      Get.offNamed(RouteHelper.getInitialRoute());
    } else {
      print(
          "NavigationHandler: User not logged in, navigating to sign in route");
      Get.offNamed(RouteHelper.getSignInRoute());
    }
  }

// الدالة لإظهار Bottom Sheet
  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => const LanguageBottomSheetWidget(),
    ).then((_) async {
      print("NavigationHandler: Language selected, proceeding to next screen");


      // بعد اختيار اللغة → التوجيه حسب حالة تسجيل الدخول
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      key: _globalKey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(ManagerAssets.splashLogoLightImage, width: 280),
          ]),
        ),
      ),
    );
  }
}
