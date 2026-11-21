import 'dart:async';
import 'dart:io';
import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/dashboard/widgets/dashboard_bottom_nav_widget.dart';
import 'package:doghree_rider/features/dashboard/widgets/lottie_bottom_sheet_order_request.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/helper/notification_router.dart';
import 'package:doghree_rider/helper/order_ringing.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/common/widgets/custom_alert_dialog_widget.dart';
import 'package:doghree_rider/features/home/screens/home_screen.dart';
import 'package:doghree_rider/features/profile/screens/profile_screen.dart';
import 'package:doghree_rider/features/order/screens/available_orders_screen.dart';
import 'package:doghree_rider/features/order/screens/order_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/util/session_checker.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  const DashboardScreen({super.key, required this.pageIndex});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final _channel = const MethodChannel('com.sixamtech/app_retain');
  late StreamSubscription _stream;
  bool _canExit = false;
  bool _isBlocking = false;

  @override
  void initState() {
    super.initState();

    // The rider is looking at the app (or at the requests): no ringing.
    OrderRinging.stop();

    _pageIndex = widget.pageIndex;
    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      AvailableOrdersScreen(onTap: () => _setPage(0)),
      const OrderScreen(),
      const ProfileScreen(),
    ];

    Get.find<OrderController>().getLatestOrders();
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<SessionChecker>().startSessionCheck();
    }

    _stream = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Never throws: a missing or bad order_id is null (audit row 32).
      final ForegroundOrderPush push =
          ForegroundOrderPush.fromData(message.data);
      final int? orderId = push.orderId;

      switch (push.kind) {
        case ForegroundPushKind.request:
        case ForegroundPushKind.assign:
          // Always refresh the lists. The sheet needs a real id.
          Get.find<OrderController>().getCurrentOrders();
          Get.find<OrderController>().getLatestOrders();
          if (orderId == null) return;
          final bool isRequest = push.kind == ForegroundPushKind.request;
          showCustomBottomSheet(
            child: LottieBottomSheetOrderRequest(
              isRequest: isRequest,
              onAccept: isRequest
                  ? () => _navigateRequestPage()
                  : () => Get.offAllNamed(RouteHelper.getOrderDetailsRoute(
                      orderId,
                      fromNotification: true)),
              onReject: () {},
              orderId: orderId,
              isParcel: push.isParcel,
            ),
          );
          break;
        case ForegroundPushKind.block:
          _handleBlock();
          break;
        case ForegroundPushKind.other:
          break;
      }
    });
  }

  /// The session and the FCM cleanup finish before sign-in opens, so a quick
  /// re-login cannot race the old unsubscribes.
  Future<void> _handleBlock() async {
    if (_isBlocking) return;
    _isBlocking = true;
    ApiChecker.isLoggingOut = true;
    Get.find<ProfileController>().stopLocationRecord();
    try {
      await Get.find<AuthController>().clearSharedData();
    } catch (e) {
      if (kDebugMode) debugPrint('block cleanup failed: ${e.runtimeType}');
    }
    Get.offAllNamed(RouteHelper.getSignInRoute());
  }

  void _navigateRequestPage() {
    if (Get.find<ProfileController>().profileModel != null &&
        Get.find<ProfileController>().profileModel!.active == 1 &&
        Get.find<OrderController>().currentOrderList != null &&
        Get.find<OrderController>().currentOrderList!.isEmpty) {
      _setPage(1);
    } else {
      if (Get.find<ProfileController>().profileModel == null ||
          Get.find<ProfileController>().profileModel!.active == 0) {
        Get.dialog(CustomAlertDialogWidget(
            description: 'you_are_offline_now'.tr,
            onOkPressed: () => Get.back()));
      } else {
        _setPage(1);
      }
    }
  }

  @override
  void dispose() {
    _stream.cancel();
    Get.find<SessionChecker>().stopSessionCheck();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (_pageIndex != 0) {
          _setPage(0);
        } else {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              if (Get.find<ProfileController>().profileModel!.active == 1) {
                _channel.invokeMethod('sendToBackground');
              }
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('back_press_again_to_exit'.tr,
                style: TextStyle(color: cs.surface)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: cs.onSurface,
            duration: const Duration(seconds: 2),
            margin: EdgeInsets.symmetric(
                horizontal: Dimensions.w10, vertical: Dimensions.h10),
          ));
          _canExit = true;

          Timer(const Duration(seconds: 2), () {
            _canExit = false;
          });
        }
      },
      child: Scaffold(
        // ← التعديل الوحيد: نفس لون الصفحات، فيختفي الشريط البيج حول الـ nav
        backgroundColor: theme.cardColor,
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: GetPlatform.isDesktop
            ? const SizedBox()
            : DashboardBottomNavWidget(
                pageIndex: _pageIndex,
                itemCount: _screens.length,
                onTap: (int index) =>
                    index == 1 ? _navigateRequestPage() : _setPage(index),
              ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => _screens[index],
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    if (pageIndex == 1) OrderRinging.stop();
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }
}