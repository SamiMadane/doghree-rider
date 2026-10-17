import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/features/profile/controllers/profile_controller.dart';
import 'package:wefrh_rider/helper/price_converter_helper.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/helper/route_helper.dart';

class CashInHandSection extends StatefulWidget {
  final ProfileController profileController;

  const CashInHandSection({
    super.key,
    required this.profileController,
  });

  @override
  State<CashInHandSection> createState() => _CashInHandSectionState();
}

class _CashInHandSectionState extends State<CashInHandSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Get.find<CashInHandController>().getWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profileController.profileModel;

    if (profile == null) {
      return Shimmer(
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
    if (profile.earnings != 1) return const SizedBox();

    return GetBuilder<CashInHandController>(builder: (c) {
      final wallet = c.wallet;
      final double cash = wallet?.cashInHand ?? profile.cashInHands ?? 0;

      return CustomCard(
        margin: EdgeInsets.only(top: Dimensions.h20),
        height: cash > 0 ? 120 : 95,
        width: MediaQuery.of(context).size.width,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.w16, vertical: Dimensions.h16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    wallet == null
                        ? '—'
                        : PriceConverterHelper.convertPrice(
                            wallet.availableBalance),
                    style: textBold().copyWith(fontSize: Dimensions.fs18),
                  ),
                  Text(
                    'available_to_withdraw'.tr,
                    style: textBold().copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fs16,
                    ),
                  ),
                  if (cash > 0)
                    Text(
                      '${'cash_in_your_hand'.tr}: ${PriceConverterHelper.convertPrice(cash)}',
                      style: textRegular().copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fs12,
                      ),
                    ),
                ],
              ),
            ),
            CustomButtonWidget(
              width: 100,
              height: 40,
              isBold: true,
              autoWidth: true,
              fontSize: Dimensions.fs14,
              buttonText: 'view_details'.tr,
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () => Get.toNamed(RouteHelper.getCashInHandRoute()),
            ),
          ],
        ),
      );
    });
  }
}