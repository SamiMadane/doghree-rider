import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/features/cash_in_hand/widgets/transaction_bottom_sheet.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/features/cash_in_hand/widgets/wallet_attention_alert_widget.dart';

class CashInHandScreen extends StatefulWidget {
  const CashInHandScreen({super.key});

  @override
  State<CashInHandScreen> createState() => _CashInHandScreenState();
}

class _CashInHandScreenState extends State<CashInHandScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    Get.find<ProfileController>().getProfile();
    Get.find<CashInHandController>().getWalletPaymentList();
    Get.find<CashInHandController>().getWalletProvidedEarningList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Get.find<ProfileController>().profileModel == null) {
      Get.find<ProfileController>().getProfile();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
        title: 'balance'.tr,
        isBackButtonExist: true,
      ),
      body: GetBuilder<CashInHandController>(builder: (cashInHandController) {
        return GetBuilder<ProfileController>(builder: (profileController) {
          return (profileController.profileModel != null &&
                  cashInHandController.transactions != null)
              ? RefreshIndicator(
                  onRefresh: () async {
                    profileController.getProfile();
                    Get.find<CashInHandController>().getWalletPaymentList();
                    Get.find<CashInHandController>()
                        .getWalletProvidedEarningList();
                    return await Future.delayed(const Duration(seconds: 1));
                  },
                  child: Container(
                    color: Theme.of(context).cardColor,
                    margin: const EdgeInsets.only(
                        top: Dimensions.paddingSizeDefault),
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(children: [
                            CustomCard(
                              width: context.width,
                              fillColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions
                                    .radiusSmall), // نفس نصف قطر البطاقة
                                child: Stack(
                                  children: [
                                    Row(
                                      textDirection: TextDirection.ltr,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // العمود الأول للنصوص
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                                Dimensions.paddingSizeDefault),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'current_balance'.tr,
                                                  style: robotoMedium.copyWith(
                                                      color: Theme.of(context)
                                                          .disabledColor,
                                                      fontSize: Dimensions
                                                          .fontSizeLarge),
                                                ),
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeDefault),
                                                Text(
                                                  PriceConverterHelper
                                                      .convertPrice(
                                                          profileController
                                                              .profileModel!
                                                              .payableBalance),
                                                  style: robotoBold.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeOverLarge,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .color),
                                                ),
                                                SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeDefault),
                                                CustomButtonWidget(
                                                  buttonText: 'transaction'.tr,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .primaryColor,
                                                  onPressed: () {
                                                    showCustomBottomSheet(
                                                        child:
                                                            TransactionBottomSheet());
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),

                                        // العمود الثاني للصورة
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment
                                                .bottomRight, // الصورة تبقى يمين وسفلي
                                            child: Image.asset(
                                              ManagerAssets.balanceImage,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefault),
                            Row(children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeDefault),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault),
                                    color: Theme.of(context).cardColor,
                                    boxShadow: Get.isDarkMode
                                        ? null
                                        : [
                                            BoxShadow(
                                                color: Colors.grey[200]!,
                                                spreadRadius: 0.5,
                                                blurRadius: 5)
                                          ],
                                  ),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          PriceConverterHelper.convertPrice(
                                              profileController
                                                  .profileModel!.cashInHands),
                                          style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeSmall),
                                        Text('cash_in_hand'.tr,
                                            style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .disabledColor)),
                                      ]),
                                ),
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeDefault),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeDefault),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault),
                                    color: Theme.of(context).cardColor,
                                    boxShadow: Get.isDarkMode
                                        ? null
                                        : [
                                            BoxShadow(
                                                color: Colors.grey[200]!,
                                                spreadRadius: 0.5,
                                                blurRadius: 5)
                                          ],
                                  ),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          PriceConverterHelper.convertPrice(
                                              profileController.profileModel!
                                                  .totalWithdrawn),
                                          style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeSmall),
                                        Text('total_withdrawn'.tr,
                                            style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .disabledColor)),
                                      ]),
                                ),
                              ),
                            ]),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: Dimensions.paddingSizeExtraLarge),
                              child: Row(children: [
                                InkWell(
                                  onTap: () {
                                    if (cashInHandController.selectedIndex !=
                                        0) {
                                      cashInHandController.setIndex(0);
                                    }
                                  },
                                  hoverColor: Colors.transparent,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('payment_history'.tr,
                                            style: robotoMedium.copyWith(
                                              color: cashInHandController
                                                          .selectedIndex ==
                                                      0
                                                  ? Colors.blue
                                                  : Theme.of(context)
                                                      .disabledColor,
                                            )),
                                        const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall),
                                        Container(
                                          height: 3,
                                          width: 110,
                                          margin: const EdgeInsets.only(
                                              top: Dimensions
                                                  .paddingSizeExtraSmall),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusSmall),
                                            color: cashInHandController
                                                        .selectedIndex ==
                                                    0
                                                ? Colors.blue
                                                : null,
                                          ),
                                        ),
                                      ]),
                                ),
                                const SizedBox(
                                    width: Dimensions.paddingSizeSmall),
                                InkWell(
                                  onTap: () {
                                    if (cashInHandController.selectedIndex !=
                                        1) {
                                      cashInHandController.setIndex(1);
                                    }
                                  },
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('wallet_provided_earning'.tr,
                                            style: robotoMedium.copyWith(
                                              color: cashInHandController
                                                          .selectedIndex ==
                                                      1
                                                  ? Colors.blue
                                                  : Theme.of(context)
                                                      .disabledColor,
                                            )),
                                        const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall),
                                        Container(
                                          height: 3,
                                          width: 150,
                                          margin: const EdgeInsets.only(
                                              top: Dimensions
                                                  .paddingSizeExtraSmall),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusSmall),
                                            color: cashInHandController
                                                        .selectedIndex ==
                                                    1
                                                ? Colors.blue
                                                : null,
                                          ),
                                        ),
                                      ]),
                                ),
                              ]),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("transaction_history".tr,
                                      style: robotoMedium),
                                  (cashInHandController.selectedIndex == 0 &&
                                              cashInHandController
                                                  .transactions!.isEmpty) ||
                                          (cashInHandController.selectedIndex ==
                                                  1 &&
                                              cashInHandController
                                                  .walletProvidedTransactions!
                                                  .isEmpty)
                                      ? const SizedBox()
                                      : InkWell(
                                          onTap: () {
                                            if (cashInHandController
                                                    .selectedIndex ==
                                                0) {
                                              Get.toNamed(RouteHelper
                                                  .getTransactionHistoryRoute());
                                            }
                                            if (cashInHandController
                                                    .selectedIndex ==
                                                1) {
                                              Get.toNamed(RouteHelper
                                                  .getWalletProvidedEarningRoute());
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 10, 0, 10),
                                            child: Text('view_all'.tr,
                                                style: robotoMedium.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                )),
                                          ),
                                        ),
                                ]),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            if (cashInHandController.selectedIndex == 0)
                              cashInHandController.transactions != null
                                  ? cashInHandController
                                          .transactions!.isNotEmpty
                                      ? ListView.builder(
                                          itemCount: cashInHandController
                                                      .transactions!.length >
                                                  25
                                              ? 25
                                              : cashInHandController
                                                  .transactions!.length,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return Column(children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: Dimensions
                                                            .paddingSizeLarge),
                                                child: Row(children: [
                                                  Expanded(
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            PriceConverterHelper
                                                                .convertPrice(
                                                                    cashInHandController
                                                                        .transactions![
                                                                            index]
                                                                        .amount),
                                                            style: robotoMedium
                                                                .copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeDefault),
                                                            textDirection:
                                                                TextDirection
                                                                    .ltr,
                                                          ),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          Text(
                                                              '${'paid_via'.tr} ${cashInHandController.transactions![index].method?.replaceAll('_', ' ').capitalize ?? ''}',
                                                              style:
                                                                  robotoRegular
                                                                      .copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeExtraSmall,
                                                                color: Theme.of(
                                                                        context)
                                                                    .disabledColor,
                                                              )),
                                                        ]),
                                                  ),
                                                  Text(
                                                    cashInHandController
                                                        .transactions![index]
                                                        .paymentTime
                                                        .toString(),
                                                    style:
                                                        robotoRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                            color: Theme.of(
                                                                    context)
                                                                .disabledColor),
                                                  ),
                                                ]),
                                              ),
                                              const Divider(height: 1),
                                            ]);
                                          },
                                        )
                                      : Center(
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 250),
                                              child: Text(
                                                  'no_transaction_found'.tr)))
                                  : const Center(
                                      child: Padding(
                                          padding: EdgeInsets.only(top: 250),
                                          child: CircularProgressIndicator())),
                            if (cashInHandController.selectedIndex == 1)
                              cashInHandController.walletProvidedTransactions !=
                                      null
                                  ? cashInHandController
                                          .walletProvidedTransactions!
                                          .isNotEmpty
                                      ? ListView.builder(
                                          itemCount: cashInHandController
                                                      .walletProvidedTransactions!
                                                      .length >
                                                  25
                                              ? 25
                                              : cashInHandController
                                                  .walletProvidedTransactions!
                                                  .length,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return Column(children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: Dimensions
                                                            .paddingSizeLarge),
                                                child: Row(children: [
                                                  Expanded(
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            PriceConverterHelper
                                                                .convertPrice(
                                                                    cashInHandController
                                                                        .walletProvidedTransactions![
                                                                            index]
                                                                        .amount),
                                                            style: robotoMedium
                                                                .copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeDefault),
                                                            textDirection:
                                                                TextDirection
                                                                    .ltr,
                                                          ),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          Text(
                                                              '${'wallet'.tr} ${cashInHandController.walletProvidedTransactions![index].method?.replaceAll('_', ' ').capitalize ?? ''}',
                                                              style:
                                                                  robotoRegular
                                                                      .copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeExtraSmall,
                                                                color: Theme.of(
                                                                        context)
                                                                    .disabledColor,
                                                              )),
                                                        ]),
                                                  ),
                                                  Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          cashInHandController
                                                              .walletProvidedTransactions![
                                                                  index]
                                                              .paymentTime
                                                              .toString(),
                                                          style: robotoRegular.copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                              color: Theme.of(
                                                                      context)
                                                                  .disabledColor),
                                                        ),
                                                        const SizedBox(
                                                            height: Dimensions
                                                                .paddingSizeExtraSmall),
                                                        Text(
                                                            cashInHandController
                                                                .walletProvidedTransactions![
                                                                    index]
                                                                .status!
                                                                .tr,
                                                            style: robotoRegular
                                                                .copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                              color: cashInHandController.walletProvidedTransactions![index].status ==
                                                                      'approved'
                                                                  ? Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                  : cashInHandController
                                                                              .walletProvidedTransactions![
                                                                                  index]
                                                                              .status ==
                                                                          'denied'
                                                                      ? Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .error
                                                                      : Colors
                                                                          .blue,
                                                            )),
                                                      ]),
                                                ]),
                                              ),
                                              const Divider(height: 1),
                                            ]);
                                          },
                                        )
                                      : Center(
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 250),
                                              child: Text(
                                                  'no_transaction_found'.tr)))
                                  : const Center(
                                      child: Padding(
                                          padding: EdgeInsets.only(top: 250),
                                          child: CircularProgressIndicator())),
                          ]),
                        ),
                      ),
                      (profileController.profileModel!.overFlowWarning! ||
                              profileController
                                  .profileModel!.overFlowBlockWarning!)
                          ? WalletAttentionAlertWidget(
                              isOverFlowBlockWarning: profileController
                                  .profileModel!.overFlowBlockWarning!)
                          : const SizedBox(),
                    ]),
                  ),
                )
              : const Center(child: CircularProgressIndicator());
        });
      }),
    );
  }
}
