import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixam_mart_delivery/features/language/controllers/language_controller.dart';
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

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Get.find<NavigationHandlerController>().initSharedData();

    // تحقق من اللغة
    final localizationController = Get.find<LocalizationController>();
    print(
        'localizationController.selectedLanguageIndex = ${localizationController.selectedLanguageIndex}');

    // إذا المستخدم مسجل دخول
    if (Get.find<AuthController>().isLoggedIn()) {
      await Get.find<ProfileController>().getProfile();
    }

    // بدء مراقبة الاتصال
    _listenConnectivity();

    // تحميل Config
    _loadConfig();
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
        child: _loadFailed ? _buildErrorWidget() : _buildLoadingWidget(),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.p20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 50),
          Image.asset(
            ManagerAssets.logo,
          ),
          const SizedBox(height: Dimensions.p10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "delivery".tr,
                style: robotoSemiBold.copyWith(
                  fontSize: Dimensions.fs16,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              const SizedBox(width: Dimensions.p4),
              LoadingDots(
                  color: Theme.of(context).textTheme.bodyMedium!.color!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  ManagerAssets.deliveryLottie,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: Dimensions.p25),

                Text(
                  "no_connection".tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fs24,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Dimensions.p10),
                Text(
                  "please_check_your_internet_and_try_again".tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fs18,
                    color: Theme.of(context).disabledColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        // زر retry ثابت بأسفل الصفحة
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: CustomButtonWidget(
            onPressed: () {
              _loadConfig();
            },
            buttonText: "retry".tr,
          ),
        ),
      ],
    );
  }
}
