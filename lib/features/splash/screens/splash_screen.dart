import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wefrh_rider/api/api_checker.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/common/widgets/no_internet_screen.dart';
import 'package:wefrh_rider/features/auth/controllers/auth_controller.dart';
import 'package:wefrh_rider/features/dashboard/screens/dashboard_screen.dart';
import 'package:wefrh_rider/features/language/controllers/language_controller.dart';
import 'package:wefrh_rider/features/splash/controllers/splash_controller.dart';
import 'package:wefrh_rider/features/splash/widgets/build_loading_widget.dart';
import 'package:wefrh_rider/features/profile/controllers/profile_controller.dart';
import 'package:wefrh_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/styles.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  const SplashScreen({super.key, required this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  bool _loadFailed = false; // حالة الفشل

  @override
  void initState() {
    super.initState();
    print("NavigationHandler: initState started");

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Get.find<SplashController>().initSharedData();

    final localizationController = Get.find<LocalizationController>();
    print(
        'localizationController.selectedLanguageIndex = ${localizationController.selectedLanguageIndex}');

    // لا نجلب البروفايل هنا - سنفعل ذلك في _validateSession
    // if (Get.find<AuthController>().isLoggedIn()) {
    //   await Get.find<ProfileController>().getProfile();
    // }

    _listenConnectivity();
    _loadConfig();
  }

  // في SplashScreen._route()
  Future<bool> _validateSession() async {
    try {
      await Get.find<ProfileController>().getProfile(isFromSplash: true);
      bool isValid = Get.find<ProfileController>().profileModel != null;

      // إذا الجلسة منتهية، حفظ سبب تسجيل الخروج
      if (!isValid) {
        await Get.find<AuthController>().setLogoutReason('session_expired');
      }

      return isValid;
    } catch (e) {
      print("Session validation failed: $e");
      return false;
    }
  }

  void _listenConnectivity() {
    bool firstTime = true;
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);

      if (!firstTime) {
        if (isConnected && _loadFailed) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          _loadConfig();
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(
            isConnected ? 'connected'.tr : 'no_connection'.tr,
            textAlign: TextAlign.center,
          ),
        ));
      }
      firstTime = false;
    });
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

    bool success = await Get.find<SplashController>().getConfigData();

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

    Timer(const Duration(seconds: 1), () async {
      final config = Get.find<SplashController>().configModel;

      if (config == null) {
        Get.offAllNamed(RouteHelper.getSignInRoute());
        return;
      }

      double? minimumVersion = _getMinimumVersion();
      bool isMaintenanceMode = config.maintenanceMode ?? false;
      bool needsUpdate = AppConstants.appVersion < (minimumVersion ?? 0);

      if (needsUpdate || isMaintenanceMode) {
        Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
      } else {
        // فحص صلاحية الجلسة قبل التوجيه
        if (Get.find<AuthController>().isLoggedIn()) {
          bool isSessionValid = await _validateSession();

          if (!isSessionValid) {
            // الجلسة منتهية - الانتقال لتسجيل الدخول بدون Dialog
            ApiChecker.resetDialogState();
            Get.offAllNamed(RouteHelper.getSignInRoute());
            return;
          }
        }

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
      return Get.find<SplashController>().configModel!.appMinimumVersionAndroid;
    } else if (GetPlatform.isIOS) {
      return Get.find<SplashController>().configModel!.appMinimumVersionIos;
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
    if (Get.find<AuthController>().isLoggedIn()) {
      await Get.find<AuthController>().updateToken();
      await Get.find<ProfileController>().getProfile();
      Get.offNamed(RouteHelper.getInitialRoute());
    } else {
      Get.offNamed(RouteHelper.getSignInRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      key: _globalKey,
      body: Center(
        child: _loadFailed
            ? _buildNoInternetScreen()
            : buildLoadingWidget(context),
      ),
    );
  }

  Widget buildLoadingWidget(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).cardColor,
      child: Center(
        child: Image.asset(
          // ✅ استخدم اللوجو المناسب حسب الثيم
          isDark
              ? 'assets/image/rider_splash_dark.png'
              : 'assets/image/rider_splash_light.png',
          width: MediaQuery.of(context).size.width * 0.7,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildNoInternetScreen() {
    return NoInternetScreen(
      child: SplashScreen(body: widget.body),
    );
  }
}
