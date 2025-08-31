import 'dart:async';
import 'package:photo_view/photo_view.dart';

import 'package:sixam_mart_delivery/features/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/order/widgets/delivery_images_section.dart';
import 'package:sixam_mart_delivery/features/order/widgets/map_preview_section.dart';
import 'package:sixam_mart_delivery/features/order/widgets/order_action_buttons_section.dart';
import 'package:sixam_mart_delivery/features/order/widgets/order_id_section.dart';
import 'package:sixam_mart_delivery/features/order/widgets/order_info_section.dart';
import 'package:sixam_mart_delivery/features/order/widgets/payment_details_section.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/navigation_handler/controllers/navigation_handler_controller.dart';
import 'package:sixam_mart_delivery/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_delivery/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart_delivery/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart_delivery/features/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/helper/responsive_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/features/order/widgets/info_card_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int? orderId;
  final bool? isRunningOrder;
  final int? orderIndex;
  final bool fromNotification;
  final bool fromLocationScreen;
  const OrderDetailsScreen(
      {super.key,
      required this.orderId,
      required this.isRunningOrder,
      required this.orderIndex,
      this.fromNotification = false,
      this.fromLocationScreen = false});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with WidgetsBindingObserver {
  Timer? _timer;

  void _startApiCalling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      Get.find<OrderController>().getOrderWithId(widget.orderId!);
    });
  }

  Future<void> _loadData() async {
    Get.find<OrderController>()
        .pickPrescriptionImage(isRemove: true, isCamera: false);
    await Get.find<OrderController>().getOrderWithId(widget.orderId);
    Get.find<OrderController>().getOrderDetails(widget.orderId,
        Get.find<OrderController>().orderModel!.orderType == 'parcel');
    await Get.find<OrderController>().getLatestOrders();
    if (Get.find<OrderController>().showDeliveryImageField) {
      Get.find<OrderController>().changeDeliveryImageStatus(isUpdate: false);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _startApiCalling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    bool? cancelPermission = Get.find<NavigationHandlerController>()
        .configModel!
        .canceledByDeliveryman;
    bool selfDelivery =
        Get.find<ProfileController>().profileModel!.type != 'zone_wise';

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if ((widget.fromNotification || widget.fromLocationScreen)) {
          Future.delayed(const Duration(milliseconds: 0), () async {
            await Get.offAllNamed(RouteHelper.getInitialRoute());
          });
        } else {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBarWidget(
            title: '${'order'.tr} #${widget.orderId}',
            onBackPressed: () {
              if (widget.fromNotification || widget.fromLocationScreen) {
                Get.offAllNamed(RouteHelper.getInitialRoute());
              } else {
                Get.back();
              }
            }),
        body: SafeArea(
          child: SizedBox.expand(
            child: Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.all(Dimensions.p16),
              margin: const EdgeInsets.only(top: Dimensions.p16),
              child: GetBuilder<OrderController>(builder: (orderController) {
                OrderModel? controllerOrderModel = orderController.orderModel;

                bool restConfModel = Get.find<NavigationHandlerController>()
                        .configModel!
                        .orderConfirmationModel !=
                    'deliveryman';

                bool? parcel,
                    processing,
                    accepted,
                    confirmed,
                    handover,
                    pickedUp,
                    cod,
                    wallet,
                    partialPay,
                    offlinePay;

                bool orderVerificationActive =
                    Get.find<NavigationHandlerController>()
                            .configModel
                            ?.orderDeliveryVerification ??
                        false;

                late bool showBottomView;
                late bool showSlider;
                bool showDeliveryConfirmImage = false;

                double? deliveryCharge = 0;
                double itemsPrice = 0;
                double? discount = 0;
                double? couponDiscount = 0;
                double? tax = 0;
                double addOns = 0;
                double? dmTips = 0;
                double additionalCharge = 0;
                double extraPackagingAmount = 0;
                double referrerBonusAmount = 0;
                bool? isPrescriptionOrder = false;
                bool? taxIncluded = false;
                bool showChatPermission = true;
                OrderModel? order = controllerOrderModel;
                if (order != null &&
                    orderController.orderDetailsModel != null) {
                  deliveryCharge = order.deliveryCharge;
                  dmTips = order.dmTips;
                  isPrescriptionOrder = order.prescriptionOrder;
                  discount = order.storeDiscountAmount! +
                      order.flashAdminDiscountAmount! +
                      order.flashStoreDiscountAmount!;
                  tax = order.totalTaxAmount;
                  taxIncluded = order.taxStatus;
                  additionalCharge = order.additionalCharge!;
                  extraPackagingAmount = order.extraPackagingAmount!;
                  referrerBonusAmount = order.referrerBonusAmount!;
                  couponDiscount = order.couponDiscountAmount;
                  if (isPrescriptionOrder!) {
                    double orderAmount = order.orderAmount ?? 0;
                    itemsPrice = (orderAmount + discount) -
                        ((taxIncluded! ? 0 : tax!) +
                            deliveryCharge! +
                            additionalCharge) -
                        dmTips!;
                  } else {
                    for (OrderDetailsModel orderDetails
                        in orderController.orderDetailsModel!) {
                      for (AddOn addOn in orderDetails.addOns!) {
                        addOns = addOns + (addOn.price! * addOn.quantity!);
                      }
                      itemsPrice = itemsPrice +
                          (orderDetails.price! * orderDetails.quantity!);
                    }
                  }

                  if (order.storeBusinessModel == 'commission') {
                    showChatPermission = true;
                  } else if (order.storeBusinessModel == 'subscription') {
                    showChatPermission = order.storeChatPermission == 1;
                  } else {
                    showChatPermission = true;
                  }
                }
                double subTotal = itemsPrice + addOns;
                double total = itemsPrice +
                    addOns -
                    discount +
                    (taxIncluded! ? 0 : tax!) +
                    deliveryCharge! -
                    couponDiscount! +
                    dmTips! +
                    additionalCharge +
                    extraPackagingAmount -
                    referrerBonusAmount;

                if (controllerOrderModel != null) {
                  parcel = controllerOrderModel.orderType == 'parcel';
                  processing = controllerOrderModel.orderStatus ==
                      AppConstants.processing;
                  accepted =
                      controllerOrderModel.orderStatus == AppConstants.accepted;
                  confirmed = controllerOrderModel.orderStatus ==
                      AppConstants.confirmed;
                  handover =
                      controllerOrderModel.orderStatus == AppConstants.handover;
                  pickedUp =
                      controllerOrderModel.orderStatus == AppConstants.pickedUp;
                  cod =
                      controllerOrderModel.paymentMethod == 'cash_on_delivery';
                  wallet = controllerOrderModel.paymentMethod == 'wallet';
                  partialPay =
                      controllerOrderModel.paymentMethod == 'partial_payment';
                  offlinePay =
                      controllerOrderModel.paymentMethod == 'offline_payment';

                  showDeliveryConfirmImage = pickedUp &&
                      Get.find<NavigationHandlerController>()
                          .configModel!
                          .dmPictureUploadStatus!;
                  bool restConfModel = Get.find<NavigationHandlerController>()
                          .configModel!
                          .orderConfirmationModel !=
                      'deliveryman';
                  showBottomView = (parcel && accepted) ||
                      accepted ||
                      confirmed ||
                      processing ||
                      handover ||
                      pickedUp ||
                      (widget.isRunningOrder ?? true);
                  showSlider =
                      (cod && accepted && !restConfModel && !selfDelivery) ||
                          handover ||
                          pickedUp ||
                          (parcel && accepted);
                }

                return (orderController.orderDetailsModel != null &&
                        controllerOrderModel != null)
                    ? SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(children: [
                          MapPreviewSection(
                            latitude: parcel!
                                ? controllerOrderModel
                                    .deliveryAddress!.latitude!
                                : controllerOrderModel.storeLat!,
                            longitude: parcel
                                ? controllerOrderModel
                                    .deliveryAddress!.longitude!
                                : controllerOrderModel.storeLng!,
                            showMap: (controllerOrderModel.orderStatus !=
                                    'delivered' &&
                                controllerOrderModel.orderStatus != 'failed' &&
                                controllerOrderModel.orderStatus !=
                                    'canceled' &&
                                controllerOrderModel.orderStatus != 'refunded'),
                          ),

                          OrderIdSection(
                            orderId: widget.orderId.toString(),
                            isPaid:
                                controllerOrderModel.paymentStatus == 'paid',
                          ),
                          const SizedBox(height: Dimensions.p16),

                          OrderInfoSection(
                            orderController: orderController,
                            controllerOrderModel: controllerOrderModel,
                            parcel: parcel,
                            cod: cod,
                            wallet: wallet,
                            partialPay: partialPay,
                            offlinePay: offlinePay,
                            showOrderCount: true,
                            showPaymentType: false,
                          ),
                          SizedBox(
                            height: Dimensions.p16,
                          ),

                          InfoCardSection(
                            title: parcel
                                ? 'sender_details'.tr
                                : 'store_details'.tr,
                            address: parcel
                                ? controllerOrderModel.deliveryAddress
                                : DeliveryAddress(
                                    address: controllerOrderModel.storeAddress),
                            // TODO: PARCEL ORDER NOT HAVE IMAGE
                            image: parcel
                                ? 'controllerOrderModel.deliveryAddress.image'
                                : '${controllerOrderModel.storeLogoFullUrl}',
                            name: parcel
                                ? controllerOrderModel
                                    .deliveryAddress!.contactPersonName
                                : controllerOrderModel.storeName,
                            phone: parcel
                                ? controllerOrderModel
                                    .deliveryAddress!.contactPersonNumber
                                : controllerOrderModel.storePhone,
                            latitude: parcel
                                ? controllerOrderModel.deliveryAddress!.latitude
                                : controllerOrderModel.storeLat,
                            longitude: parcel
                                ? controllerOrderModel
                                    .deliveryAddress!.longitude
                                : controllerOrderModel.storeLng,
                            showButton: (controllerOrderModel.orderStatus !=
                                    'delivered' &&
                                controllerOrderModel.orderStatus != 'failed' &&
                                controllerOrderModel.orderStatus !=
                                    'canceled' &&
                                controllerOrderModel.orderStatus != 'refunded'),
                            isStore: parcel ? false : true,
                            isChatAllow: showChatPermission,
                            messageOnTap: () =>
                                Get.toNamed(RouteHelper.getChatRoute(
                              notificationBody: NotificationBodyModel(
                                orderId: controllerOrderModel.id,
                                vendorId: orderController
                                    .orderDetailsModel![0].vendorId,
                              ),
                              user: User(
                                id: controllerOrderModel.storeId,
                                fName: controllerOrderModel.storeName,
                                imageFullUrl:
                                    controllerOrderModel.storeLogoFullUrl,
                              ),
                            )),
                            order: order!,
                          ),
                          const SizedBox(height: Dimensions.p16),
                          InfoCardSection(
                            title: parcel
                                ? 'receiver_details'.tr
                                : 'customer_details'.tr,
                            address: parcel
                                ? controllerOrderModel.receiverDetails
                                : controllerOrderModel.deliveryAddress, 
                            image: parcel
                                ? ''
                                : controllerOrderModel.customer != null
                                    ? '${controllerOrderModel.customer!.imageFullUrl}'
                                    : '',
                            name: parcel
                                ? controllerOrderModel
                                    .receiverDetails!.contactPersonName
                                : controllerOrderModel
                                    .deliveryAddress!.contactPersonName,
                            phone: parcel
                                ? controllerOrderModel
                                    .receiverDetails!.contactPersonNumber
                                : controllerOrderModel
                                    .deliveryAddress!.contactPersonNumber,
                            latitude: parcel
                                ? controllerOrderModel.receiverDetails!.latitude
                                : controllerOrderModel
                                    .deliveryAddress!.latitude,
                            longitude: parcel
                                ? controllerOrderModel
                                    .receiverDetails!.longitude
                                : controllerOrderModel
                                    .deliveryAddress!.longitude,
                            showButton: controllerOrderModel.orderStatus !=
                                    'delivered' &&
                                controllerOrderModel.orderStatus != 'failed' &&
                                controllerOrderModel.orderStatus !=
                                    'canceled' &&
                                controllerOrderModel.orderStatus != 'refunded',
                            isStore: parcel ? false : true,
                            isChatAllow: showChatPermission,
                            messageOnTap: () =>
                                Get.toNamed(RouteHelper.getChatRoute(
                              notificationBody: NotificationBodyModel(
                                orderId: controllerOrderModel.id,
                                customerId: controllerOrderModel.customer!.id,
                              ),
                              // TODO: THIS CODE PASS CUSTOMAR INFO FOR CHAT , NOT DELIVARY ADDRESS INFO
                              user: User(
                                id: controllerOrderModel.customer!.id,
                                fName: controllerOrderModel.customer!.fName, // yousef
                                lName: controllerOrderModel.customer!.lName, // iwadi
                                imageFullUrl:
                                    controllerOrderModel.customer!.imageFullUrl,
                              ),
                            )),
                            order: order,
                          ),
                          const SizedBox(height: Dimensions.p16),

                          // TODO: ADD THIS SECTION FROM BACKENT TO TEST IT
                          (controllerOrderModel.orderNote != null &&
                                  controllerOrderModel.orderNote!.isNotEmpty)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      Text('additional_note'.tr,
                                          style: robotoRegular),
                                      const SizedBox(
                                          height: Dimensions.p10),
                                      Container(
                                        width: 1170,
                                        padding: const EdgeInsets.all(
                                            Dimensions.p10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              width: 1,
                                              color: Theme.of(context)
                                                  .disabledColor),
                                        ),
                                        child: Text(
                                          controllerOrderModel.orderNote!,
                                          style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fs12,
                                              color: Theme.of(context)
                                                  .disabledColor),
                                        ),
                                      ),
                                    ])
                              : const SizedBox(),
                          SizedBox(
                              height: (controllerOrderModel.orderNote != null &&
                                      controllerOrderModel
                                          .orderNote!.isNotEmpty)
                                  ? Dimensions.p20
                                  : 0),
                          (Get.find<NavigationHandlerController>()
                                      .getModule(
                                          controllerOrderModel.moduleType)
                                      .orderAttachment! &&
                                  controllerOrderModel.orderAttachmentFullUrl !=
                                      null &&
                                  controllerOrderModel
                                      .orderAttachmentFullUrl!.isNotEmpty)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      Text('prescription'.tr,
                                          style: robotoRegular),
                                      const SizedBox(
                                          height: Dimensions.p10),
                                      GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio: 1.5,
                                          crossAxisCount:
                                              ResponsiveHelper.isTab(context)
                                                  ? 5
                                                  : 3,
                                          mainAxisSpacing: 10,
                                          crossAxisSpacing: 5,
                                        ),
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: controllerOrderModel
                                            .orderAttachmentFullUrl!.length,
                                        itemBuilder:
                                            (BuildContext context, index) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8),
                                            child: InkWell(
                                              onTap: () => openDialog(
                                                  context,
                                                  controllerOrderModel
                                                          .orderAttachmentFullUrl![
                                                      index]),
                                              child: Center(
                                                  child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions.r4),
                                                child: CustomImageWidget(
                                                  image: controllerOrderModel
                                                          .orderAttachmentFullUrl![
                                                      index],
                                                  width: 100,
                                                  height: 100,
                                                ),
                                              )),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(
                                          height: Dimensions.p20),
                                    ])
                              : const SizedBox(),
                          (controllerOrderModel.orderStatus == 'delivered' &&
                                  controllerOrderModel.orderProofFullUrl !=
                                      null &&
                                  controllerOrderModel
                                      .orderProofFullUrl!.isNotEmpty)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      const SizedBox(
                                          height: Dimensions.p10),
                                      Text('order_proof'.tr,
                                          style: robotoRegular),
                                      const SizedBox(
                                          height: Dimensions.p10),
                                      GridView.builder(
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            childAspectRatio: 1.5,
                                            crossAxisCount:
                                                ResponsiveHelper.isTab(context)
                                                    ? 5
                                                    : 3,
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 5,
                                          ),
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: controllerOrderModel
                                              .orderProofFullUrl!.length,
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8),
                                              child: InkWell(
                                                onTap: () => openDialog(
                                                    context,
                                                    controllerOrderModel
                                                            .orderProofFullUrl![
                                                        index]),
                                                child: Center(
                                                    child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .r4),
                                                  child: CustomImageWidget(
                                                    image: controllerOrderModel
                                                            .orderProofFullUrl![
                                                        index],
                                                    width: 100,
                                                    height: 100,
                                                  ),
                                                )),
                                              ),
                                            );
                                          }),
                                      const SizedBox(
                                          height: Dimensions.p20),
                                    ])
                              : const SizedBox(),
                          const SizedBox(height: Dimensions.p16),

                          PaymentDetailsSection(
                            parcel: parcel,
                            itemsPrice: itemsPrice,
                            addOns: addOns,
                            subTotal: subTotal,
                            discount: discount,
                            couponDiscount: couponDiscount,
                            referrerBonusAmount: referrerBonusAmount,
                            deliveryCharge: deliveryCharge,
                            dmTips: dmTips,
                            extraPackagingAmount: extraPackagingAmount,
                            additionalCharge: additionalCharge,
                            tax: tax!,
                            taxIncluded: taxIncluded,
                            partialPay: partialPay!,
                            total: total,
                            restConfModel: restConfModel,
                          ),
                          DeliveryImagesSection(
                            order: controllerOrderModel,
                            showDeliveryConfirmImage: showDeliveryConfirmImage,
                          ),
                          OrderActionButtonsSection(
                            order: order,
                            showDeliveryConfirmImage: showDeliveryConfirmImage,
                            showBottomView: showBottomView,
                            showSlider: showSlider,
                            accepted: accepted!,
                            parcel: parcel,
                            processing: processing!,
                            confirmed: confirmed!,
                            cod: cod!,
                            partialPay: partialPay,
                            selfDelivery: selfDelivery,
                            pickedUp: pickedUp!,
                            handover: handover!,
                            restConfModel: restConfModel,
                            orderVerificationActive: orderVerificationActive,
                            cancelPermission: cancelPermission!,
                            fromLocationScreen: widget.fromLocationScreen,
                          ),
                        ]),
                      )
                    : const Center(child: CircularProgressIndicator());
              }),
            ),
          ),
        ),
      ),
    );
  }

  void openDialog(BuildContext context, String imageUrl) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.r16)),
            child: Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.r16),
                child: PhotoView(
                  tightMode: true,
                  imageProvider: NetworkImage(imageUrl),
                  heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    splashRadius: 5,
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                  )),
            ]),
          );
        },
      );
}
