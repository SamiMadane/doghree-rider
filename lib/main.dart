import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/language/controllers/language_controller.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/common/controllers/theme_controller.dart';
import 'package:doghree_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:doghree_rider/helper/date_converter_helper.dart';
import 'package:doghree_rider/helper/location_permission_manager.dart';
import 'package:doghree_rider/helper/notification_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/theme/dark_theme.dart';
import 'package:doghree_rider/theme/light_theme.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:doghree_rider/util/messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';
import 'helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
late List<CameraDescription> cameras;

Future<void> main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  if (GetPlatform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA9r4E873RMreR9D-60tDHjz9No57fAbNk",
        appId: "1:696479427007:android:5c22bd1037d746be0cd90a",
        messagingSenderId: "696479427007",
        projectId: "serious-venture-434014-q3",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  Map<String, Map<String, String>> languages = await di.init();

  NotificationBodyModel? body;
  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  } catch (_) {}

  await DateConverterHelper.initLocaleDateFormatting();
  Get.put(LocationPermissionManager(), permanent: true);

  cameras = await availableCameras();
  runApp(MyApp(languages: languages, body: body));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  const MyApp({super.key, required this.languages, this.body});

  void _route() {
    Get.find<SplashController>().getConfigData().then((bool isSuccess) async {
      if (isSuccess) {
        if (Get.find<AuthController>().isLoggedIn()) {
          Get.find<AuthController>().updateToken();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();
      _route();
    }

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return ScreenUtilInit(
      designSize: const Size(376, 812), // ✅ نفس اليوزر
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetBuilder<ThemeController>(builder: (themeController) {
          return GetBuilder<LocalizationController>(
              builder: (localizeController) {
            return GetBuilder<SplashController>(builder: (splashController) {
              return (GetPlatform.isWeb && splashController.configModel == null)
                  ? const SizedBox()
                  : GetMaterialApp(
                      title: AppConstants.appName,
                      debugShowCheckedModeBanner: false,
                      navigatorKey: Get.key,
                      theme: themeController.darkTheme ? dark : light,
                      locale: localizeController.locale,
                      translations: Messages(languages: languages),
                      fallbackLocale: Locale(
                          AppConstants.languages[0].languageCode!,
                          AppConstants.languages[0].countryCode),
                      initialRoute: Get.find<LocalizationController>()
                                  .selectedLanguageIndex ==
                              -1
                          ? RouteHelper.getLanguageInitRoute()
                          : RouteHelper.getNavigationHandlerRoute(body),
                      getPages: RouteHelper.routes,
                      defaultTransition: Transition.topLevel,
                      transitionDuration: const Duration(milliseconds: 500),
                      builder: (BuildContext context, widget) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                              textScaler: const TextScaler.linear(1.0)),
                          child: Material(
                            child: SafeArea(
                              top: false,
                              bottom: GetPlatform.isAndroid,
                              child: Stack(
                                children: [
                                  widget!,
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
            });
          });
        });
      },
    );
  }
}
