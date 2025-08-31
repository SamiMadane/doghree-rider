import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';

class CashInHandSection extends StatelessWidget {
  final ProfileController profileController;

  const CashInHandSection({
    super.key,
    required this.profileController,
  });

  @override
  Widget build(BuildContext context) {
    return profileController.profileModel != null
        ? profileController.profileModel!.earnings == 1
            ? CustomCard(
                margin: const EdgeInsets.only(
                    top: Dimensions.p20),
                height: 95,
                width: MediaQuery.of(context).size.width,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.all(
                  Dimensions.p16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            PriceConverterHelper.convertPrice(
                              profileController.profileModel!.cashInHands,
                            ),
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fs18,
                            ),
                          ),
                          Text(
                            'cash_in_your_hand'.tr,
                            style: robotoBold.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fs16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomButtonWidget(
                      width: 100,
                      height: 40,
                      isBold: true,
                      fontSize: Dimensions.fs14,
                      buttonText: 'view_details'.tr,
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: () => Get.toNamed(
                        RouteHelper.getCashInHandRoute(),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox()
        : Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(
              height: 85,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.r10),
                color: Theme.of(context).shadowColor,
              ),
            ),
          );
  }
}
