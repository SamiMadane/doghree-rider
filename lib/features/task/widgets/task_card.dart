import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/helper/price_converter_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/util/theme_extension.dart';

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
      padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
      isBorder: false,
        fillColor: Theme.of(context).scaffoldBackgroundColor,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${'task'.tr} : $taskNumber',
              style: textBold().copyWith(
                fontSize: Dimensions.fs16,
              )),

          SizedBox(height: Dimensions.h8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(name,
                    maxLines: 2,
                    style: textSemiBold().copyWith(fontSize: Dimensions.fs18)),
              ),
              Spacer(),
              Expanded(
                flex: 1,
                child: Text(PriceConverterHelper.convertPrice(amount),
                    style: textSemiBold().copyWith(
                        fontSize: Dimensions.fs18,
                        color: ManagerColors.greenLightMode)),
              ),
            ],
          ),
          SizedBox(height: Dimensions.h8),

          Text('${'id_number'.tr} $idNumber',
              style: textBold().copyWith(fontSize: Dimensions.fs16)),
          SizedBox(height: Dimensions.h8),

          // Item box
          CustomCard(
            padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
            borderRadius: Dimensions.r16,
            fillColor: Theme.of(context).cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(ManagerAssets.taskIcon,color: Theme.of(context).textTheme.bodyMedium?.color,),
                    SizedBox(width: Dimensions.w12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(itemTitle,
                            style: textBold().copyWith(
                              fontSize: Dimensions.fs16,
                            )),
                        SizedBox(
                          height: Dimensions.h4,
                        ),
                        Text(itemSubtitle,
                            style: textSemiBold().copyWith(
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
            
            SizedBox(height: Dimensions.h12),
            CustomCard(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
              fillColor: customColor.blueBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('updated_from_support'.tr,
                      style: textBold().copyWith(
                          fontSize: Dimensions.fs16,
                          color: customColor.blue)),
                  SizedBox(height: Dimensions.h4),
                  Text(note!,
                      style: textMedium().copyWith(
                          fontSize: Dimensions.fs15,
                          color: customColor.blue)),
                ],
              ),
            ),
          ],
          SizedBox(height: Dimensions.h16),

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
              SizedBox(width: Dimensions.w8),
              Expanded(
                child: CustomButtonWidget(
                  onPressed: onReschedule,
                  backgroundColor: ManagerColors.orangeLightMode,
                  buttonText: 'reschedule'.tr,
                  fontSize: Dimensions.fs15,
                ),
              ),
              SizedBox(width: Dimensions.w8),
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
