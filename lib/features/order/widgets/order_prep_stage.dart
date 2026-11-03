import 'package:doghree_rider/util/manager_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/util/manager_colors.dart';

/// مرحلة تجهيز الطلب عند المتجر (بعد قبول السائق وقبل الاستلام).
enum OrderPrepStage {
  pending,
  processing;

  static OrderPrepStage of(bool processing) =>
      processing ? OrderPrepStage.processing : OrderPrepStage.pending;

  bool get isProcessing => this == OrderPrepStage.processing;

  String get label => isProcessing ? 'processing'.tr : 'pending'.tr;

  String get description =>
      isProcessing ? 'order_is_preparing'.tr : 'order_waiting_for_process'.tr;

  String get image => isProcessing
    ? ManagerAssets.orderPreparingImage
    : ManagerAssets.orderPendingImage;

  /// ألوان شارات حالات الطلب في دليل الهوية:
  /// pending = رمادي الطريق + أبيض، processing = أصفر + أسفلت.
  Color get chipBackground =>
      isProcessing ? ManagerColors.primaryLight : ManagerColors.darkGray;

  Color get chipForeground =>
      isProcessing ? ManagerColors.onPrimary : ManagerColors.white;

  /// خطوط الحارة: صفراء متحركة أثناء التجهيز، وخافتة ثابتة أثناء الانتظار.
   Color get laneDash => ManagerColors.primaryLight;

  /// مسار الطريق: أسفلت بالفاتح، ورمادي الطريق بالداكن (الكرت نفسه أسفلت).
  static Color laneTrack(bool isDark) =>
      isDark ? ManagerColors.darkGray : ManagerColors.onPrimary;
}