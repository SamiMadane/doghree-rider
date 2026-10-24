import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/util/manager_colors.dart';

extension OrderHistoryX on OrderModel {
  bool get _isCanceled =>
      orderStatus == 'canceled' ||
      orderStatus == 'failed' ||
      orderStatus == 'refunded';

  bool get isParcel => orderType == 'parcel';

  /// Status colour: delivered = success, canceled = danger, else neutral.
  Color get statusColor {
    if (orderStatus == 'delivered') return ManagerColors.success;
    if (_isCanceled) return ManagerColors.error;
    return ManagerColors.darkGray;
  }

  /// Text on top of [statusColor] (asphalt on green/red, white on grey).
  Color get onStatusColor {
    if (orderStatus == 'delivered' || _isCanceled) return ManagerColors.onPrimary;
    return ManagerColors.white;
  }

  String get historyTitle {
    if (isParcel) {
      return parcelCategory?.name ?? 'no_parcel_category_data_found'.tr;
    }
    return storeName ?? 'no_store_data_found'.tr;
  }

  String get historyImage => isParcel
      ? (parcelCategory?.imageFullUrl ?? '')
      : (storeLogoFullUrl ?? '');
}