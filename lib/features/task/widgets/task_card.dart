import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/util/theme_extension.dart';

class TaskCard extends StatelessWidget {
  final int taskNumber;
  final String name;
  final String idNumber;
  final String itemTitle;
  final String itemSubtitle;
  final String? note; // يمكن أن يكون null
  final double amount;
  final VoidCallback onDelivered;
  final VoidCallback onReschedule;
  final VoidCallback onSupport;

  const TaskCard({
    Key? key,
    required this.taskNumber,
    required this.name,
    required this.idNumber,
    required this.itemTitle,
    required this.itemSubtitle,
    this.note,
    required this.amount,
    required this.onDelivered,
    required this.onReschedule,
    required this.onSupport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return CustomCard(
      padding: EdgeInsets.all(Dimensions.p16),
      isBorder: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${'task'.tr} : $taskNumber',
              style: robotoBold.copyWith(
                fontSize: Dimensions.fs16,
                color: Theme.of(context).disabledColor,
              )),

          const SizedBox(height: Dimensions.p8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(name,
                    maxLines: 2,
                    style: robotoBold.copyWith(fontSize: Dimensions.fs18)),
              ),
              Spacer(),
              Expanded(
                flex: 1,
                child: Text(PriceConverterHelper.convertPrice(amount),
                    style: robotoSemiBold.copyWith(
                        fontSize: Dimensions.fs18,
                        color: ManagerColors.greenLightMode)),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.p8),

          Text('${'id_number'.tr} $idNumber',
              style: robotoBold.copyWith(fontSize: Dimensions.fs16)),
          const SizedBox(height: Dimensions.p8),

          // Item box
          CustomCard(
            padding: const EdgeInsets.all(Dimensions.p16),
            borderRadius: Dimensions.r16,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(ManagerAssets.taskIcon,color: Theme.of(context).textTheme.bodyMedium?.color,),
                    const SizedBox(width: Dimensions.p12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(itemTitle,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fs16,
                            )),
                        SizedBox(
                          height: Dimensions.p4,
                        ),
                        Text(itemSubtitle,
                            style: robotoSemiBold.copyWith(
                                fontSize: Dimensions.fs14,
                                color: Theme.of(context).disabledColor)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Note box (اختياري)
          if (note != null) ...[
            
            const SizedBox(height: Dimensions.p12),
            CustomCard(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.p16),
              fillColor: customColor.blueBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('updated_from_support'.tr,
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fs16,
                          color: customColor.blue)),
                  const SizedBox(height: Dimensions.p4),
                  Text(note!,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fs15,
                          color: customColor.blue)),
                ],
              ),
            ),
          ],
          const SizedBox(height: Dimensions.p16),

          // Buttons
          Row(
            children: [
              Expanded(
                child: CustomButtonWidget(
                  onPressed: onDelivered,
                  backgroundColor: ManagerColors.lightGreen,
                  buttonText: 'delivered'.tr,
                  fontSize: Dimensions.fs15,
                ),
              ),
              const SizedBox(width: Dimensions.p8),
              Expanded(
                child: CustomButtonWidget(
                  onPressed: onReschedule,
                  backgroundColor: ManagerColors.orange,
                  buttonText: 'reschedule'.tr,
                  fontSize: Dimensions.fs15,
                ),
              ),
              const SizedBox(width: Dimensions.p8),
              Expanded(
                child: CustomButtonWidget(
                  onPressed: onSupport,
                  backgroundColor: ManagerColors.naturalBlueLightMode,
                  buttonText: 'support'.tr,
                  fontSize: Dimensions.fs15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
