import 'dart:convert';
import 'package:wefrh_rider/features/auth/screens/dm_registration_success_screen.dart';
import 'package:wefrh_rider/features/cash_in_hand/screens/my_earning_filter_screen.dart';
import 'package:wefrh_rider/features/cash_in_hand/screens/my_earning_screen.dart';
import 'package:wefrh_rider/features/cash_in_hand/screens/withdrawals_screen.dart';
import 'package:wefrh_rider/features/splash/screens/language_init_screen.dart';
import 'package:wefrh_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:wefrh_rider/features/chat/domain/models/conversation_model.dart';
import 'package:wefrh_rider/features/auth/screens/sign_in_screen.dart';
import 'package:wefrh_rider/features/auth/screens/dm_registration_screen.dart';
import 'package:wefrh_rider/features/cash_in_hand/screens/cash_in_hand_screen.dart';
import 'package:wefrh_rider/features/cash_in_hand/screens/transaction_history_screen.dart';
import 'package:wefrh_rider/features/cash_in_hand/screens/wallet_provided_earning_history_screen.dart';
import 'package:wefrh_rider/features/cash_in_hand/screens/payment_screen.dart';
import 'package:wefrh_rider/features/cash_in_hand/widgets/payment_successful_widget.dart';
import 'package:wefrh_rider/features/chat/screens/chat_screen.dart';
import 'package:wefrh_rider/features/chat/screens/conversation_screen.dart';
import 'package:wefrh_rider/features/dashboard/screens/dashboard_screen.dart';
import 'package:wefrh_rider/features/disbursement/screens/add_withdraw_method_screen.dart';
import 'package:wefrh_rider/features/disbursement/screens/disbursement_screen.dart';
import 'package:wefrh_rider/features/disbursement/screens/withdraw_method_screen.dart';
import 'package:wefrh_rider/features/forgot_password/screens/forget_pass_screen.dart';
import 'package:wefrh_rider/features/forgot_password/screens/new_pass_screen.dart';
import 'package:wefrh_rider/features/forgot_password/screens/verification_screen.dart';
import 'package:wefrh_rider/features/html/screens/html_viewer_screen.dart';
import 'package:wefrh_rider/features/language/screens/language_screen.dart';
import 'package:wefrh_rider/features/notification/screens/notification_screen.dart';
import 'package:wefrh_rider/features/order/screens/order_details_screen.dart';
import 'package:wefrh_rider/features/order/screens/running_order_screen.dart';
import 'package:wefrh_rider/features/profile/screens/setting_screen.dart';
import 'package:wefrh_rider/features/profile/screens/update_profile_screen.dart';
import 'package:wefrh_rider/features/splash/screens/splash_screen.dart';
import 'package:wefrh_rider/features/task/screens/capture_id_screen.dart';
import 'package:wefrh_rider/features/task/screens/client_screen.dart';
import 'package:wefrh_rider/features/task/screens/operation_history_screen.dart';
import 'package:wefrh_rider/features/task/screens/details_statistics_screen.dart';
import 'package:wefrh_rider/features/task/screens/finish_shift_screen.dart';
import 'package:wefrh_rider/features/task/screens/preview_id_screen.dart';
import 'package:wefrh_rider/features/task/screens/support_team_screen.dart';
import 'package:wefrh_rider/features/update/screens/update_screen.dart';
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
  static const String disbursement = '/disbursement';
  static const String withdrawMethod = '/withdraw-method';
  static const String addWithdrawMethod = '/add-withdraw-method';
  static const String success = '/success';
  static const String payment = '/payment';
  static const String transactionHistory = '/transaction-history';
  static const String cashInHand = '/cash-in-hand';
  static const String walletProvidedEarning = '/wallet-provided-earning';
  static const String myEarning = '/my-earning';
  static const String myEarningFilter = '/my-earning-filter';
  static const String dmRegistrationSuccess = '/dm-registration-success';
  static const String taskScreen = '/task';
  static const String settingScreen = '/setting';
  static String languageInit = '/language-init';
  static const String detailsStatistics = '/details-statistics';
  static const String clientScreen = '/client-screen';
  static const String supportTeamScreen = '/support-team-screen';
  static const String finishShiftScreen = '/finish-shift-screen';
  static const String captureIdScreen = '/capture-id-screen';
  static const String previewIdScreen = '/preview-id-screen';
  static const String detailedOperationHistoryScreen = '/detailed-operation-history-screen';
  static const String withdrawals = '/withdrawals';


  static String getDetailedOperationHistoryRoute() => detailedOperationHistoryScreen;
  static String getDetailsStatisticsRoute() => detailsStatistics;
  static String getClientScreenRoute() => clientScreen;
  static String getCaptureIdRoute() => captureIdScreen;
  static String getPreviewIdRoute() => previewIdScreen;
  static String getSupportTeamRoute() => supportTeamScreen;
  static String getFinishShiftRoute() => finishShiftScreen;

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

  static String getSignInRoute() => signIn;
  static String getVerificationRoute(String number, {String? session}) {
    String? authSession;
    if (session != null) {
      authSession = base64Url.encode(utf8.encode(session));
    }
    return '$verification?number=$number&session=$authSession';
  }

  static String getMainRoute(String page) => '$main?page=$page';
  static String getForgotPassRoute() => forgotPassword;
  static String getResetPasswordRoute(
          String? phone, String token, String page) =>
      '$resetPassword?phone=$phone&token=$token&page=$page';
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
  static String getDisbursementRoute() => disbursement;
  static String getWithdrawMethodRoute({bool isFromDashBoard = false}) =>
      '$withdrawMethod?is_from_dashboard=${isFromDashBoard.toString()}';
  static String getAddWithdrawMethodRoute() => addWithdrawMethod;
  static String getSuccessRoute(String status) => '$success?status=$status';
  static String getPaymentRoute(String? redirectUrl) {
    return '$payment?redirect-url=$redirectUrl';
  }

  static String getTransactionHistoryRoute() => transactionHistory;
  static String getCashInHandRoute() => cashInHand;
  static String getWalletProvidedEarningRoute() => walletProvidedEarning;
  static String getMyEarningRoute() => myEarning;
  static String getMyEarningFilterRoute() => myEarningFilter;
  static String getDmRegistrationSuccessRoute() => dmRegistrationSuccess;

  static String getTaskRoute() => taskScreen;
  static String getSettingRoute() => settingScreen;
  static String getLanguageInitRoute() => languageInit;
  static String getWithdrawalsRoute() => withdrawals;


  static List<GetPage> routes = [
    GetPage(
        name: detailsStatistics, page: () => const DetailsStatisticsScreen()),
        
    GetPage(name: detailedOperationHistoryScreen, page: () => const DetailedOperationHistoryScreen()),
    GetPage(name: clientScreen, page: () => const ClientScreen()),
    GetPage(name: captureIdScreen, page: () => CaptureIdScreen()),
    GetPage(
      name: previewIdScreen,
      page: () => PreviewIdScreen(image: Get.arguments),
    ),
    GetPage(name: supportTeamScreen, page: () => const SupportTeamScreen()),
    GetPage(name: finishShiftScreen, page: () => const FinishShiftScreen()),
    GetPage(name: languageInit, page: () => const LanguageInitScreen()),
    GetPage(
        name: initial,
        page: () => DashboardScreen(
            pageIndex: 0,
            fromOrderDetails: Get.parameters['from_order_details'] == 'true')),
    GetPage(
        name: navigationHandler,
        page: () {
          NotificationBodyModel? data;
          if (Get.parameters['data'] != 'null') {
            List<int> decode =
                base64Decode(Get.parameters['data']!.replaceAll(' ', '+'));
            data =
                NotificationBodyModel.fromJson(jsonDecode(utf8.decode(decode)));
          }
          return SplashScreen(body: data);
        }),
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
          OrderDetailsScreen? orderDetails = Get.arguments;
          return orderDetails ??
              OrderDetailsScreen(
                fromNotification: Get.parameters['from'] == 'true',
                isRunningOrder: null,
                orderIndex: null,
                orderId: int.parse(Get.parameters['id']!),
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
          NotificationBodyModel? notificationBody;
          if (Get.parameters['notification_body'] != 'null') {
            notificationBody = NotificationBodyModel.fromJson(jsonDecode(utf8
                .decode(base64Url.decode(Get.parameters['notification_body']!
                    .replaceAll(' ', '+')))));
          }
          User? user;
          if (Get.parameters['user'] != 'null') {
            user = User.fromJson(jsonDecode(utf8.decode(base64Url
                .decode(Get.parameters['user']!.replaceAll(' ', '+')))));
          }
          return ChatScreen(
            notificationBody: notificationBody,
            user: user,
            fromNotification: Get.parameters['from'] == 'true',
            conversationId: Get.parameters['conversation_id'] != null &&
                    Get.parameters['conversation_id'] != 'null'
                ? int.parse(Get.parameters['conversation_id']!)
                : null,
          );
        }),
    GetPage(
        name: conversationListScreen, page: () => const ConversationScreen()),
    GetPage(
        name: deliveryManRegistration,
        page: () => const DmRegistrationScreen()),
    GetPage(name: disbursement, page: () => const DisbursementScreen()),
    GetPage(
        name: withdrawMethod,
        page: () => WithdrawMethodScreen(
            isFromDashboard: Get.parameters['is_from_dashboard'] == 'true')),
    GetPage(
        name: addWithdrawMethod, page: () => const AddWithDrawMethodScreen()),
    GetPage(
        name: success,
        page: () => PaymentSuccessfulWidget(
            success: Get.parameters['status'] == 'success')),
    GetPage(
        name: payment,
        page: () {
          String walletPayment = Get.parameters['redirect-url']!;
          return PaymentScreen(redirectUrl: walletPayment);
        }),
    GetPage(
        name: transactionHistory, page: () => const TransactionHistoryScreen()),
    GetPage(name: cashInHand, page: () => const CashInHandScreen()),
    GetPage(
        name: walletProvidedEarning,
        page: () => const WalletProvidedHistoryScreen()),
    GetPage(name: myEarning, page: () => const MyEarningScreen()),
    GetPage(name: myEarningFilter, page: () => const MyEarningFilterScreen()),
    GetPage(
        name: dmRegistrationSuccess,
        page: () => const DmRegistrationSuccessScreen()),
    GetPage(name: settingScreen, page: () => const SettingScreen()),
    GetPage(name: withdrawals, page: () => const WithdrawalsScreen()),
  ];
}
