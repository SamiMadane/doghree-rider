import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/util/theme_extension.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DetailsStatisticsScreen extends StatelessWidget {
  const DetailsStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'detailed_statistics'.tr),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // مساحة للزر + مسافة
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Total tasks
                  CustomCard(
                    padding: const EdgeInsets.all(Dimensions.p16),
                    isBorder: false,
                    borderRadius: Dimensions.r8,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('total_tasks_today'.tr,
                                      style: robotoBold.copyWith(
                                          fontSize: Dimensions.fs16,
                                          color: Theme.of(context).primaryColor)),
                                  SizedBox(height: Dimensions.p12),
                                  Text('8',
                                      style: robotoBold.copyWith(
                                          fontSize: Dimensions.fs32,
                                          color: Theme.of(context).primaryColor)),
                                ],
                              ),
                              Spacer(),
                              Image.asset(
                                ManagerAssets.totalTaskImage,
                                height: 120,width: 120,
                                fit: BoxFit.cover,
                              )
                            ],
                          ),
                          SizedBox(height: Dimensions.p12),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${'reminder'.tr} ',
                                  style: robotoSemiBold.copyWith(
                                      fontSize: Dimensions.fs14,
                                      color: ManagerColors.orangeLightMode),
                                ),
                                TextSpan(
                                  text: 'reminder_message'.tr,
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fs14,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: Dimensions.p12),

                  /// List of beneficiaries
                  CustomCard(
                    padding: const EdgeInsets.all(Dimensions.p16),
                    isBorder: false,
                    borderRadius: Dimensions.r8,
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.p16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('list_of_beneficiaries'.tr,
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fs18)),
                          SizedBox(height: Dimensions.p16),
                          Row(
                            children: [
                              Text('embedding_rate'.tr,
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fs17)),
                              Spacer(),
                              InkWell(
                                onTap: () {
                                  Get.toNamed(RouteHelper
                                      .getDetailedOperationHistoryRoute());
                                },
                                child: Text(
                                  'see_all'.tr,
                                  style: robotoRegular.copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationColor: customColor.naturalBlue,
                                    color: customColor.naturalBlue,
                                  ),
                                ),
                              )
                            ],
                          ),

                          SizedBox(
                            height: 180,
                            child: SfRadialGauge(
                              axes: <RadialAxis>[
                                RadialAxis(
                                  startAngle: 180,
                                  endAngle: 0,
                                  showLabels: false,
                                  showTicks: false,
                                  canScaleToFit: true,
                                  axisLineStyle: AxisLineStyle(
                                    thickness: 20,
                                    color: customColor.gray,
                                    cornerStyle: CornerStyle.bothCurve,
                                  ),
                                  pointers: <GaugePointer>[
                                    RangePointer(
                                      value: 38,
                                      cornerStyle: CornerStyle.bothCurve,
                                      width: 20,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                      angle: 90,
                                      positionFactor: 0,
                                      widget: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '38%',
                                            style: robotoBold.copyWith(
                                                fontSize: Dimensions.fs28,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                          SizedBox(height: Dimensions.p2),
                                          Text(
                                            'total /20',
                                            style: robotoMedium.copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: Dimensions.p16),

                          /// Grid العناصر الأربعة
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            crossAxisCount: 2,
                            crossAxisSpacing: Dimensions.p8,
                            mainAxisSpacing: Dimensions.p8,
                            childAspectRatio: 1.4,
                            children: [
                              _statusBox(
                                  "23",
                                  "Delivered",
                                  customColor.greenBg,
                                  ManagerColors.greenLightMode,
                                  ManagerAssets.deliveredImage),
                              _statusBox(
                                  "3",
                                  "Postponed",
                                  customColor.orangeBg,
                                  ManagerColors.orangeLightMode,
                                  ManagerAssets.postponedImage),
                              _statusBox(
                                  "1",
                                  "Waiting",
                                  customColor.blueBg,
                                  customColor.naturalBlue,
                                  ManagerAssets.waitingImage),
                              _statusBox(
                                  "1",
                                  "Problem",
                                  customColor.primaryBg,
                                  Theme.of(context).primaryColor,
                                  ManagerAssets.problemImage),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: Dimensions.p12),

                  /// Amount to be delivered
                  CustomCard(
                    padding: const EdgeInsets.all(Dimensions.p16),
                    isBorder: false,
                    borderRadius: Dimensions.r8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      ManagerAssets.flagIcon,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    SizedBox(width: Dimensions.p4),
                                    Text('amount_to_be_delivered'.tr,
                                        style: robotoBold.copyWith(
                                            fontSize: Dimensions.fs16,
                                            color: Theme.of(context)
                                                .primaryColor)),
                                  ],
                                ),
                                SizedBox(height: Dimensions.p8),
                                Text(PriceConverterHelper.convertPrice(47),
                                    style: robotoSemiBold.copyWith(
                                        fontSize: Dimensions.fs24,
                                        color: Theme.of(context).primaryColor)),
                              ],
                            ),
                            Spacer(),
                            Image.asset(ManagerAssets.amountToBeDeliveredImage,height: 100,width: 100,fit: BoxFit.cover,)
                          ],
                        ),
                        SizedBox(height: Dimensions.p8),
                        Text(
                          'handover_message'.tr,
                          style:
                              robotoMedium.copyWith(fontSize: Dimensions.fs14),
                        ),
                        SizedBox(height: Dimensions.p16),
                        CustomCard(
                          padding: const EdgeInsets.all(Dimensions.p16),
                          isBorder: false,
                          borderRadius: Dimensions.r8,
                          fillColor: customColor.primaryBg,
                          child: Text(
                            'important_note_payment'.tr,
                            style: robotoBold.copyWith(
                                color: Theme.of(context).primaryColor),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// زر التحميل أسفل الشاشة
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: const Offset(0, -3),
                  ),
                ],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.r8),
                    topRight: Radius.circular(Dimensions.r8)),
              ),
              child: CustomButtonWidget(
                width: double.infinity,
                onPressed: () {},
                icon: SvgPicture.asset(ManagerAssets.downloadIcon,height: 30,width: 30,),
                buttonText: 'download_payment_statement'.tr,
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _statusBox(String count, String title, Color bgColor, Color textColor,
    String image) {
  return CustomCard(
    padding: const EdgeInsets.all(Dimensions.p12),
    fillColor: bgColor,
    isBorder: false,
    borderRadius: Dimensions.r12,
    child: SizedBox(
      height: 80, // ارتفاع ثابت لكل البوكسات
      child: Row(
        children: [
          // نص مرن مع تقليم
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1, // سطر واحد فقط
                  overflow: TextOverflow.ellipsis, // يظهر ... إذا طويل
                  style: robotoBold.copyWith(
                      color: textColor, fontSize: Dimensions.fs14),
                ),
                SizedBox(height: Dimensions.p4),
                Text(
                  count,
                  style: robotoBold.copyWith(
                      color: textColor, fontSize: Dimensions.fs15),
                ),
              ],
            ),
          ),
          SizedBox(width: Dimensions.p8),
          // الصورة ثابتة الحجم
          Image.asset(
            image,
            width: 65,
            height: 65,
            fit: BoxFit.contain,
          ),
        ],
      ),
    ),
  );
}


}
