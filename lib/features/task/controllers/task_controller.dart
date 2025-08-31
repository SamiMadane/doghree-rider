// file: controllers/task_connection_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';

class TaskController extends GetxController {
  RxString connectionLabel = 'without'.tr.obs;
  Rx<Color> connectionColor = ManagerColors.grayCirule.obs;

  void setConnectionState(String label, Color color) {
    connectionLabel.value = label;
    connectionColor.value = color;
  }

  String get connectionStatusText {
    switch (connectionLabel.value) {
      case 'WiFi':
        return 'wifi_connected'.tr;
      case '2G':
        return 'packages_2g'.tr;
      default:
        return 'without_internet'.tr;
    }
  }
}
