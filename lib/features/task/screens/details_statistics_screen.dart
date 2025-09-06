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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(Dimensions.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Total tasks
                  CustomCard(
                    padding: EdgeInsets.all(Dimensions.p16),
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
                                          color:
                                              Theme.of(context).primaryColor)),
                                  SizedBox(height: Dimensions.p12),
                                  Text('8',
                                      style: robotoBold.copyWith(
                                          fontSize: Dimensions.fs32,
                                          color:
                                              Theme.of(context).primaryColor)),
                                ],
                              ),
                              Spacer(),
                              Image.asset(
                                ManagerAssets.totalTaskImage,
                                fit: BoxFit.cover,
                              )
                            ],
                          ),
                          SizedBox(height: Dimensions.p12),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${'reminder'.tr} ', // السطر الأول
                                  style: robotoSemiBold.copyWith(
                                      fontSize: Dimensions.fs14,
                                      color: ManagerColors.orange),
                                ),
                                TextSpan(
                                  text: 'reminder_message'.tr, // السطر الثاني
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
                    padding: EdgeInsets.all(Dimensions.p16),
                    isBorder: false,
                    borderRadius: Dimensions.r8,
                    child: Padding(
                      padding: EdgeInsets.all(Dimensions.p16),
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
                                onTap: (){
                                  Get.toNamed(RouteHelper.getDetailedOperationHistoryRoute());
                                },
                                child: Text(
                                  'see_all'.tr,
                                  style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fs14,
                                      decoration: TextDecoration.underline),
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
                          SizedBox(
                            height: Dimensions.p16,
                          ),

                          /// ----- Grid العناصر الأربعة -----
                          GridView.count(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            crossAxisCount: 2,
                            crossAxisSpacing: Dimensions.p8,
                            mainAxisSpacing: Dimensions.p8,
                            childAspectRatio: 1.6,
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
                                  ManagerColors.orange,
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
                    padding: EdgeInsets.all(Dimensions.p16),
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
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                            Image.asset(ManagerAssets.amountToBeDeliveredImage)
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
                          padding: EdgeInsets.all(Dimensions.p16),
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
            Container(
              width: double.infinity,
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
                icon: SvgPicture.asset(ManagerAssets.downloadIcon),
                buttonText: 'download_payment_statement'.tr,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBox(String count, String title, Color bgColor, Color textColor,
      String image) {
    return CustomCard(
      padding: EdgeInsets.all(Dimensions.p12),
      fillColor: bgColor, // خلفية فاتحة
      isBorder: false,
      borderRadius: Dimensions.r12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// النصوص
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: robotoBold.copyWith(
                      color: textColor, fontSize: Dimensions.fs15)),
              Text(count,
                  style: robotoBold.copyWith(
                      color: textColor, fontSize: Dimensions.fs16)),
            ],
          ),
          Image.asset(image),
        ],
      ),
    );
  }
}
