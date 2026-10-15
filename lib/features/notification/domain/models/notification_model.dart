class NotificationModel {
  int? id;
  String? title;
  String? description;
  String? imageFullUrl;
  String? createdAt;
  String? updatedAt;
  Data? data;
  bool isRead = false;

  NotificationModel(
      {this.id,
      this.title,
      this.description,
      this.imageFullUrl,
      this.createdAt,
      this.updatedAt,
      this.data,
      this.isRead = false});

  // ✨ Safe parsing لكل الحقول
  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = _safeIntParse(json['id']);

    final Map<String, dynamic>? dataMap =
        json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null;

    title = _safeString(json['title']) ?? _safeString(dataMap?['title']);
    description = _safeString(json['description']) ??
        _safeString(dataMap?['description']);
    imageFullUrl = _safeString(json['image_full_url']) ??
        _safeString(dataMap?['image_full_url']) ??
        _safeString(dataMap?['image']);

    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    data = dataMap != null ? Data.fromJson(dataMap) : null;
    isRead = _safeBool(json['is_read']);
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['image_full_url'] = imageFullUrl;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_read'] = isRead;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }

  static String? _safeString(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  static bool _safeBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }

  // ✅ دالة Safe parsing موحدة
  static int? _safeIntParse(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class Data {
  String? type;
  int? orderId;
  int? customerId;
  int? vendorId;
  int? conversationId;

  Data({
    this.type,
    this.orderId,
    this.customerId,
    this.vendorId,
    this.conversationId,
  });

  Data.fromJson(Map<String, dynamic> json) {
    type = json['type'];

    // ✨ استخدام الدالة الموحدة لكل الحقول
    orderId = NotificationModel._safeIntParse(json['order_id']);
    customerId = NotificationModel._safeIntParse(json['customer_id']);
    vendorId = NotificationModel._safeIntParse(json['vendor_id']);
    conversationId = NotificationModel._safeIntParse(json['conversation_id']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['order_id'] = orderId;
    data['customer_id'] = customerId;
    data['vendor_id'] = vendorId;
    data['conversation_id'] = conversationId;
    return data;
  }
}
