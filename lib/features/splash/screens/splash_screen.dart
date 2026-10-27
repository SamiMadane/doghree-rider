import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/common/widgets/no_internet_screen.dart';
import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/dashboard/screens/dashboard_screen.dart';
import 'package:doghree_rider/features/language/controllers/language_controller.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:doghree_rider/features/splash/widgets/doghree_splash_animation.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  const SplashScreen({super.key, required this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  bool _loadFailed = false;
  bool _isLoading = true;
  VoidCallback? _pendingNavigation;

  @override
  void initState() {
    super.initState();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Get.find<SplashController>().initSharedData();

    Get.find<LocalizationController>();

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
    _onConnectivityChanged?.cancel();
    super.dispose();
  }

  void _loadConfig() async {
    setState(() {
      _loadFailed = false;
      _isLoading = true;
    });

    bool success = await Get.find<SplashController>().getConfigData();
    if (!mounted) return;

    if (success) {
      _route();
    } else {
      setState(() {
        _loadFailed = true;
      });
    }
  }

  Future<void> _route() async {
    final config = Get.find<SplashController>().configModel;

    if (config == null) {
      _finishLoading(() => Get.offAllNamed(RouteHelper.getSignInRoute()));
      return;
    }

    double? minimumVersion = _getMinimumVersion();
    bool isMaintenanceMode = config.maintenanceMode ?? false;
    bool needsUpdate = AppConstants.appVersion < (minimumVersion ?? 0);

    if (needsUpdate || isMaintenanceMode) {
      _finishLoading(
          () => Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate)));
      return;
    }

    // فحص صلاحية الجلسة قبل التوجيه
    if (Get.find<AuthController>().isLoggedIn()) {
      bool isSessionValid = await _validateSession();
      if (!mounted) return;

      if (!isSessionValid) {
        // الجلسة منتهية - الانتقال لتسجيل الدخول بدون Dialog
        _finishLoading(() {
          ApiChecker.resetDialogState();
          Get.offAllNamed(RouteHelper.getSignInRoute());
        });
        return;
      }
    }

    if (widget.body != null) {
      _finishLoading(() => _handleNotificationRouting(widget.body));
    } else {
      _finishLoading(_handleDefaultRouting);
    }
  }

  /// التحميل خلص: نخزّن التوجيه وننهي الأنيميشن. التوجيه الفعلي بيصير بعد الكشف.
  void _finishLoading(VoidCallback navigate) {
    _pendingNavigation = navigate;
    setState(() => _isLoading = false);
  }

  void _onSplashAnimationFinished() {
    final VoidCallback? navigate = _pendingNavigation;
    _pendingNavigation = null;
    navigate?.call();
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _globalKey,
      backgroundColor: _loadFailed
          ? Theme.of(context).cardColor
          : (isDark ? ManagerColors.onPrimary : ManagerColors.primaryLight),
      body: _loadFailed
          ? Center(child: _buildNoInternetScreen())
          : DoghreeSplashAnimation(
              isLoading: _isLoading,
              onFinished: _onSplashAnimationFinished,
              frameSize: 300,        // عدّله بعد المقارنة مع الـ native
              // debugGeometry: true,   // للمعايرة مرة وحدة
            ),
    );
  }

  Widget _buildNoInternetScreen() {
    return NoInternetScreen(
      child: SplashScreen(body: widget.body),
    );
  }
}
