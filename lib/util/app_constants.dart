import 'package:get/get.dart';
import 'package:doghree_rider/features/language/domain/models/language_model.dart';
import 'package:doghree_rider/util/manager_assets.dart';

class AppConstants {
  static const String appName = 'Doghree Rider';
  static const double appVersion = 3.3;

  ///Flutter sdk 3.32.8

  static const String baseUrl = 'https://doghree.com';
  static String get fontFamily {
    return (Get.locale?.languageCode ==
                AppConstants.languages[1].languageCode ||
            Get.locale?.languageCode == 'ar')
        ? 'Tajawal'
        : 'Roboto';
  }

  static const String configUri = '/api/v1/config';
  static const String directionUri = '/api/v1/config/direction-api';
  static const String walletAccountsUri =
      '/api/v1/delivery-man/wallet/accounts';
  static const String walletWithdrawUri =
      '/api/v1/delivery-man/wallet/withdraw';
  static const String walletWithdrawalsUri =
      '/api/v1/delivery-man/wallet/withdrawals';
  static const String forgetPasswordUri =
      '/api/v1/auth/delivery-man/forgot-password';
  static const String walletUri = '/api/v1/delivery-man/wallet';
  static const String verifyTokenUri = '/api/v1/auth/delivery-man/verify-token';
  static const String resetPasswordUri =
      '/api/v1/auth/delivery-man/reset-password';
  static const String loginUri = '/api/v1/auth/delivery-man/login';
  static const String tokenUri = '/api/v1/delivery-man/update-fcm-token';
  static const String currentOrdersUri =
      '/api/v1/delivery-man/current-orders?token=';
  static const String allOrdersUri = '/api/v1/delivery-man/all-orders';
  static const String latestOrdersUri =
      '/api/v1/delivery-man/latest-orders?token=';
  static const String recordLocationUri =
      '/api/v1/delivery-man/record-location-data';
  static const String profileUri = '/api/v1/delivery-man/profile?token=';
  static const String updateOrderStatusUri =
      '/api/v1/delivery-man/update-order-status';
  static const String updatePaymentStatusUri =
      '/api/v1/delivery-man/update-payment-status';
  static const String orderDetailsUri =
      '/api/v1/delivery-man/order-details?token=';
  static const String acceptOrderUri = '/api/v1/delivery-man/accept-order';
  static const String activeStatusUri =
      '/api/v1/delivery-man/update-active-status';
  static const String updateProfileUri = '/api/v1/delivery-man/update-profile';
  static const String notificationUri = '/api/v1/delivery-man/notifications';

  static const String markNotificationReadUri =
      '/api/v1/delivery-man/notifications/mark-read';
  static const String markAllNotificationsReadUri =
      '/api/v1/delivery-man/notifications/mark-all-read';
  static const String aboutUsUri = '/api/v1/about-us';
  static const String privacyPolicyUri = '/api/v1/privacy-policy';
  static const String tramsAndConditionUri = '/api/v1/terms-and-conditions';
  static const String driverRemoveUri =
      '/api/v1/delivery-man/remove-account?token=';
  static const String dmRegisterUri = '/api/v1/auth/delivery-man/store';
  static const String zoneListUri = '/api/v1/zone/list';
  static const String zoneUri = '/api/v1/config/get-zone-id';
  static const String currentOrderUri = '/api/v1/delivery-man/order?token=';
  static const String vehiclesUri = '/api/v1/get-vehicles';
  static const String orderCancellationUri =
      '/api/v1/customer/order/cancellation-reasons';
  static const String deliveredOrderNotificationUri =
      '/api/v1/delivery-man/send-order-otp';
  static const String addWithdrawMethodUri =
      '/api/v1/delivery-man/withdraw-method/store';
  static const String disbursementMethodListUri =
      '/api/v1/delivery-man/withdraw-method/list';
  static const String makeDefaultDisbursementMethodUri =
      '/api/v1/delivery-man/withdraw-method/make-default';
  static const String deleteDisbursementMethodUri =
      '/api/v1/delivery-man/withdraw-method/delete';
  static const String getDisbursementReportUri =
      '/api/v1/delivery-man/get-disbursement-report';
  static const String withdrawRequestMethodUri =
      '/api/v1/delivery-man/get-withdraw-method-list';
  static const String makeCollectedCashPaymentUri =
      '/api/v1/delivery-man/make-collected-cash-payment';
  static const String walletPaymentListUri =
      '/api/v1/delivery-man/wallet-payment-list';
  static const String makeWalletAdjustmentUri =
      '/api/v1/delivery-man/make-wallet-adjustment';
  static const String walletProvidedEarningListUri =
      '/api/v1/delivery-man/wallet-provided-earning-list';
  static const String firebaseAuthVerify =
      '/api/v1/auth/delivery-man/firebase-verify-token';
  static const String earningReportUri = '/api/v1/delivery-man/earning-report';
  static const String earningReportInvoiceUri =
      '/deliveryman-earning-report-invoice';

  ///chat url
  static const String getConversationListUri =
      '/api/v1/delivery-man/message/list';
  static const String getMessageListUri =
      '/api/v1/delivery-man/message/details';
  static const String sendMessageUri = '/api/v1/delivery-man/message/send';
  static const String searchConversationListUri =
      '/api/v1/delivery-man/message/search-list';

  /// Shared Key
  static const String theme = 'doghree_rider_theme';
  static const String token = 'doghree_rider_token';
  static const String countryCode = 'doghree_rider_country_code';
  static const String languageCode = 'doghree_rider_language_code';
  static const String cacheCountryCode = 'cache_country_code';
  static const String cacheLanguageCode = 'cache_language_code';
  static const String userPassword = 'doghree_rider_user_password';
  static const String userAddress = 'doghree_rider_user_address';
  static const String userNumber = 'doghree_rider_user_number';
  static const String userCountryDialCode =
      'doghree_rider_user_country_dial_code';
  static const String userCountryCode = 'doghree_rider_user_country_code';
  static const String notification = 'doghree_rider_notification';
  static const String notificationCount = 'doghree_rider_notification_count';
  static const String ignoreList = 'doghree_rider_ignore_list';
  static const String topic = 'all_zone_delivery_man';
  static const String zoneTopic = 'zone_topic';
  static const String vehicleWiseTopic = 'vehicle_wise_topic';
  static const String localizationKey = 'X-localization';
  static const String langIntro = 'language_intro';
  static const String notificationIdList = 'notification_id_list';
  static const String logoutReason = 'logout_reason';

  /// Order Status
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String accepted = 'accepted';
  static const String processing = 'processing';
  static const String handover = 'handover';
  static const String pickedUp = 'picked_up';
  static const String delivered = 'delivered';
  static const String canceled = 'canceled';
  static const String failed = 'failed';
  static const String refunded = 'refunded';

  ///user type..
  static const String user = 'user';
  static const String customer = 'customer';
  static const String deliveryMan = 'delivery_man';
  static const String vendor = 'vendor';

  static const bool allowDmTypeSelection = false;

  static List<LanguageModel> languages = [
    LanguageModel(
        imageUrl: ManagerAssets.english,
        languageName: 'English',
        countryCode: 'US',
        languageCode: 'en'),
    LanguageModel(
        imageUrl: ManagerAssets.arabic,
        languageName: 'العربية',
        countryCode: 'SA',
        languageCode: 'ar'),
  ];
}
