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
import 'package:doghree_rider/features/profile/domain/models/profile_result_model.dart';
import 'package:doghree_rider/features/splash/domain/models/splash_load_guard.dart';
import 'package:doghree_rider/features/splash/widgets/doghree_splash_animation.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:flutter/foundation.dart';
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
  final SplashLoadGuard _guard = SplashLoadGuard();

  @override
  void initState() {
    super.initState();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Get.find<SplashController>().initSharedData();

    // Finishes a logout whose FCM cleanup failed offline. Silent, not awaited:
    // updateToken waits for it before asking FCM for a token.
    Get.find<AuthController>().retryPendingPushCleanup();

    Get.find<LocalizationController>();

    _listenConnectivity();
    _loadConfig();
  }

  /// One profile request. Only a real 401 ends the session; offline,
  /// timeout and server errors leave the session untouched.
  Future<SessionStatus> _validateSession() async {
    try {
      return await Get.find<ProfileController>()
          .getProfile(isFromSplash: true);
    } catch (e) {
      if (kDebugMode) debugPrint('Splash session check failed: ${e.runtimeType}');
      return SessionStatus.unverified;
    }
  }

  /// Ends the session for real. Every step is guarded so navigation to
  /// sign-in always happens, with no toast.
  Future<void> _endSession() async {
    try {
      await Get.find<AuthController>().clearSharedData();
    } catch (e) {
      if (kDebugMode) debugPrint('clearSharedData failed: ${e.runtimeType}');
    }
    try {
      Get.find<ProfileController>().stopLocationRecord();
    } catch (e) {
      if (kDebugMode) debugPrint('stopLocationRecord failed: ${e.runtimeType}');
    }
    try {
      await Get.find<AuthController>().setLogoutReason('session_expired');
    } catch (e) {
      if (kDebugMode) debugPrint('setLogoutReason failed: ${e.runtimeType}');
    }
  }

  /// Only job: retry silently when the connection comes back after a failed
  /// load. Feedback is the compact NoInternetScreen, never a bar or toast.
  void _listenConnectivity() {
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (!mounted) return;

      bool isConnected = result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);

      if (isConnected && _loadFailed) {
        _loadConfig();
      }
    });
  }

  @override
  void dispose() {
    _onConnectivityChanged?.cancel();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    if (_pendingNavigation != null || !_guard.tryStartLoad()) return;
    try {
      setState(() {
        _loadFailed = false;
        _isLoading = true;
      });

      bool success = await Get.find<SplashController>().getConfigData();
      if (!mounted) return;

      if (success) {
        await _route();
      } else {
        _showLoadFailed();
      }
    } finally {
      _guard.endLoad();
    }
  }

  void _showLoadFailed() {
    if (!mounted) return;
    setState(() {
      _loadFailed = true;
      _isLoading = false;
    });
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
      final SessionStatus status = await _validateSession();
      if (!mounted) return;

      if (status == SessionStatus.expired) {
        // الجلسة منتهية فعلاً (401): مسح الجلسة ثم تسجيل الدخول بدون Dialog
        await _endSession();
        if (!mounted) return;
        _finishLoading(() {
          ApiChecker.resetDialogState();
          Get.offAllNamed(RouteHelper.getSignInRoute());
        });
        return;
      }

      if (status != SessionStatus.valid) {
        // لا إنترنت / مهلة / خطأ خادم: الجلسة تبقى كما هي، شاشة Retry
        _showLoadFailed();
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
    if (navigate != null && _guard.tryNavigate()) {
      navigate();
    }
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
      NotificationType.otp: () {},
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
      // البروفايل محمّل مسبقاً في _validateSession (وHomeScreen يحدّثه)
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
              frameSize: Dimensions.w300, // عدّله بعد المقارنة مع الـ native
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
