import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/api/error_message.dart';
import 'package:wefrh_rider/api/error_type.dart';
import 'api_error_model.dart';

class ApiErrorHandler {
  /// معالجة الأخطاء وإرجاع نموذج خطأ واضح
  static ApiErrorModel handleError(dynamic error) {
    if (kDebugMode) {
      debugPrint('🔴 API Error: $error');
    }

    // معالجة أخطاء Response
    if (error is Response) {
      return _handleResponseError(error);
    }

    // معالجة أخطاء Exception
    if (error is Exception) {
      return _handleException(error);
    }

    // معالجة String errors
    if (error is String) {
      return _handleStringError(error);
    }

    // خطأ غير معروف
    return ApiErrorModel(
      code: HttpStatusCode.unknown,
      message: ErrorMessages.getMessage(ErrorType.unknown),
    );
  }

  /// معالجة أخطاء Response
  static ApiErrorModel _handleResponseError(Response response) {
    final statusCode = response.statusCode ?? HttpStatusCode.unknown;

    if (kDebugMode) {
      debugPrint('🔴 Response Error - Code: $statusCode');
      debugPrint('🔴 Response Body: ${response.body}');
      debugPrint('🔴 Status Text: ${response.statusText}');
    }

    // محاولة استخراج رسالة من الـ body
    String? apiMessage = _extractMessageFromBody(response.body);

    switch (statusCode) {
      case HttpStatusCode.badRequest:
        return ApiErrorModel(
          code: statusCode,
          message: ErrorMessages.getMessage(
            ErrorType.badRequest,
            customMessage: apiMessage,
          ),
        );

      case HttpStatusCode.unauthorized:
        return ApiErrorModel(
          code: statusCode,
          message: ErrorMessages.getMessage(
            ErrorType.unauthorized,
            customMessage: apiMessage,
          ),
        );

      case HttpStatusCode.forbidden:
        return ApiErrorModel(
          code: statusCode,
          message: ErrorMessages.getMessage(
            ErrorType.forbidden,
            customMessage: apiMessage,
          ),
        );

      case HttpStatusCode.notFound:
        return ApiErrorModel(
          code: statusCode,
          message: ErrorMessages.getMessage(
            ErrorType.notFound,
            customMessage: apiMessage,
          ),
        );

      case HttpStatusCode.validationError:
        // أ) داخل _handleResponseError، بدل جلب validationErrors:
        Map<String, dynamic>? validationErrors;
        if (response.body is Map && response.body['errors'] is Map) {
          validationErrors = Map<String, dynamic>.from(response.body['errors']);
        }

        return ApiErrorModel(
          code: statusCode,
          message: ErrorMessages.getMessage(
            ErrorType.validationError,
            customMessage: apiMessage,
          ),
          validationErrors: validationErrors,
        );

      case HttpStatusCode.serverError:
      case HttpStatusCode.serviceUnavailable:
        return ApiErrorModel(
          code: statusCode,
          message: ErrorMessages.getMessage(
            ErrorType.serverError,
            customMessage: apiMessage,
          ),
        );
      case HttpStatusCode.tooManyRequests:
        return ApiErrorModel(
            code: statusCode,
            message: ErrorMessages.getMessage(ErrorType.tooManyRequests,
                customMessage: apiMessage));
      case HttpStatusCode.methodNotAllowed:
        return ApiErrorModel(
            code: statusCode,
            message: ErrorMessages.getMessage(ErrorType.blocked,
                customMessage: apiMessage));
      case HttpStatusCode.gone:
        return ApiErrorModel(
            code: statusCode,
            message: ErrorMessages.getMessage(ErrorType.gone,
                customMessage: apiMessage));
      default:
        // إذا كان الكود 1 (no internet من ApiClient)
        if (statusCode == 1) {
          return ApiErrorModel(
            code: HttpStatusCode.noInternet,
            message: ErrorMessages.getMessage(ErrorType.noInternet),
          );
        }

        return ApiErrorModel(
          code: statusCode,
          message: ErrorMessages.getMessage(
            ErrorType.unknown,
            customMessage: apiMessage ?? response.statusText,
          ),
        );
    }
  }

  /// معالجة أخطاء Exception
  static ApiErrorModel _handleException(Exception exception) {
    if (kDebugMode) {
      debugPrint('🔴 Exception: $exception');
    }

    // أخطاء الاتصال
    if (exception is SocketException) {
      return ApiErrorModel(
        code: HttpStatusCode.noInternet,
        message: ErrorMessages.getMessage(ErrorType.noInternet),
      );
    }

    // أخطاء الوقت
    if (exception is TimeoutException) {
      return ApiErrorModel(
        code: HttpStatusCode.timeout,
        message: ErrorMessages.getMessage(ErrorType.timeout),
      );
    }

    // أخطاء عامة
    return ApiErrorModel(
      code: HttpStatusCode.unknown,
      message: ErrorMessages.getMessage(ErrorType.unknown),
      details: exception.toString(),
    );
  }

  /// معالجة أخطاء String
  static ApiErrorModel _handleStringError(String error) {
    if (kDebugMode) {
      debugPrint('🔴 String Error: $error');
    }

    // التحقق من نوع الخطأ من النص
    final lowerError = error.toLowerCase();

    if (lowerError.contains('internet') ||
        lowerError.contains('connection') ||
        lowerError.contains('network')) {
      return ApiErrorModel(
        code: HttpStatusCode.noInternet,
        message: ErrorMessages.getMessage(ErrorType.noInternet),
      );
    }

    if (lowerError.contains('timeout')) {
      return ApiErrorModel(
        code: HttpStatusCode.timeout,
        message: ErrorMessages.getMessage(ErrorType.timeout),
      );
    }

    return ApiErrorModel(
      code: HttpStatusCode.unknown,
      message: ErrorMessages.getMessage(
        ErrorType.unknown,
        customMessage: error,
      ),
    );
  }

  /// استخراج الرسالة من الـ body
  static String? _extractMessageFromBody(dynamic body) {
    if (body == null) return null;

    try {
      // إذا كان Map
      if (body is Map) {
        // البحث عن message في مفاتيح مختلفة
        if (body['message'] != null) {
          return body['message'].toString();
        }
        if (body['error'] != null) {
          if (body['error'] is String) {
            return body['error'];
          }
          if (body['error'] is Map && body['error']['message'] != null) {
            return body['error']['message'].toString();
          }
        }
        if (body['msg'] != null) {
          return body['msg'].toString();
        }

        // البحث في errors array
        if (body['errors'] != null && body['errors'] is List) {
          final errors = body['errors'] as List;
          if (errors.isNotEmpty) {
            final firstError = errors.first;
            if (firstError is Map && firstError['message'] != null) {
              return firstError['message'].toString();
            }
            if (firstError is String) {
              return firstError;
            }
          }
        }
      }

      // إذا كان String
      if (body is String) {
        return body;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔴 Error extracting message: $e');
      }
    }

    return null;
  }

  /// تنسيق أخطاء الـ validation لعرضها
  static String formatValidationErrors(Map<String, dynamic>? errors) {
    if (errors == null || errors.isEmpty) return '';

    final List<String> errorMessages = [];

    errors.forEach((field, messages) {
      if (messages is List) {
        for (var message in messages) {
          errorMessages.add('• $message');
        }
      } else if (messages is String) {
        errorMessages.add('• $messages');
      }
    });

    return errorMessages.join('\n');
  }

  /// تحديد نوع الخطأ من الكود
  static ErrorType getErrorType(int code) {
    switch (code) {
      case HttpStatusCode.noInternet:
        return ErrorType.noInternet;
      case HttpStatusCode.timeout:
        return ErrorType.timeout;
      case HttpStatusCode.unauthorized:
        return ErrorType.unauthorized;
      case HttpStatusCode.forbidden:
        return ErrorType.forbidden;
      case HttpStatusCode.notFound:
        return ErrorType.notFound;
      case HttpStatusCode.badRequest:
        return ErrorType.badRequest;
      case HttpStatusCode.validationError:
        return ErrorType.validationError;
      case HttpStatusCode.serverError:
      case HttpStatusCode.serviceUnavailable:
        return ErrorType.serverError;
      case HttpStatusCode.cancelled:
        return ErrorType.cancelled;
      case HttpStatusCode.tooManyRequests:
        return ErrorType.tooManyRequests;
      case HttpStatusCode.methodNotAllowed:
        return ErrorType.blocked;
      case HttpStatusCode.gone:
        return ErrorType.gone;
      default:
        return ErrorType.unknown;
    }
  }

  /// الرسالة من أي شكل: errors كقائمة أو نص أو كائن، أو message
  static String? extractMessage(dynamic body) {
    try {
      if (body is Map) {
        final fromErrors = _firstMessage(body['errors']);
        if (fromErrors != null) return fromErrors;
        for (final k in ['message', 'error', 'msg']) {
          final v = body[k];
          if (v is String && v.isNotEmpty) return v;
          if (v is Map && v['message'] is String) return v['message'] as String;
        }
      }
    } catch (_) {}
    return null; // جسم نصي/HTML لا يُعرض للمستخدم
  }

  static String? _firstMessage(dynamic errors) {
    if (errors is String && errors.isNotEmpty) return errors;
    if (errors is List && errors.isNotEmpty) {
      final f = errors.first;
      if (f is String) return f;
      if (f is Map && f['message'] != null) return f['message'].toString();
    }
    if (errors is Map && errors.isNotEmpty) {
      final v = errors.values.first;
      if (v is List && v.isNotEmpty) return v.first.toString();
      if (v is String) return v;
    }
    return null;
  }

  /// errors[0].code (أو اسم الحقل في أخطاء التحقق). للمقارنة بدل النص.
  static String? extractCode(dynamic body) {
    if (body is Map) {
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty && errors.first is Map) {
        return (errors.first as Map)['code']?.toString();
      }
      if (errors is Map && errors.isNotEmpty)
        return errors.keys.first.toString();
    }
    return null;
  }

  static String? codeOf(Response r) => extractCode(r.body);
}
