import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/features/task/widgets/delivered_bottom_sheet.dart';
import 'package:wefrh_rider/features/task/widgets/reschedule_bottom_sheet.dart';
import 'package:wefrh_rider/features/task/widgets/task_card.dart';
import 'package:wefrh_rider/features/task/widgets/task_progress_section.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';

class ExistTaskSection extends StatelessWidget {
  const ExistTaskSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CustomCard(
        padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
        isBorder: false,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        child: TaskProgressSection(completed: 3, remaining: 3, issue: 1),
      ),
      SizedBox(
        height: Dimensions.h16,
      ),
      InkWell(
        onTap: () {
          Get.toNamed(RouteHelper.getClientScreenRoute());
        },
        child: TaskCard(
          taskNumber: 1,
          name: 'Yusuf Mahmoud Abdulrahman',
          idNumber: '444555666',
          itemTitle: 'Staple food items',
          itemSubtitle: 'CRS Foundation',
          note:
              'Phone number updated - old number not working', // null إذا لا توجد ملاحظة
          amount: 590,
          onDelivered: () {
            showCustomBottomSheet(child: DeliveredBottomSheet(beneficiaryName:'Yusuf Mahmoud Abdulrahman' ,));
          },
          onReschedule: () {
            showCustomBottomSheet(child: RescheduleBottomSheet(),showCloseButton: false);
          },
          onSupport: () {
            Get.toNamed(RouteHelper.getSupportTeamRoute());
          },
        ),
      ),
    ]);
  }
}
