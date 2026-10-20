import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/features/task/widgets/embedding_rate.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';

class DetailsStatisticsScreen extends StatelessWidget {
  const DetailsStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'detailed_statistics'.tr),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
              margin: EdgeInsets.only(top: Dimensions.h16),
              color: Theme.of(context).cardColor,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Total tasks
                    CustomCard(
                      padding: EdgeInsets.zero,
                      isBorder: false,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'total_tasks_today'.tr,
                                      style: textBold().copyWith(
                                        fontSize: Dimensions.fs16,
                                      ),
                                    ),
                                    SizedBox(height: Dimensions.h12),
                                    Text(
                                      '8',
                                      style: textBold().copyWith(
                                        fontSize: Dimensions.fs32,
                                      ),
                                    ),
                                    SizedBox(height: Dimensions.h12),
                                    Text(
                                      'Turn in all collections to the supervisor before shift ends.'
                                          .tr,
                                      style: textRegular().copyWith(
                                        fontSize: Dimensions.fs12,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Image.asset(
                              ManagerAssets.totalTaskImage,
                              width: 140,
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomCenter,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: Dimensions.h16),
                    CustomCard(
                      padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
                      isBorder: false,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      child: EmbeddingRateWidget(
                        title: 'Embedding Rate',
                        percentage: 60,
                        onSeeAllPressed: () {
                          Get.toNamed(
                              RouteHelper.getDetailedOperationHistoryRoute());
                        },
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.h16,
                    ),

                    /// List of beneficiaries
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      crossAxisCount: 2,
                      crossAxisSpacing: Dimensions.w16,
                      childAspectRatio: 1.4,
                      children: [
                        _statusBox("23", "Delivered",
                            ManagerAssets.deliveredImage, context),
                        _statusBox("3", "Postponed",
                            ManagerAssets.postponedImage, context),
                        _statusBox("1", "Waiting", ManagerAssets.waitingImage,
                            context),
                        _statusBox("1", "Problem", ManagerAssets.problemImage,
                            context),
                      ],
                    ),

                    SizedBox(height: Dimensions.h16),

                    /// Amount to be delivered
                    CustomCard(
                      padding: EdgeInsets.zero,
                      isBorder: false,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          ManagerAssets.flagIcon,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                        ),
                                        SizedBox(width: Dimensions.w4),
                                        Text('amount_to_be_delivered'.tr,
                                            style: textBold().copyWith(
                                              fontSize: Dimensions.fs16,
                                            )),
                                      ],
                                    ),
                                    SizedBox(height: Dimensions.h8),
                                    Text(PriceConverterHelper.convertPrice(47),
                                        style: textSemiBold().copyWith(
                                          fontSize: Dimensions.fs22,
                                        )),
                                    SizedBox(height: Dimensions.h8),
                                    Text(
                                      'handover_message'.tr,
                                      style: textRegular().copyWith(
                                          fontSize: Dimensions.fs13,
                                          color: Theme.of(context).hintColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Image.asset(
                                ManagerAssets.amountToBeDeliveredImage,
                                width: 100,
                                fit: BoxFit.cover,
                                alignment: Alignment.bottomCenter,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// زر التحميل أسفل الشاشة
          SafeArea(
            child: Container(
              padding: EdgeInsets.all(16),
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
                icon: SvgPicture.asset(
                  ManagerAssets.downloadIcon,
                  height: 30,
                  width: 30,
                ),
                buttonText: 'download_payment_statement'.tr,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBox(
      String count, String title, String image, BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.zero,
      fillColor: Theme.of(context).scaffoldBackgroundColor,
      isBorder: false,
      child: SizedBox(
        height: 110, // ارتفاع ثابت لكل البوكسات
        child: IntrinsicHeight(
          child: Row(
            children: [
              // نص مرن مع تقليم
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textBold().copyWith(fontSize: Dimensions.fs14),
                      ),
                      SizedBox(height: Dimensions.h4),
                      Text(
                        count,
                        style: textBold().copyWith(fontSize: Dimensions.fs16),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: Dimensions.w8),
              // الصورة ثابتة الحجم
              Column(
                children: [
                  SizedBox(),
                  Spacer(),
                  Image.asset(
                    image,
                    width: 70,
                    height: 90,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
