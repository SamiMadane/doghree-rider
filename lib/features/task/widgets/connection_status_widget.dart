// file: widgets/connection_status_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:wefrh_rider/features/task/controllers/task_controller.dart';
import 'package:wefrh_rider/features/task/widgets/connection_bottom_sheet.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';


class ConnectionStatusWidget extends StatelessWidget {
  final TaskController controller = Get.put(TaskController());

  ConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => InkWell(
          onTap: () => _showBottomSheet(context),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.p16,
                vertical: Dimensions.p8),
                margin: EdgeInsets.symmetric(horizontal: Dimensions.p10),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(Dimensions.r8),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: controller.connectionColor.value,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: Dimensions.p8),
                Text(
                  controller.connectionLabel.value,
                  style: robotoRegular.copyWith(
                      fontSize: Dimensions.fs14),
                ),
              ],
            ),
          ),
        ));
  }

  void _showBottomSheet(BuildContext context) {
    showCustomBottomSheet(
      child: ConnectionBottomSheet(controller: controller),
    );
  }
}
