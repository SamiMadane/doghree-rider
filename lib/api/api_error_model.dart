class ApiErrorModel {
  final int code;
  final String message;
  final String? details;
  final Map<String, dynamic>? validationErrors;

  ApiErrorModel({
    required this.code,
    required this.message,
    this.details,
    this.validationErrors,
  });

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      details: json['details'],
      validationErrors: json['errors'] is Map ? json['errors'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'details': details,
      'validationErrors': validationErrors,
    };
  }

  @override
  String toString() {
    return 'ApiErrorModel(code: $code, message: $message, details: $details)';
  }
}