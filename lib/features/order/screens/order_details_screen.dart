import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/features/chat/domain/models/conversation_model.dart';
import 'package:doghree_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/models/order_details_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/widgets/additional_note_section.dart';
import 'package:doghree_rider/features/order/widgets/delivery_images_section.dart';
import 'package:doghree_rider/features/order/widgets/info_card_section.dart';
import 'package:doghree_rider/features/order/widgets/map_preview_section.dart';
import 'package:doghree_rider/features/order/widgets/order_action_buttons_section.dart';
import 'package:doghree_rider/features/order/widgets/order_id_section.dart';
import 'package:doghree_rider/features/order/widgets/order_info_section.dart';
import 'package:doghree_rider/features/order/widgets/order_item_widget.dart';
import 'package:doghree_rider/features/order/widgets/order_proof_section.dart';
import 'package:doghree_rider/features/order/widgets/order_summary_widget.dart';
import 'package:doghree_rider/features/order/widgets/payment_details_section.dart';
import 'package:doghree_rider/features/order/widgets/prescription_section.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/theme_extension.dart';

/// Final statuses: the order can no longer change.
bool _isFinishedStatus(String? status) =>
    status == 'delivered' ||
    status == 'failed' ||
    status == 'canceled' ||
    status == 'refunded';

class OrderDetailsScreen extends StatefulWidget {
  final int? orderId;
  final bool? isRunningOrder;
  final int? orderIndex;
  final bool fromNotification;
  final bool fromLocationScreen;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.isRunningOrder,
    required this.orderIndex,
    this.fromNotification = false,
    this.fromLocationScreen = false,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with WidgetsBindingObserver {
  Timer? _timer;

  /// Refreshes the order status every 10s (a store confirming the order, etc.).
  /// Stops by itself once the order reaches a final status.
  void _startApiCalling() {
    _timer?.cancel();
    final int? id = widget.orderId;
    if (id == null) return;

    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      final OrderController c = Get.find<OrderController>();
      final OrderModel? current = c.orderModel;
      if (current != null &&
          current.id == id &&
          _isFinishedStatus(current.orderStatus)) {
        timer.cancel();
        return;
      }
      c.getOrderWithId(id);
    });
  }

  Future<void> _loadData() async {
    final OrderController c = Get.find<OrderController>();
    c.pickPrescriptionImage(isRemove: true, isCamera: false);
    await c.getOrderWithId(widget.orderId);
    if (!mounted) return;

    final OrderModel? order = c.orderModel;
    if (order == null) return;

    c.getOrderDetails(widget.orderId, order.orderType == 'parcel');
    await c.getLatestOrders();
    if (!mounted) return;

    if (c.showDeliveryImageField) {
      c.changeDeliveryImageStatus(isUpdate: false);
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
    } else if (state == AppLifecycleState.resumed) {
      _startApiCalling();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _goBack() {
    if (widget.fromNotification || widget.fromLocationScreen) {
      Get.offAllNamed(RouteHelper.getInitialRoute());
    } else {
      Get.back();
    }
  }

  void _showItems(
    BuildContext context,
    OrderModel order,
    List<OrderDetailsModel> details,
  ) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    showCustomBottomSheet(
      maxHeight: MediaQuery.of(context).size.height * 0.8,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.w16,
          vertical: Dimensions.h16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'order_items'.tr,
              style: textSemiBold().copyWith(fontSize: Dimensions.fs16),
            ),
            SizedBox(height: Dimensions.h16),
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.w16,
                  vertical: Dimensions.h16,
                ),
                shrinkWrap: true,
                itemCount: details.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      OrderItemWidget(order: order, orderDetails: details[index]),
                      if (index != details.length - 1) ...[
                        SizedBox(height: Dimensions.h16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final int dashCount =
                                (constraints.maxWidth / 9).floor();
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                dashCount,
                                (_) => Container(
                                  width: 5,
                                  height: 2,
                                  color: customColor.strock2,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: Dimensions.h16),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (widget.fromNotification || widget.fromLocationScreen) {
          Future.delayed(const Duration(milliseconds: 0), () async {
            await Get.offAllNamed(RouteHelper.getInitialRoute());
          });
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBarWidget(
          title: '${'order'.tr} #${widget.orderId}',
          onBackPressed: _goBack,
        ),
        body: SafeArea(
          child: SizedBox.expand(
            child: Container(
              color: theme.cardColor,
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.w16,
                vertical: Dimensions.h16,
              ),
              margin: EdgeInsets.only(top: Dimensions.h16),
              child: GetBuilder<OrderController>(builder: (orderController) {
                final OrderModel? order = orderController.orderModel;
                final details = orderController.orderDetailsModel;

                if (order == null || details == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final config = Get.find<SplashController>().configModel;
                final bool orderVerificationActive =
                    config?.orderDeliveryVerification ?? false;
                final bool cancelPermission =
                    config?.canceledByDeliveryman ?? false;

                // ----- status -----
                final bool parcel = order.orderType == 'parcel';
                final bool processing =
                    order.orderStatus == AppConstants.processing;
                final bool accepted = order.orderStatus == AppConstants.accepted;
                final bool confirmed =
                    order.orderStatus == AppConstants.confirmed;
                final bool handover = order.orderStatus == AppConstants.handover;
                final bool pickedUp = order.orderStatus == AppConstants.pickedUp;
                final bool isFinished = _isFinishedStatus(order.orderStatus);

                final bool showDeliveryConfirmImage =
                    pickedUp && (config?.dmPictureUploadStatus ?? false);
                final bool showBottomView = (parcel && accepted) ||
                    accepted ||
                    confirmed ||
                    processing ||
                    handover ||
                    pickedUp ||
                    (widget.isRunningOrder ?? true);
                final bool showSlider =
                    handover || pickedUp || (parcel && accepted);

                final bool showChatPermission =
                    order.storeBusinessModel == 'subscription'
                        ? order.storeChatPermission == 1
                        : true;

                // ----- money -----
                final double deliveryCharge = order.deliveryCharge ?? 0.0;
                final double dmTips = order.dmTips ?? 0.0;
                final double discount = (order.storeDiscountAmount ?? 0.0) +
                    (order.flashAdminDiscountAmount ?? 0.0) +
                    (order.flashStoreDiscountAmount ?? 0.0);
                final double tax = order.totalTaxAmount ?? 0.0;
                final bool taxIncluded = order.taxStatus ?? false;
                final double additionalCharge = order.additionalCharge ?? 0.0;
                final double extraPackagingAmount =
                    order.extraPackagingAmount ?? 0.0;
                final double referrerBonusAmount =
                    order.referrerBonusAmount ?? 0.0;
                final double couponDiscount = order.couponDiscountAmount ?? 0.0;

                double itemsPrice = 0;
                double addOns = 0;
                if (order.prescriptionOrder ?? false) {
                  final double orderAmount = order.orderAmount ?? 0.0;
                  itemsPrice = (orderAmount + discount) -
                      ((taxIncluded ? 0 : tax) +
                          deliveryCharge +
                          additionalCharge) -
                      dmTips;
                } else {
                  for (final OrderDetailsModel d in details) {
                    for (final AddOn a in d.addOns ?? const <AddOn>[]) {
                      addOns += ((a.price ?? 0) * (a.quantity ?? 0)).toDouble();
                    }
                    itemsPrice +=
                        ((d.price ?? 0) * (d.quantity ?? 0)).toDouble();
                  }
                }

                final double subTotal = itemsPrice + addOns;
                final double total = itemsPrice +
                    addOns -
                    discount +
                    (taxIncluded ? 0 : tax) +
                    deliveryCharge -
                    couponDiscount +
                    dmTips +
                    additionalCharge +
                    extraPackagingAmount -
                    referrerBonusAmount;

                // ----- map target -----
                final String? mapLat =
                    parcel ? order.deliveryAddress?.latitude : order.storeLat;
                final String? mapLng =
                    parcel ? order.deliveryAddress?.longitude : order.storeLng;
                final bool showMap =
                    !isFinished && mapLat != null && mapLng != null;

                final bool hasNote =
                    order.orderNote != null && order.orderNote!.isNotEmpty;

                final bool hasAttachments =
                    (Get.find<SplashController>()
                                .getModule(order.moduleType)
                                .orderAttachment ??
                            false) &&
                        order.orderAttachmentFullUrl != null &&
                        order.orderAttachmentFullUrl!.isNotEmpty;

                final bool hasProof = order.orderStatus == 'delivered' &&
                    order.orderProofFullUrl != null &&
                    order.orderProofFullUrl!.isNotEmpty;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(children: [
                    MapPreviewSection(
                      latitude: mapLat ?? '0',
                      longitude: mapLng ?? '0',
                      showMap: showMap,
                    ),
                    if (!isFinished)
                      OrderSummaryWidget(
                        order: order,
                        itemCount: details.length,
                        onShowItems: () => _showItems(context, order, details),
                      )
                    else ...[
                      OrderIdSection(orderId: widget.orderId.toString()),
                      SizedBox(height: Dimensions.h16),
                      OrderInfoSection(
                        orderController: orderController,
                        controllerOrderModel: order,
                        parcel: parcel,
                        showOrderCount: true,
                      ),
                    ],
                    SizedBox(height: Dimensions.h16),
                    InfoCardSection(
                      title: parcel ? 'sender_details'.tr : 'store_details'.tr,
                      address: parcel
                          ? order.deliveryAddress
                          : DeliveryAddress(address: order.storeAddress),
                      image: parcel
                          ? ManagerAssets.storeImage
                          : order.storeLogoFullUrl ?? '',
                      name: parcel
                          ? order.deliveryAddress?.contactPersonName
                          : order.storeName,
                      phone: parcel
                          ? order.deliveryAddress?.contactPersonNumber
                          : order.storePhone,
                      latitude:
                          parcel ? order.deliveryAddress?.latitude : order.storeLat,
                      longitude: parcel
                          ? order.deliveryAddress?.longitude
                          : order.storeLng,
                      showButton: !isFinished,
                      isStore: !parcel,
                      isChatAllow: showChatPermission,
                      messageOnTap: () => Get.toNamed(RouteHelper.getChatRoute(
                        notificationBody: NotificationBodyModel(
                          orderId: order.id,
                          vendorId:
                              details.isNotEmpty ? details.first.vendorId : null,
                        ),
                        user: User(
                          id: order.storeId,
                          fName: order.storeName,
                          imageFullUrl: order.storeLogoFullUrl,
                        ),
                      )),
                      order: order,
                    ),
                    SizedBox(height: Dimensions.h16),
                    InfoCardSection(
                      title: parcel
                          ? 'receiver_details'.tr
                          : 'customer_details'.tr,
                      address:
                          parcel ? order.receiverDetails : order.deliveryAddress,
                      image: parcel ? '' : order.customer?.imageFullUrl ?? '',
                      name: parcel
                          ? order.receiverDetails?.contactPersonName
                          : order.deliveryAddress?.contactPersonName,
                      phone: parcel
                          ? order.receiverDetails?.contactPersonNumber
                          : order.deliveryAddress?.contactPersonNumber,
                      latitude: parcel
                          ? order.receiverDetails?.latitude
                          : order.deliveryAddress?.latitude,
                      longitude: parcel
                          ? order.receiverDetails?.longitude
                          : order.deliveryAddress?.longitude,
                      showButton: !isFinished,
                      isStore: !parcel,
                      isChatAllow: showChatPermission,
                      messageOnTap: () {
                        final Customer? customer = order.customer;
                        if (customer == null) return;
                        Get.toNamed(RouteHelper.getChatRoute(
                          notificationBody: NotificationBodyModel(
                            orderId: order.id,
                            customerId: customer.id,
                          ),
                          // Chat goes to the customer account, not the delivery address contact.
                          user: User(
                            id: customer.id,
                            fName: customer.fName,
                            lName: customer.lName,
                            imageFullUrl: customer.imageFullUrl,
                          ),
                        ));
                      },
                      order: order,
                    ),
                    SizedBox(height: Dimensions.h16),
                    if (hasNote) ...[
                      AdditionalNoteSection(note: order.orderNote!),
                      SizedBox(height: Dimensions.h20),
                    ],
                    if (hasAttachments)
                      PrescriptionSection(
                        attachments: order.orderAttachmentFullUrl ?? [],
                        prescriptionNote: order.prescriptionNote,
                      ),
                    if (hasProof)
                      OrderProofSection(
                        proofImages: order.orderProofFullUrl ?? [],
                        orderStatus: order.orderStatus ?? '',
                      ),
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
                      tax: tax,
                      taxIncluded: taxIncluded,
                      total: total,
                    ),
                    DeliveryImagesSection(
                      order: order,
                      showDeliveryConfirmImage: showDeliveryConfirmImage,
                    ),
                    OrderActionButtonsSection(
                      order: order,
                      showDeliveryConfirmImage: showDeliveryConfirmImage,
                      showBottomView: showBottomView,
                      showSlider: showSlider,
                      accepted: accepted,
                      parcel: parcel,
                      processing: processing,
                      confirmed: confirmed,
                      pickedUp: pickedUp,
                      handover: handover,
                      orderVerificationActive: orderVerificationActive,
                      cancelPermission: cancelPermission,
                      fromLocationScreen: widget.fromLocationScreen,
                    ),
                  ]),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}