import 'package:doghree_rider/api/error_type.dart';

import 'package:get/get.dart';

class ErrorMessages {
  // الحصول على الرسالة حسب نوع الخطأ واللغة
  static String getMessage(ErrorType type, {String? customMessage}) {
    // إذا كان هناك رسالة مخصصة واضحة، استخدمها
    if (customMessage != null &&
        customMessage.isNotEmpty &&
        !_isTechnicalMessage(customMessage)) {
      return customMessage;
    }

    // استخدم الرسائل المترجمة حسب اللغة
    return _getLocalizedMessage(type);
  }

  // التحقق من أن الرسالة تقنية وليست واضحة
  static bool _isTechnicalMessage(String message) {
    final technicalPatterns = [
      'connection',
      'timeout',
      'socket',
      'exception',
      'error',
      'failed',
      'http',
      'server',
      '500',
      '404',
      '401',
    ];

    final lowerMessage = message.toLowerCase();
    return technicalPatterns.any((pattern) => lowerMessage.contains(pattern));
  }

  // الحصول على الرسالة المترجمة
  static String _getLocalizedMessage(ErrorType type) {
    // التحقق من اللغة الحالية
    final isArabic = Get.locale?.languageCode == 'ar';

    switch (type) {
      case ErrorType.noInternet:
        return isArabic
            ? 'لا يوجد اتصال بالإنترنت\nيرجى التحقق من اتصالك والمحاولة مرة أخرى'
            : 'No internet connection\nPlease check your connection and try again';

      case ErrorType.timeout:
        return isArabic
            ? 'انتهت مهلة الاتصال\nيرجى المحاولة مرة أخرى'
            : 'Connection timeout\nPlease try again';

      case ErrorType.connectionError:
        return isArabic
            ? 'فشل الاتصال بالخادم\nيرجى التحقق من اتصالك بالإنترنت'
            : 'Failed to connect to server\nPlease check your internet connection';

      case ErrorType.unauthorized:
        return isArabic
            ? 'عذراً، ليس لديك صلاحية للوصول'
            : 'Sorry, you don\'t have permission to access';

      case ErrorType.sessionExpired:
        return isArabic
            ? 'انتهت صلاحية الجلسة\nيرجى تسجيل الدخول مرة أخرى'
            : 'Session expired\nPlease login again';

      case ErrorType.forbidden:
        return isArabic
            ? 'عذراً، هذا الإجراء غير مسموح'
            : 'Sorry, this action is not allowed';

      case ErrorType.serverError:
        return isArabic
            ? 'حدث خطأ في الخادم\nنحن نعمل على حل المشكلة'
            : 'Server error occurred\nWe are working on fixing it';

      case ErrorType.notFound:
        return isArabic
            ? 'عذراً، البيانات المطلوبة غير موجودة'
            : 'Sorry, requested data not found';

      case ErrorType.serviceUnavailable:
        return isArabic
            ? 'الخدمة غير متاحة حالياً\nيرجى المحاولة لاحقاً'
            : 'Service unavailable\nPlease try again later';

      case ErrorType.badRequest:
        return isArabic
            ? 'طلب غير صحيح\nيرجى التحقق من البيانات المدخلة'
            : 'Invalid request\nPlease check your input';

      case ErrorType.validationError:
        return isArabic
            ? 'بيانات غير صحيحة\nيرجى التحقق من المعلومات المدخلة'
            : 'Invalid data\nPlease check your information';

      case ErrorType.cancelled:
        return isArabic ? 'تم إلغاء العملية' : 'Operation cancelled';
      case ErrorType.tooManyRequests:
        return isArabic
            ? 'محاولات كثيرة\nيرجى الانتظار قليلاً ثم المحاولة مرة أخرى'
            : 'Too many attempts\nPlease wait a moment and try again';
      case ErrorType.blocked:
        return isArabic
            ? 'تم تعليق هذا الإجراء مؤقتاً\nيرجى المحاولة لاحقاً'
            : 'This action is temporarily blocked\nPlease try again later';
      case ErrorType.gone:
        return isArabic
            ? 'هذه الخدمة لم تعد متاحة\nيرجى تحديث التطبيق'
            : 'This service is no longer available\nPlease update the app';

      case ErrorType.unknown:
      // ignore: unreachable_switch_default
      default:
        return isArabic
            ? 'حدث خطأ غير متوقع\nيرجى المحاولة مرة أخرى'
            : 'An unexpected error occurred\nPlease try again';
    }
  }

  // رسائل إضافية مفيدة
  static String getActionSuggestion(ErrorType type) {
    final isArabic = Get.locale?.languageCode == 'ar';

    switch (type) {
      case ErrorType.noInternet:
        return isArabic
            ? '• تحقق من اتصال الواي فاي أو البيانات\n• حاول إعادة تشغيل التطبيق'
            : '• Check your WiFi or data connection\n• Try restarting the app';

      case ErrorType.timeout:
      case ErrorType.connectionError:
        return isArabic
            ? '• تحقق من اتصالك بالإنترنت\n• حاول مرة أخرى بعد قليل'
            : '• Check your internet connection\n• Try again in a moment';

      case ErrorType.serverError:
        return isArabic
            ? '• حاول مرة أخرى بعد دقائق\n• إذا استمرت المشكلة، تواصل مع الدعم'
            : '• Try again in a few minutes\n• If the problem persists, contact support';

      case ErrorType.unauthorized:
      case ErrorType.sessionExpired:
        return isArabic
            ? '• سجل دخولك مرة أخرى\n• تأكد من بيانات الدخول'
            : '• Login again\n• Check your credentials';

      default:
        return '';
    }
  }
}
