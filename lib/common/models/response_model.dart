class ResponseModel {
  final bool _isSuccess;
  final String? _message;
  final int? _statusCode;
  ResponseModel(this._isSuccess, this._message, {int? statusCode})
      : _statusCode = statusCode;

  String? get message => _message;
  bool get isSuccess => _isSuccess;
  int? get statusCode => _statusCode;

  /// 405 = رقم مقفول مؤقتاً (blocked_temp_otp)، 429 = تجاوز المعدّل
  bool get isRateLimited => _statusCode == 405 || _statusCode == 429;
}