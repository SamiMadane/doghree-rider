import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/features/task/widgets/task_card.dart';
import 'package:sixam_mart_delivery/features/task/widgets/task_progress_section.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';

class ExistTaskSection extends StatelessWidget {
  const ExistTaskSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CustomCard(
        padding: const EdgeInsets.all(Dimensions.p16),
        isBorder: false,
        child: TaskProgressSection(completed: 3, remaining: 3, issue: 1),
      ),
      SizedBox(
        height: Dimensions.p16,
      ),
      TaskCard(
        taskNumber: 1,
        name: 'Yusuf Mahmoud Abdulrahman',
        idNumber: '444555666',
        itemTitle: 'Staple food items',
        itemSubtitle: 'CRS Foundation',
        note:
            'Phone number updated - old number not working', // null إذا لا توجد ملاحظة
        amount: 590,
        onDelivered: () {
          print('Delivered');
        },
        onReschedule: () {
          print('Reschedule');
        },
        onSupport: () {
          print('Support');
        },
      ),
    ]);
  }
}
