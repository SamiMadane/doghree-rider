import 'dart:async';
import 'dart:io';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/dashboard/widgets/lottie_bottom_sheet_order_request.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/disbursement/helper/disbursement_helper.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/task/screens/task_screen.dart';
import 'package:doghree_rider/helper/notification_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/main.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/common/widgets/custom_alert_dialog_widget.dart';
import 'package:doghree_rider/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:doghree_rider/features/home/screens/home_screen.dart';
import 'package:doghree_rider/features/profile/screens/profile_screen.dart';
import 'package:doghree_rider/features/order/screens/available_orders_screen.dart';
import 'package:doghree_rider/features/order/screens/order_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/session_checker.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromOrderDetails;
  const DashboardScreen(
      {super.key, required this.pageIndex, this.fromOrderDetails = false});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final _channel = const MethodChannel('com.sixamtech/app_retain');
  late StreamSubscription _stream;
  DisbursementHelper disbursementHelper = DisbursementHelper();
  bool _canExit = false;

  @override
  void initState() {
    super.initState();

    _pageIndex = widget.pageIndex;
    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      AvailableOrdersScreen(onTap: () => _setPage(0)),
      const OrderScreen(),
      TaskScreen(),
      const ProfileScreen(),
    ];

    showDisbursementWarningMessage();
    Get.find<OrderController>().getLatestOrders();
    // ✅ إضافة: بدء فحص الجلسة
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<SessionChecker>().startSessionCheck();
    }

    _stream = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String? type = message.data['body_loc_key'] ?? message.data['type'];
      String? orderID =
          message.data['title_loc_key'] ?? message.data['order_id'];
      bool isParcel = (message.data['order_type'] == 'parcel_order');
      if (type != 'assign' &&
          type != 'new_order' &&
          type != 'message' &&
          type != 'order_request' &&
          type != 'order_status') {
        NotificationHelper.showNotification(
            message, flutterLocalNotificationsPlugin);
      }
      if (type == 'new_order' || type == 'order_request') {
        Get.find<OrderController>().getCurrentOrders();
        Get.find<OrderController>().getLatestOrders();

        showCustomBottomSheet(
          child: LottieBottomSheetOrderRequest(
            isRequest: true,
            onAccept: () => _navigateRequestPage(),
            onReject: () {}, 
            orderId: int.parse(message.data['order_id'].toString()),
            isParcel: isParcel,
          ),
        );
      } else if (type == 'assign' && orderID != null && orderID.isNotEmpty) {
        Get.find<OrderController>().getCurrentOrders();
        Get.find<OrderController>().getLatestOrders();
        showCustomBottomSheet(
          child: LottieBottomSheetOrderRequest(
            isRequest: false,
            onAccept: () {
              Get.offAllNamed(RouteHelper.getOrderDetailsRoute(
                  int.parse(orderID),
                  fromNotification: true));
            },
            onReject: () {},
            orderId: int.parse(message.data['order_id'].toString()),
            isParcel: isParcel,
          ),
        );
      } else if (type == 'block') {
        Get.find<AuthController>().clearSharedData();
        Get.find<ProfileController>().stopLocationRecord();
        Get.offAllNamed(RouteHelper.getSignInRoute());
      }
    });
  }

  showDisbursementWarningMessage() async {
    if (!widget.fromOrderDetails) {
      disbursementHelper.enableDisbursementWarningMessage(true);
    }
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
    super.dispose();
    _stream.cancel();
    Get.find<SessionChecker>().stopSessionCheck();
  }

  @override
  Widget build(BuildContext context) {
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
                style: const TextStyle(color: Colors.white)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            margin: EdgeInsets.symmetric(horizontal:Dimensions.w10 ,vertical: Dimensions.h10,),
          ));
          _canExit = true;

          Timer(const Duration(seconds: 2), () {
            _canExit = false;
          });
        }
      },
      child: Scaffold(
        // إضافة resizeToAvoidBottomInset لمنع دفع Bottom Nav عند ظهور الكيبورد
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: GetPlatform.isDesktop
            ? const SizedBox()
            : SafeArea(
                // SafeArea لحماية Bottom Nav من الدخول تحت شاشة الجهاز
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                    ),
                    child: BottomAppBar(
                      elevation: 0,
                      height: 65, // ارتفاع ثابت مناسب
                      padding: EdgeInsets.zero,
                      color: Theme.of(context).cardColor,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            BottomNavItemWidget(
                              label: 'home'.tr,
                              isSelected: _pageIndex == 0,
                              onTap: () => _setPage(0),
                              selectedIcon: ManagerAssets.homeSelectedIcon,
                              unSelectedIcon: ManagerAssets.homeIcon,
                            ),
                            BottomNavItemWidget(
                              label: 'orders'.tr,
                              isSelected: _pageIndex == 1,
                              pageIndex: 1,
                              onTap: () {
                                _navigateRequestPage();
                              },
                              selectedIcon: ManagerAssets.orderSelectedIcon,
                              unSelectedIcon: ManagerAssets.orderIcon,
                            ),
                            BottomNavItemWidget(
                              label: 'my_orders'.tr,
                              isSelected: _pageIndex == 2,
                              onTap: () => _setPage(2),
                              selectedIcon: ManagerAssets.myOrderSelectedIcon,
                              unSelectedIcon: ManagerAssets.myOrderIcon,
                            ),
                            BottomNavItemWidget(
                              label: 'task'.tr,
                              isSelected: _pageIndex == 3,
                              onTap: () => _setPage(3),
                              selectedIcon: ManagerAssets.taskSelectedIcon,
                              unSelectedIcon: ManagerAssets.taskIcon,
                            ),
                            BottomNavItemWidget(
                              label: 'profile'.tr,
                              isSelected: _pageIndex == 4,
                              onTap: () => _setPage(4),
                              selectedIcon: ManagerAssets.profileSelectedIcon,
                              unSelectedIcon: ManagerAssets.userIcon,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }
}
