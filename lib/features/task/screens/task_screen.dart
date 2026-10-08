import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/features/task/widgets/connection_status_widget.dart';
import 'package:wefrh_rider/features/task/widgets/no_task_section.dart';
import 'package:wefrh_rider/features/task/widgets/statistics_section.dart';
import 'package:wefrh_rider/features/task/widgets/exist_task_section.dart';
import 'package:wefrh_rider/helper/price_converter_helper.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool existTransaction = true;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
        title: 'task_management'.tr,
        centerTitle: false,
        isBackButtonExist: false,
        actionWidget: ConnectionStatusWidget(),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
         margin: EdgeInsets.only(
          top: Dimensions.h16,
        ),
        color: Theme.of(context).cardColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  StatisticsSection(),
                  SizedBox(height: Dimensions.h16),
                  existTransaction
                      ? const ExistTaskSection()
                      : const NoTaskSection(),
                ],
              ),
              if (existTransaction) ...[
                SizedBox(height: Dimensions.h30),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor,
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: const Offset(0, -3), // ظل لأعلى
                      ),
                    ],
                  ),
                  child: CustomButtonWidget(
                    radius: Dimensions.r8,
                    onPressed: () {
                      Get.toNamed(RouteHelper.getFinishShiftRoute());
                    },
                    buttonText:
                        '${'finish_the_shift'.tr} ${PriceConverterHelper.convertPrice(590)}',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
