import 'package:doghree_rider/features/address/domain/services/address_service.dart';
import 'package:doghree_rider/features/address/domain/services/address_service_interface.dart';
import 'package:doghree_rider/features/auth/domain/services/auth_service.dart';
import 'package:doghree_rider/features/auth/domain/services/auth_service_interface.dart';
import 'package:doghree_rider/features/chat/domain/services/chat_service.dart';
import 'package:doghree_rider/features/chat/domain/services/chat_service_interface.dart';
import 'package:doghree_rider/features/forgot_password/domain/services/forgot_password_service.dart';
import 'package:doghree_rider/features/forgot_password/domain/services/forgot_password_service_interface.dart';
import 'package:doghree_rider/features/html/domain/services/html_service.dart';
import 'package:doghree_rider/features/html/domain/services/html_service_interface.dart';
import 'package:doghree_rider/features/language/domain/services/language_service.dart';
import 'package:doghree_rider/features/language/domain/services/language_service_interface.dart';
import 'package:doghree_rider/features/notification/domain/services/notification_service.dart';
import 'package:doghree_rider/features/notification/domain/services/notification_service_interface.dart';
import 'package:doghree_rider/features/order/domain/services/order_service.dart';
import 'package:doghree_rider/features/order/domain/services/order_service_interface.dart';
import 'package:doghree_rider/features/profile/domain/services/profile_service.dart';
import 'package:doghree_rider/features/profile/domain/services/profile_service_interface.dart';
import 'package:doghree_rider/features/splash/domain/services/splash_service.dart';
import 'package:doghree_rider/features/splash/domain/services/splash_service_interface.dart';
import 'package:doghree_rider/features/wallet/domain/services/wallet_service.dart';
import 'package:doghree_rider/features/wallet/domain/services/wallet_service_interface.dart';
import 'package:doghree_rider/helper/get_di.dart' as di;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Audit row 55: each service is registered once, as its interface.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, Map<String, String>> languages;

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    languages = await di.init();
  });

  tearDown(Get.reset);

  test('T1: no concrete service type is registered a second time', () {
    final Map<String, bool> concrete = {
      'HtmlService': Get.isRegistered<HtmlService>(),
      'WalletService': Get.isRegistered<WalletService>(),
      'ForgotPasswordService': Get.isRegistered<ForgotPasswordService>(),
      'ChatService': Get.isRegistered<ChatService>(),
      'LanguageService': Get.isRegistered<LanguageService>(),
      'SplashService': Get.isRegistered<SplashService>(),
      'NotificationService': Get.isRegistered<NotificationService>(),
      'ProfileService': Get.isRegistered<ProfileService>(),
      'AddressService': Get.isRegistered<AddressService>(),
      'AuthService': Get.isRegistered<AuthService>(),
      'OrderService': Get.isRegistered<OrderService>(),
    };
    expect(concrete.entries.where((e) => e.value).map((e) => e.key).toList(),
        isEmpty);
  });

  test('G1: every service interface resolves to its implementation', () {
    expect(Get.find<HtmlServiceInterface>(), isA<HtmlService>());
    expect(Get.find<WalletServiceInterface>(), isA<WalletService>());
    expect(Get.find<ForgotPasswordServiceInterface>(),
        isA<ForgotPasswordService>());
    expect(Get.find<ChatServiceInterface>(), isA<ChatService>());
    expect(Get.find<LanguageServiceInterface>(), isA<LanguageService>());
    expect(Get.find<SplashServiceInterface>(), isA<SplashService>());
    expect(Get.find<NotificationServiceInterface>(),
        isA<NotificationService>());
    expect(Get.find<ProfileServiceInterface>(), isA<ProfileService>());
    expect(Get.find<AddressServiceInterface>(), isA<AddressService>());
    expect(Get.find<AuthServiceInterface>(), isA<AuthService>());
    expect(Get.find<OrderServiceInterface>(), isA<OrderService>());
    expect(languages.keys, containsAll(<String>['en_US', 'ar_SA']));
  });
}
