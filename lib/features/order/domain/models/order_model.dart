import 'package:doghree_rider/helper/json_helper.dart';

class PaginatedOrderModel {
  int? totalSize;
  String? limit;
  String? offset;
  List<OrderModel>? orders;

  PaginatedOrderModel({this.totalSize, this.limit, this.offset, this.orders});

  /// `total_size`, `limit` and `offset` may arrive as numbers or strings
  /// (audit rows 27, 53). A missing or wrong `orders` gives null, which the
  /// controller treats as the end of the history. A bad order is skipped.
  PaginatedOrderModel.fromJson(Map<String, dynamic> json) {
    totalSize = JsonHelper.asInt(json['total_size']);
    limit = json['limit'].toString();
    offset = json['offset'].toString();
    orders = JsonHelper.mapList(json['orders'], OrderModel.fromJson,
        name: 'all-orders');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderModel {
  int? id;
  int? itemCampaignId;
  int? userId;
  double? orderAmount;
  double? couponDiscountAmount;
  String? paymentStatus;
  String? orderStatus;
  double? totalTaxAmount;
  String? paymentMethod;
  String? transactionReference;
  int? deliveryAddressId;
  int? deliveryManId;
  String? orderType;
  int? storeId;
  String? createdAt;
  String? updatedAt;
  double? deliveryCharge;
  double? originalDeliveryCharge;
  String? scheduleAt;
  String? storeName;
  String? storeAddress;
  String? storeLat;
  String? storeLng;
  String? storeLogoFullUrl;
  String? storePhone;
  int? detailsCount;
  String? orderNote;
  bool? prescriptionOrder;
  List<String>? orderAttachmentFullUrl;
  String? chargePayer;
  String? moduleType;
  DeliveryAddress? deliveryAddress;
  DeliveryAddress? receiverDetails;
  ParcelCategory? parcelCategory;
  Customer? customer;
  double? dmTips;
  bool? cutlery;
  String? unavailableItemNote;
  String? deliveryInstruction;
  List<String>? orderProofFullUrl;

  /// True when the server holds at least one proof photo URL (D-09). A
  /// missing, null, empty or non-list `order_proof_full_url` is false.
  bool get hasProofImages =>
      JsonHelper.stringList(orderProofFullUrl).any((u) => u.trim().isNotEmpty);
  List<Payments>? payments;
  double? storeDiscountAmount;
  bool? taxStatus;
  double? additionalCharge;
  bool? isGuest;
  double? flashAdminDiscountAmount;
  double? flashStoreDiscountAmount;
  double? extraPackagingAmount;
  double? referrerBonusAmount;
  String? storeBusinessModel;
  int? storeChatPermission;
  String? prescriptionNote;

  OrderModel({
    this.id,
    this.itemCampaignId,
    this.userId,
    this.orderAmount,
    this.couponDiscountAmount,
    this.paymentStatus,
    this.orderStatus,
    this.totalTaxAmount,
    this.paymentMethod,
    this.transactionReference,
    this.deliveryAddressId,
    this.deliveryManId,
    this.orderType,
    this.storeId,
    this.createdAt,
    this.updatedAt,
    this.deliveryCharge,
    this.originalDeliveryCharge,
    this.scheduleAt,
    this.storeName,
    this.storeAddress,
    this.storeLat,
    this.storeLng,
    this.storeLogoFullUrl,
    this.storePhone,
    this.detailsCount,
    this.chargePayer,
    this.prescriptionOrder,
    this.orderAttachmentFullUrl,
    this.orderNote,
    this.moduleType,
    this.deliveryAddress,
    this.receiverDetails,
    this.parcelCategory,
    this.customer,
    this.dmTips,
    this.cutlery,
    this.unavailableItemNote,
    this.deliveryInstruction,
    this.orderProofFullUrl,
    this.payments,
    this.storeDiscountAmount,
    this.taxStatus,
    this.additionalCharge,
    this.isGuest,
    this.flashAdminDiscountAmount,
    this.flashStoreDiscountAmount,
    this.extraPackagingAmount,
    this.referrerBonusAmount,
    this.storeBusinessModel,
    this.storeChatPermission,
    this.prescriptionNote,
  });

  /// Every field is read with [JsonHelper], so a number sent as text, a 1/0
  /// flag or a nested value of the wrong type never drops the whole order
  /// from a list (audit row 96, D-16). Valid values read exactly as before.
  OrderModel.fromJson(Map<String, dynamic> json) {
    id = JsonHelper.asInt(json['id']);
    itemCampaignId = JsonHelper.asInt(json['item_campaign_id']);
    userId = JsonHelper.asInt(json['user_id']);
    orderAmount = JsonHelper.asDouble(json['order_amount']);
    couponDiscountAmount = JsonHelper.asDouble(json['coupon_discount_amount']);
    paymentStatus = JsonHelper.asString(json['payment_status']);
    orderStatus = JsonHelper.asString(json['order_status']);
    totalTaxAmount = JsonHelper.asDouble(json['total_tax_amount']);
    paymentMethod = JsonHelper.asString(json['payment_method']);
    transactionReference = JsonHelper.asString(json['transaction_reference']);
    deliveryAddressId = JsonHelper.asInt(json['delivery_address_id']);
    deliveryManId = JsonHelper.asInt(json['delivery_man_id']);
    orderType = JsonHelper.asString(json['order_type']);
    storeId = JsonHelper.asInt(json['store_id']);
    createdAt = JsonHelper.asString(json['created_at']);
    updatedAt = JsonHelper.asString(json['updated_at']);
    deliveryCharge = JsonHelper.asDouble(json['delivery_charge']);
    originalDeliveryCharge =
        JsonHelper.asDouble(json['original_delivery_charge']);
    scheduleAt = JsonHelper.asString(json['schedule_at']);
    storeName = JsonHelper.asString(json['store_name']);
    storeAddress = JsonHelper.asString(json['store_address']);
    // store_lat and store_lng arrive as strings, and every store_* key is
    // null for an order with no store (backend R2).
    storeLat = JsonHelper.asString(json['store_lat']);
    storeLng = JsonHelper.asString(json['store_lng']);
    storeLogoFullUrl = JsonHelper.asString(json['store_logo_full_url']);
    storePhone = JsonHelper.asString(json['store_phone']);
    detailsCount = JsonHelper.asInt(json['details_count']);
    orderNote = JsonHelper.asString(json['order_note']);
    chargePayer = JsonHelper.asString(json['charge_payer']);
    moduleType = JsonHelper.asString(json['module_type']);
    prescriptionOrder = JsonHelper.asBool(json['prescription_order']);
    if (json['order_attachment_full_url'] != null) {
      orderAttachmentFullUrl =
          JsonHelper.stringList(json['order_attachment_full_url']);
    }
    final Map<String, dynamic>? address =
        JsonHelper.asMap(json['delivery_address']);
    deliveryAddress = address != null ? DeliveryAddress.fromJson(address) : null;
    final Map<String, dynamic>? receiver =
        JsonHelper.asMap(json['receiver_details']);
    receiverDetails =
        receiver != null ? DeliveryAddress.fromJson(receiver) : null;
    final Map<String, dynamic>? category =
        JsonHelper.asMap(json['parcel_category']);
    parcelCategory =
        category != null ? ParcelCategory.fromJson(category) : null;
    final Map<String, dynamic>? customerJson =
        JsonHelper.asMap(json['customer']);
    customer = customerJson != null ? Customer.fromJson(customerJson) : null;
    dmTips = JsonHelper.asDouble(json['dm_tips']);
    cutlery = JsonHelper.asBool(json['cutlery']);
    unavailableItemNote = JsonHelper.asString(json['unavailable_item_note']);
    deliveryInstruction = JsonHelper.asString(json['delivery_instruction']);
    if (json['order_proof_full_url'] != null) {
      orderProofFullUrl = JsonHelper.stringList(json['order_proof_full_url']);
    }
    payments = JsonHelper.mapList(json['payments'], Payments.fromJson,
        name: 'payments');
    storeDiscountAmount = JsonHelper.asDouble(json['store_discount_amount']);
    taxStatus = json['tax_status'] == 'included' ? true : false;
    additionalCharge = JsonHelper.asDouble(json['additional_charge']) ?? 0;
    isGuest = JsonHelper.asBool(json['is_guest']);
    flashAdminDiscountAmount =
        JsonHelper.asDouble(json['flash_admin_discount_amount']) ?? 0;
    flashStoreDiscountAmount =
        JsonHelper.asDouble(json['flash_store_discount_amount']) ?? 0;
    extraPackagingAmount = JsonHelper.asDouble(json['extra_packaging_amount']);
    referrerBonusAmount = JsonHelper.asDouble(json['ref_bonus_amount']);
    storeBusinessModel = JsonHelper.asString(json['store_business_model']);
    storeChatPermission = JsonHelper.asInt(json['chat_permission']);
    prescriptionNote = JsonHelper.asString(json['prescription_note']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['item_campaign_id'] = itemCampaignId;
    data['user_id'] = userId;
    data['order_amount'] = orderAmount;
    data['coupon_discount_amount'] = couponDiscountAmount;
    data['payment_status'] = paymentStatus;
    data['order_status'] = orderStatus;
    data['total_tax_amount'] = totalTaxAmount;
    data['payment_method'] = paymentMethod;
    data['transaction_reference'] = transactionReference;
    data['delivery_address_id'] = deliveryAddressId;
    data['delivery_man_id'] = deliveryManId;
    data['prescription_note'] = prescriptionNote;

    data['order_type'] = orderType;
    data['store_id'] = storeId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['delivery_charge'] = deliveryCharge;
    data['original_delivery_charge'] = originalDeliveryCharge;
    data['schedule_at'] = scheduleAt;
    data['store_name'] = storeName;
    data['store_address'] = storeAddress;
    data['store_lat'] = storeLat;
    data['store_lng'] = storeLng;
    data['store_logo_full_url'] = storeLogoFullUrl;
    data['store_phone'] = storePhone;
    data['details_count'] = detailsCount;
    data['prescription_order'] = prescriptionOrder;
    data['order_attachment_full_url'] = orderAttachmentFullUrl;
    data['order_attachment'] = chargePayer;
    data['order_note'] = orderNote;
    data['module_type'] = moduleType;
    if (deliveryAddress != null) {
      data['delivery_address'] = deliveryAddress!.toJson();
    }
    if (receiverDetails != null) {
      data['receiver_details'] = receiverDetails!.toJson();
    }
    if (parcelCategory != null) {
      data['parcel_category'] = parcelCategory!.toJson();
    }
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    data['dm_tips'] = dmTips;
    data['cutlery'] = cutlery;
    data['unavailable_item_note'] = unavailableItemNote;
    data['delivery_instruction'] = deliveryInstruction;
    data['order_proof_full_url'] = orderProofFullUrl;
    if (payments != null) {
      data['payments'] = payments!.map((v) => v.toJson()).toList();
    }
    data['store_discount_amount'] = storeDiscountAmount;
    data['additional_charge'] = additionalCharge;
    data['is_guest'] = isGuest;
    data['flash_admin_discount_amount'] = flashAdminDiscountAmount;
    data['flash_store_discount_amount'] = flashStoreDiscountAmount;
    data['extra_packaging_amount'] = extraPackagingAmount;
    data['ref_bonus_amount'] = referrerBonusAmount;
    data['store_business_model'] = storeBusinessModel;
    data['chat_permission'] = storeChatPermission;
    return data;
  }
}

class DeliveryAddress {
  int? id;
  String? addressType;
  String? contactPersonNumber;
  String? address;
  String? latitude;
  String? longitude;
  int? userId;
  String? contactPersonName;
  String? createdAt;
  String? updatedAt;
  int? zoneId;
  String? streetNumber;
  String? house;
  String? floor;

  DeliveryAddress({
    this.id,
    this.addressType,
    this.contactPersonNumber,
    this.address,
    this.latitude,
    this.longitude,
    this.userId,
    this.contactPersonName,
    this.createdAt,
    this.updatedAt,
    this.zoneId,
    this.streetNumber,
    this.house,
    this.floor,
  });

  DeliveryAddress.fromJson(Map<String, dynamic> json) {
    id = JsonHelper.asInt(json['id']);
    addressType = JsonHelper.asString(json['address_type']);
    // A missing number stays null, never the text "null", so no Call button
    // dials it (audit row 100, D-16). A number sent as a number is its text.
    contactPersonNumber = JsonHelper.asString(json['contact_person_number']);
    address = JsonHelper.asString(json['address']);
    latitude = json['latitude'].toString();
    longitude = json['longitude'].toString();
    userId = JsonHelper.asInt(json['user_id']);
    contactPersonName = JsonHelper.asString(json['contact_person_name']);
    createdAt = JsonHelper.asString(json['created_at']);
    updatedAt = JsonHelper.asString(json['updated_at']);
    zoneId = JsonHelper.asInt(json['zone_id']);
    streetNumber = JsonHelper.asString(json['road']);
    house = JsonHelper.asString(json['house']);
    floor = JsonHelper.asString(json['floor']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address_type'] = addressType;
    data['contact_person_number'] = contactPersonNumber;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['user_id'] = userId;
    data['contact_person_name'] = contactPersonName;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['zone_id'] = zoneId;
    data['road'] = streetNumber;
    data['house'] = house;
    data['floor'] = floor;
    return data;
  }
}

class Customer {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? imageFullUrl;
  String? createdAt;
  String? updatedAt;
  String? cmFirebaseToken;
  Customer({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.imageFullUrl,
    this.createdAt,
    this.updatedAt,
    this.cmFirebaseToken,
  });

  Customer.fromJson(Map<String, dynamic> json) {
    id = JsonHelper.asInt(json['id']);
    fName = JsonHelper.asString(json['f_name']);
    lName = JsonHelper.asString(json['l_name']);
    phone = JsonHelper.asString(json['phone']);
    email = JsonHelper.asString(json['email']);
    imageFullUrl = JsonHelper.asString(json['image_full_url']);
    createdAt = JsonHelper.asString(json['created_at']);
    updatedAt = JsonHelper.asString(json['updated_at']);
    cmFirebaseToken = JsonHelper.asString(json['cm_firebase_token']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['image_full_url'] = imageFullUrl;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['cm_firebase_token'] = cmFirebaseToken;
    return data;
  }
}

class ParcelCategory {
  int? id;
  String? imageFullUrl;
  String? name;
  String? description;
  String? createdAt;
  String? updatedAt;

  ParcelCategory({
    this.id,
    this.imageFullUrl,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  ParcelCategory.fromJson(Map<String, dynamic> json) {
    id = JsonHelper.asInt(json['id']);
    imageFullUrl = JsonHelper.asString(json['image_full_url']);
    name = JsonHelper.asString(json['name']);
    description = JsonHelper.asString(json['description']);
    createdAt = JsonHelper.asString(json['created_at']);
    updatedAt = JsonHelper.asString(json['updated_at']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image_full_url'] = imageFullUrl;
    data['name'] = name;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Payments {
  int? id;
  int? orderId;
  double? amount;
  String? paymentStatus;
  String? paymentMethod;
  String? createdAt;
  String? updatedAt;

  Payments({
    this.id,
    this.orderId,
    this.amount,
    this.paymentStatus,
    this.paymentMethod,
    this.createdAt,
    this.updatedAt,
  });

  Payments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    amount = json['amount']?.toDouble();
    paymentStatus = json['payment_status'];
    paymentMethod = json['payment_method'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['amount'] = amount;
    data['payment_status'] = paymentStatus;
    data['payment_method'] = paymentMethod;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
