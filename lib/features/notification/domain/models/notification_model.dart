class NotificationModel {
  int? id;
  String? title;
  String? description;
  String? imageFullUrl;
  String? createdAt;
  String? updatedAt;
  Data? data;

  NotificationModel({
    this.id,
    this.title,
    this.description,
    this.imageFullUrl,
    this.createdAt,
    this.updatedAt,
    this.data,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    imageFullUrl = json['image_full_url'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['image_full_url'] = imageFullUrl;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
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
    orderId = json['order_id'];
    customerId = json['customer_id'];
    vendorId = json['vendor_id'];
    conversationId = json['conversation_id'];
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