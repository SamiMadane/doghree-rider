import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/features/profile/controllers/profile_controller.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/features/cash_in_hand/widgets/transaction_bottom_sheet.dart';
import 'package:wefrh_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/helper/price_converter_helper.dart';

class BalanceOverviewSection extends StatelessWidget {
  final ProfileController profileController;

  const BalanceOverviewSection({Key? key, required this.profileController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Current Balance Section
        CustomCard(
          width: context.width,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.r4),
            child: Stack(
              children: [
                // المحتوى النصي
                Padding(
                  padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      Flexible(
                        flex: 3, 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'current_balance'.tr,
                              style: textRegular().copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: Dimensions.fs16,
                              ),
                            ),
                             SizedBox(
                                height: Dimensions.h16),
                            Text(
                              PriceConverterHelper.convertPrice(
                                  profileController
                                      .profileModel!.payableBalance),
                              style: textBold().copyWith(
                                fontSize: Dimensions.fs28,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                            ),
                             SizedBox(
                                height: Dimensions.h16),
                            CustomButtonWidget(
                              buttonText: 'transaction'.tr,
                              fontSize: Dimensions.fs16,
                              backgroundColor: Theme.of(context).primaryColor,
                              onPressed: () {
                                showCustomBottomSheet(
                                    child: TransactionBottomSheet());
                              },
                            )
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        child: Container(), 
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.5,
                      maxHeight: 150, 
                    ),
                    child: Image.asset(
                      ManagerAssets.balanceImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: Dimensions.h20),

        /// Cash Info Section
        Row(
          children: [
            Expanded(
              child: CustomCard(
                padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'cash_in_hand'.tr,
                      style: textRegular().copyWith(
                        color: Theme.of(context).disabledColor,
                        fontSize: Dimensions.fs14,
                      ),
                    ),
                    SizedBox(height: Dimensions.h16),
                    Text(
                      PriceConverterHelper.convertPrice(
                          profileController.profileModel!.cashInHands),
                      style: textBold().copyWith(
                        fontSize: Dimensions.fs16,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: Dimensions.w16),
            Expanded(
              child: CustomCard(
                padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'total_withdrawn'.tr,
                      style: textRegular().copyWith(
                        color: Theme.of(context).disabledColor,
                        fontSize: Dimensions.fs14,
                      ),
                    ),
                    SizedBox(height: Dimensions.h16),
                    Text(
                      PriceConverterHelper.convertPrice(
                          profileController.profileModel!.totalWithdrawn),
                      style: textBold().copyWith(
                        fontSize: Dimensions.fs16,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
