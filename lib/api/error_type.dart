// تصنيف أنواع الأخطاء
enum ErrorType {
  // أخطاء الشبكة
  noInternet,
  timeout,
  connectionError,

  // أخطاء المصادقة
  unauthorized,
  sessionExpired,
  forbidden,

  // أخطاء الخادم
  serverError,
  notFound,
  serviceUnavailable,

  // أخطاء البيانات
  badRequest,
  validationError,

  tooManyRequests, // 429
  blocked, // 405 (مثل blocked_temp_otp)
  gone, // 410

  // أخطاء أخرى
  cancelled,
  unknown,
}

// أكواد الحالات HTTP
class HttpStatusCode {
  static const int success = 200;
  static const int created = 201;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int validationError = 422;
  static const int serverError = 500;
  static const int serviceUnavailable = 503;
  static const int methodNotAllowed = 405;
  static const int gone = 410;
  static const int tooManyRequests = 429;

  // أكواد محلية للأخطاء
  static const int timeout = -1;
  static const int noInternet = -2;
  static const int cancelled = -3;
  static const int unknown = -4;
}
