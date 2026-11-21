import 'dart:convert';
import 'package:doghree_rider/features/auth/screens/dm_registration_success_screen.dart';
import 'package:doghree_rider/features/wallet/screens/my_earning_screen.dart';
import 'package:doghree_rider/features/wallet/screens/wallet_screen.dart';
import 'package:doghree_rider/features/wallet/screens/withdrawals_screen.dart';
import 'package:doghree_rider/features/splash/screens/language_init_screen.dart';
import 'package:doghree_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:doghree_rider/features/chat/domain/models/conversation_model.dart';
import 'package:doghree_rider/features/auth/screens/sign_in_screen.dart';
import 'package:doghree_rider/features/auth/screens/dm_registration_screen.dart';
import 'package:doghree_rider/features/chat/screens/chat_screen.dart';
import 'package:doghree_rider/features/chat/screens/conversation_screen.dart';
import 'package:doghree_rider/features/dashboard/screens/dashboard_screen.dart';

import 'package:doghree_rider/features/forgot_password/screens/forget_pass_screen.dart';
import 'package:doghree_rider/features/forgot_password/screens/new_pass_screen.dart';
import 'package:doghree_rider/features/forgot_password/screens/verification_screen.dart';
import 'package:doghree_rider/features/html/screens/html_viewer_screen.dart';
import 'package:doghree_rider/features/language/screens/language_screen.dart';
import 'package:doghree_rider/features/notification/screens/notification_screen.dart';
import 'package:doghree_rider/features/order/screens/order_details_screen.dart';
import 'package:doghree_rider/features/order/screens/running_order_screen.dart';
import 'package:doghree_rider/features/profile/screens/setting_screen.dart';
import 'package:doghree_rider/features/profile/screens/update_profile_screen.dart';
import 'package:doghree_rider/features/splash/screens/splash_screen.dart';

import 'package:doghree_rider/features/update/screens/update_screen.dart';
import 'package:get/get.dart';

class RouteHelper {
  static const String initial = '/';
  static const String navigationHandler = '/navigation-handler';
  static const String signIn = '/sign-in';
  static const String verification = '/verification';
  static const String main = '/main';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String orderDetails = '/order-details';
  static const String updateProfile = '/update-profile';
  static const String notification = '/notification';
  static const String runningOrder = '/running-order';
  static const String terms = '/terms-and-condition';
  static const String privacy = '/privacy-policy';
  static const String language = '/language';
  static const String update = '/update';
  static const String chatScreen = '/chat-screen';
  static const String conversationListScreen = '/conversation-list-screen';
  static const String deliveryManRegistration = '/delivery-man-registration';

  static const String wallet = '/wallet';
  static const String myEarning = '/my-earning';
  static const String dmRegistrationSuccess = '/dm-registration-success';
  static const String taskScreen = '/task';
  static const String settingScreen = '/setting';
  static String languageInit = '/language-init';

  static const String withdrawals = '/withdrawals';

  static String getInitialRoute({bool? fromOrderDetails}) =>
      '$initial?from_order_details=${fromOrderDetails.toString()}';
  static String getNavigationHandlerRoute(NotificationBodyModel? body) {
    String data = 'null';
    if (body != null) {
      List<int> encoded = utf8.encode(jsonEncode(body.toJson()));
      data = base64Encode(encoded);
    }
    return '$navigationHandler?data=$data';
  }

  /// Builds `path?query` with every value URL-encoded, so `+`, `&` and `=`
  /// in a phone or code arrive intact (audit row 51). Null values are left out.
  static String _route(String path, Map<String, String?> params) {
    final Map<String, String> query = {
      for (final e in params.entries)
        if (e.value != null) e.key: e.value!,
    };
    return Uri(path: path, queryParameters: query.isEmpty ? null : query)
        .toString();
  }

  /// Decodes a base64 JSON route value. The encoding is unchanged (D-02
  /// note): the query turns `+` into a space, so it is put back first, and
  /// Dart's decoder reads both base64 alphabets. 'null', a missing value or a
  /// broken one gives null instead of a throw (rows 31, 34).
  static Map<String, dynamic>? _decodeJson(String? value) {
    if (value == null || value.isEmpty || value == 'null') return null;
    try {
      final dynamic json =
          jsonDecode(utf8.decode(base64.decode(value.replaceAll(' ', '+'))));
      return json is Map<String, dynamic> ? json : null;
    } catch (_) {
      return null;
    }
  }

  static NotificationBodyModel? _decodeBody(String? value) {
    final Map<String, dynamic>? json = _decodeJson(value);
    return json == null ? null : NotificationBodyModel.fromJson(json);
  }

  static String getSignInRoute() => signIn;
  static String getVerificationRoute(String number, {String? session}) {
    String? authSession;
    if (session != null) {
      authSession = base64Url.encode(utf8.encode(session));
    }
    return _route(verification, {'number': number, 'session': authSession});
  }

  static String getMainRoute(String page) => '$main?page=$page';
  static String getForgotPassRoute() => forgotPassword;
  static String getResetPasswordRoute(
          String? phone, String token, String page) =>
      _route(resetPassword, {'phone': phone, 'token': token, 'page': page});
  static String getOrderDetailsRoute(int? id,
          {bool? fromNotification, bool? fromLocationScreen}) =>
      '$orderDetails?id=$id&from=${fromNotification.toString()}&from_location_screen=${fromLocationScreen.toString()}';
  static String getUpdateProfileRoute() => updateProfile;
  static String getNotificationRoute({bool? fromNotification}) =>
      '$notification?from=${fromNotification.toString()}';
  static String getRunningOrderRoute() => runningOrder;
  static String getTermsRoute() => terms;
  static String getPrivacyRoute() => privacy;
  static String getLanguageRoute() => language;
  static String getUpdateRoute(bool isUpdate) =>
      '$update?update=${isUpdate.toString()}';
  static String getChatRoute(
      {required NotificationBodyModel? notificationBody,
      User? user,
      int? conversationId,
      bool? fromNotification}) {
    String notificationBody0 = 'null';
    String user0 = 'null';

    if (notificationBody != null) {
      notificationBody0 =
          base64Encode(utf8.encode(jsonEncode(notificationBody)));
    }
    if (user != null) {
      user0 = base64Encode(utf8.encode(jsonEncode(user.toJson())));
    }
    return '$chatScreen?notification_body=$notificationBody0&user=$user0&conversation_id=$conversationId&from=${fromNotification.toString()}';
  }

  static String getConversationListRoute() => conversationListScreen;
  static String getDeliverymanRegistrationRoute() => deliveryManRegistration;

  static String getWalletRoute() => wallet;
  static String getMyEarningRoute() => myEarning;
  static String getDmRegistrationSuccessRoute() => dmRegistrationSuccess;

  static String getTaskRoute() => taskScreen;
  static String getSettingRoute() => settingScreen;
  static String getLanguageInitRoute() => languageInit;
  static String getWithdrawalsRoute() => withdrawals;

  static List<GetPage> routes = [
    GetPage(name: languageInit, page: () => const LanguageInitScreen()),
    GetPage(
        name: initial,
        page: () => DashboardScreen(
              pageIndex: 0,
            )),
    GetPage(
        name: navigationHandler,
        page: () => SplashScreen(body: _decodeBody(Get.parameters['data']))),
    GetPage(name: signIn, page: () => const SignInScreen()),
    GetPage(
        name: verification,
        page: () {
          String? session;
          if (Get.parameters['session'] != null &&
              Get.parameters['session'] != 'null') {
            session =
                utf8.decode(base64Url.decode(Get.parameters['session'] ?? ''));
          }
          return VerificationScreen(
              number: Get.parameters['number'], firebaseSession: session);
        }),
    GetPage(
        name: main,
        page: () => DashboardScreen(
              pageIndex: Get.parameters['page'] == 'home'
                  ? 0
                  : Get.parameters['page'] == 'order-request'
                      ? 1
                      : Get.parameters['page'] == 'order'
                          ? 2
                          : Get.parameters['page'] == 'profile'
                              ? 3
                              : 0,
            )),
    GetPage(name: forgotPassword, page: () => const ForgetPassScreen()),
    GetPage(
        name: resetPassword,
        page: () => NewPassScreen(
              resetToken: Get.parameters['token'],
              number: Get.parameters['phone'],
              fromPasswordChange: Get.parameters['page'] == 'password-change',
            )),
    GetPage(
        name: orderDetails,
        page: () {
          final dynamic arguments = Get.arguments;
          if (arguments is OrderDetailsScreen) return arguments;
          // A missing or bad id opens My Orders instead of throwing (row 31).
          final int? id = int.tryParse(Get.parameters['id'] ?? '');
          if (id == null) return const DashboardScreen(pageIndex: 2);
          return OrderDetailsScreen(
            fromNotification: Get.parameters['from'] == 'true',
            isRunningOrder: null,
            orderId: id,
            fromLocationScreen:
                Get.parameters['from_location_screen'] == 'true',
          );
        }),
    GetPage(name: updateProfile, page: () => const UpdateProfileScreen()),
    GetPage(
        name: notification,
        page: () => NotificationScreen(
            fromNotification: Get.parameters['from'] == 'true')),
    GetPage(name: runningOrder, page: () => const RunningOrderScreen()),
    GetPage(
        name: terms,
        page: () => const HtmlViewerScreen(isPrivacyPolicy: false)),
    GetPage(
        name: privacy,
        page: () => const HtmlViewerScreen(isPrivacyPolicy: true)),
    GetPage(name: language, page: () => const ChooseLanguageScreen()),
    GetPage(
        name: update,
        page: () => UpdateScreen(isUpdate: Get.parameters['update'] == 'true')),
    GetPage(
        name: chatScreen,
        page: () {
          final NotificationBodyModel? notificationBody =
              _decodeBody(Get.parameters['notification_body']);
          User? user;
          final Map<String, dynamic>? userJson =
              _decodeJson(Get.parameters['user']);
          if (userJson != null) {
            try {
              user = User.fromJson(userJson);
            } catch (_) {
              user = null;
            }
          }
          // ChatScreen needs a body; without one the list is the safe screen.
          if (notificationBody == null) return const ConversationScreen();
          return ChatScreen(
            notificationBody: notificationBody,
            user: user,
            fromNotification: Get.parameters['from'] == 'true',
            // A non-numeric id is null, never a throw (row 34).
            conversationId:
                int.tryParse(Get.parameters['conversation_id'] ?? ''),
          );
        }),
    GetPage(
        name: conversationListScreen, page: () => const ConversationScreen()),
    GetPage(
        name: deliveryManRegistration,
        page: () => const DmRegistrationScreen()),
    GetPage(name: wallet, page: () => const WalletScreen()),
    GetPage(name: myEarning, page: () => const MyEarningScreen()),
    GetPage(
        name: dmRegistrationSuccess,
        page: () => const DmRegistrationSuccessScreen()),
    GetPage(name: settingScreen, page: () => const SettingScreen()),
    GetPage(name: withdrawals, page: () => const WithdrawalsScreen()),
  ];
}
