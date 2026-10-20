import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/order/domain/models/order_details_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/domain/models/update_status_body_model.dart';
import 'package:doghree_rider/features/order/domain/models/ignore_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_cancellation_body.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/order/domain/services/order_service_interface.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:doghree_rider/doghree_map/map_safety.dart';

class OrderController extends GetxController implements GetxService {
  final OrderServiceInterface orderServiceInterface;
  OrderController({required this.orderServiceInterface});

  List<OrderModel>? _currentOrderList;
  List<OrderModel>? get currentOrderList => _currentOrderList;

  List<OrderModel>? _completedOrderList;
  List<OrderModel>? get completedOrderList => _completedOrderList;

  List<OrderModel>? _latestOrderList;
  List<OrderModel>? get latestOrderList => _latestOrderList;

  List<OrderDetailsModel>? _orderDetailsModel;
  List<OrderDetailsModel>? get orderDetailsModel => _orderDetailsModel;

  List<IgnoreModel> _ignoredRequests = [];
  List<IgnoreModel> get ignoredRequests => _ignoredRequests;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _otp = '';
  String get otp => _otp;

  bool _paginate = false;
  bool get paginate => _paginate;

  int? _pageSize;
  int? get pageSize => _pageSize;

  List<int> _offsetList = [];
  List<int> get offsetList => _offsetList;

  int _offset = 1;
  int get offset => _offset;

  OrderModel? _orderModel;
  OrderModel? get orderModel => _orderModel;

  String? _cancelReason = '';
  String? get cancelReason => _cancelReason;

  List<CancellationData>? _orderCancelReasons;
  List<CancellationData>? get orderCancelReasons => _orderCancelReasons;

  bool _showDeliveryImageField = false;
  bool get showDeliveryImageField => _showDeliveryImageField;

  List<XFile> _pickedPrescriptions = [];
  List<XFile> get pickedPrescriptions => _pickedPrescriptions;
  // ---------- خريطة معاينة الطلب ----------
  LatLng? _mapMyPoint;
  LatLng? get mapMyPoint => _mapMyPoint;

  LatLng? _mapDestPoint;
  LatLng? get mapDestPoint => _mapDestPoint;

  List<LatLng> _mapRoute = [];
  List<LatLng> get mapRoute => _mapRoute;

  bool _mapRouteIsApprox = true;
  bool get mapRouteIsApprox => _mapRouteIsApprox;

  bool _mapIsLoadingLocation = true;
  bool get mapIsLoadingLocation => _mapIsLoadingLocation;

  // الـ controller دائم (GetxService)، فنرقّم كل طلب حتى لا تُكتب نتيجة قديمة فوق الجديدة
  int _mapRequestId = 0;

  Future<void> initOrderMap(
      {required String latitude, required String longitude}) async {
    final int requestId = ++_mapRequestId;
    _mapDestPoint = parsePoint(latitude, longitude);
    _mapMyPoint = null;
    _mapRoute = [];
    _mapRouteIsApprox = true;
    _mapIsLoadingLocation = true;
    update(['order_map']);

    LatLng? my = await orderServiceInterface.getCurrentPoint();
    if (my == null) {
      // آخر موقع أرسله التطبيق للسيرفر
      final loc = Get.find<ProfileController>().recordLocationBody;
      my = parsePoint(loc?.latitude, loc?.longitude);
    }
    if (requestId != _mapRequestId) return;
    _mapMyPoint = my;
    _mapIsLoadingLocation = false;
    update(['order_map']);

    final LatLng? dest = _mapDestPoint;
    if (my == null || dest == null) return;

    final List<LatLng>? real = await orderServiceInterface.getRoute(my, dest);
    if (requestId != _mapRequestId) return;
    _mapRouteIsApprox = orderServiceInterface.isApproxRoute(real);

    try {
      _mapRoute = orderServiceInterface.buildRoute(my, dest, real);
    } catch (e) {
      debugPrint('buildRoute failed: $e');
      _mapRoute = [my, dest]; // خط مستقيم بدل لا شيء
    }
    update(['order_map']);
  }

  /// يُستدعى من dispose() للويدجت (بدون update)
  void clearOrderMap() {
    _mapRequestId++;
    _mapMyPoint = null;
    _mapDestPoint = null;
    _mapRoute = [];
  }

  void changeDeliveryImageStatus({bool isUpdate = true}) {
    _showDeliveryImageField = !_showDeliveryImageField;
    if (isUpdate) {
      update();
    }
  }

  void pickPrescriptionImage(
      {required bool isRemove, required bool isCamera}) async {
    if (isRemove) {
      _pickedPrescriptions = [];
    } else {
      if (_pickedPrescriptions.length >= 5) {
        if (Get.isDialogOpen ?? false) Get.back();
        showCustomSnackBar('maximum_proof_images_5'.tr);
        return;
      }
      XFile? xFile = await ImagePicker().pickImage(
          source: isCamera ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 70,
          maxWidth: 1600);
      if (xFile != null) {
        _pickedPrescriptions.add(xFile);
        if (Get.isDialogOpen!) {
          Get.back();
        }
      }
      update();
    }
  }

  void initLoading() {
    _isLoading = false;
    update();
  }

  void setOrderCancelReason(String? reason) {
    _cancelReason = reason;
    update();
  }

  Future<void> getOrderCancelReasons() async {
    List<CancellationData>? orderCancelReasons =
        await orderServiceInterface.getCancelReasons();
    if (orderCancelReasons != null) {
      _orderCancelReasons = [];
      _orderCancelReasons!.addAll(orderCancelReasons);
    }
    update();
  }

  Future<void> getOrderWithId(int? orderId) async {
    _orderModel = null;
    Response response = await orderServiceInterface.getOrderWithId(orderId);
    if (response.statusCode == 200) {
      _orderModel = OrderModel.fromJson(response.body);
    } else {
      Navigator.pop(Get.context!);
      await Get.find<OrderController>().getCurrentOrders();
    }
    update();
  }

  Future<void> getCompletedOrders(int offset, {bool willUpdate = true}) async {
    if (offset == 1) {
      _offsetList = [];
      _offset = 1;
      _completedOrderList = null;
      if (willUpdate) {
        update();
      }
    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      PaginatedOrderModel? paginatedOrderModel =
          await orderServiceInterface.getCompletedOrderList(offset);
      if (paginatedOrderModel != null) {
        if (offset == 1) {
          _completedOrderList = [];
        }

        // ✅ فلترة Orders بدون items
        List<OrderModel> validOrders =
            paginatedOrderModel.orders!.where(_isValidOrder).toList();

        _completedOrderList!.addAll(validOrders);
        _pageSize = paginatedOrderModel.totalSize;
        _paginate = false;
        update();
      }
    } else {
      if (_paginate) {
        _paginate = false;
        update();
      }
    }
  }

  void showBottomLoader() {
    _paginate = true;
    update();
  }

  void setOffset(int offset) {
    _offset = offset;
  }

  Future<void> getCurrentOrders() async {
    List<OrderModel>? currentOrderList =
        await orderServiceInterface.getCurrentOrders();
    if (currentOrderList != null) {
      _currentOrderList = [];

      // ✅ فلترة Orders بدون items
      List<OrderModel> validOrders =
          currentOrderList.where(_isValidOrder).toList();

      _currentOrderList!.addAll(validOrders);
    }
    update();
  }

  /// ✅ فلترة Orders: استبعاد orders بدون items
  bool _isValidOrder(OrderModel order) {
    // للـ parcel orders: نقبلها دائماً
    if (order.orderType == 'parcel') {
      return true;
    }
    // للـ delivery orders: نتأكد من وجود items
    return order.detailsCount != null && order.detailsCount! > 0;
  }

  Future<void> getLatestOrders() async {
    List<OrderModel>? latestOrderList =
        await orderServiceInterface.getLatestOrders();
    if (latestOrderList != null) {
      _latestOrderList = [];
      List<int?> ignoredIdList =
          orderServiceInterface.prepareIgnoreIdList(_ignoredRequests);

      // معالجة Orders + فلترة Orders الفاضية
      List<OrderModel> processedOrders = orderServiceInterface
          .processLatestOrders(latestOrderList, ignoredIdList);

      // ✅ فلترة Orders بدون items
      List<OrderModel> validOrders =
          processedOrders.where(_isValidOrder).toList();

      _latestOrderList!.addAll(validOrders);
    }
    update();
  }

  Future<bool> updateOrderStatus(OrderModel currentOrder, String status,
      {bool back = false,
      String? reason,
      bool? parcel = false,
      bool gotoDashboard = false}) async {
    _isLoading = true;
    update();
    List<MultipartBody> multiParts =
        orderServiceInterface.prepareOrderProofImages(_pickedPrescriptions);
    UpdateStatusBodyModel updateStatusBody = UpdateStatusBodyModel(
      orderId: currentOrder.id,
      status: status,
      reason: reason,
      otp: status == AppConstants.delivered ||
              (parcel! && status == AppConstants.pickedUp)
          ? _otp
          : null,
    );
    ResponseModel responseModel = await orderServiceInterface.updateOrderStatus(
        updateStatusBody, multiParts);
    Get.back(result: responseModel.isSuccess);
    if (responseModel.isSuccess) {
      if (back) {
        Get.back();
      }
      if (gotoDashboard) {
        Get.offAllNamed(RouteHelper.getInitialRoute(fromOrderDetails: true));
      }
      Get.find<ProfileController>().getProfile();
      if (Get.isRegistered<CashInHandController>()) {
        Get.find<CashInHandController>().getWallet();
      }
      getCurrentOrders();
      currentOrder.orderStatus = status;
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
      getLatestOrders();
    }
    _isLoading = false;
    update();
    return responseModel.isSuccess;
  }

  Future<void> getOrderDetails(int? orderID, bool parcel) async {
    if (parcel) {
      _orderDetailsModel = [];
    } else {
      _orderDetailsModel = null;

      try {
        List<OrderDetailsModel>? orderDetailsModel =
            await orderServiceInterface.getOrderDetails(orderID);

        if (orderDetailsModel != null) {
          _orderDetailsModel = [];
          _orderDetailsModel!.addAll(orderDetailsModel);
        } else {
          // ✅ معالجة حالة order details = null
          showCustomSnackBar('order_details_not_found'.tr, isError: true);
        }
      } catch (e) {
        // ✅ معالجة خطأ 404
        showCustomSnackBar('failed_to_load_order_details'.tr, isError: true);
        debugPrint('🔴 Error loading order details: $e');
      }

      update();
    }
  }

  Future<bool> acceptOrder(
      int? orderID, int index, OrderModel orderModel) async {
    // ✅ التحقق من صحة Order قبل القبول
    if (!_isValidOrder(orderModel)) {
      showCustomSnackBar('cannot_accept_order_without_items'.tr, isError: true);
      return false;
    }

    _isLoading = true;
    update();
    ResponseModel responseModel =
        await orderServiceInterface.acceptOrder(orderID);
    Get.back();
    if (responseModel.isSuccess) {
      _latestOrderList!.removeAt(index);
      _currentOrderList!.add(orderModel);
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    _isLoading = false;
    update();
    return responseModel.isSuccess;
  }

  void getIgnoreList() {
    _ignoredRequests = [];
    _ignoredRequests.addAll(orderServiceInterface.getIgnoreList());
  }

  void removePrescriptionImage(XFile file) {
    _pickedPrescriptions.remove(file);
    update();
  }

  void ignoreOrder(int index) {
    _ignoredRequests.add(
        IgnoreModel(id: _latestOrderList![index].id, time: DateTime.now()));
    _latestOrderList!.removeAt(index);
    orderServiceInterface.setIgnoreList(_ignoredRequests);
    update();
  }

  void removeFromIgnoreList() {
    List<IgnoreModel> tempList = orderServiceInterface.tempList(
        Get.find<SplashController>().currentTime, _ignoredRequests);
    _ignoredRequests = [];
    _ignoredRequests.addAll(tempList);
    orderServiceInterface.setIgnoreList(_ignoredRequests);
  }

  void setOtp(String otp) {
    _otp = otp;
    if (otp != '') {
      update();
    }
  }
}
