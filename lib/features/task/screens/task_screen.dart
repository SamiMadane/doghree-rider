import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/features/task/widgets/connection_status_widget.dart';
import 'package:sixam_mart_delivery/features/task/widgets/no_task_section.dart';
import 'package:sixam_mart_delivery/features/task/widgets/statistics_section.dart';
import 'package:sixam_mart_delivery/features/task/widgets/exist_task_section.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool existTransaction = false;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
        title: 'task_management'.tr,
        centerTitle: false,
        isBackButtonExist: false,
        actionWidget: ConnectionStatusWidget(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Dimensions.p16),
              child: Column(
                children: [
                  StatisticsSection(),
                  const SizedBox(height: Dimensions.p16),
                  existTransaction
                      ? const ExistTaskSection()
                      : const NoTaskSection(),
                ],
              ),
            ),
            if (existTransaction) ...[
              const SizedBox(height: Dimensions.p30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: const Offset(0, -3), // ظل لأعلى
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomButtonWidget(
                  radius: Dimensions.r8,
                  onPressed: () {
                    print("Finish the shift");
                  },
                  buttonText:
                      '${'finish_the_shift'.tr} ${PriceConverterHelper.convertPrice(590)}',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
