import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doghree_rider/api/error_message.dart';
import 'package:doghree_rider/api/error_type.dart';
import 'package:doghree_rider/features/wallet/controllers/wallet_controller.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/order/domain/models/order_action_result.dart';
import 'package:doghree_rider/features/order/domain/models/order_details_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/domain/models/update_status_body_model.dart';
import 'package:doghree_rider/features/order/domain/models/ignore_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_cancellation_body.dart';
import 'package:doghree_rider/features/order/widgets/deliver_without_photos_dialog.dart';
import 'package:doghree_rider/common/models/list_load.dart';
import 'package:doghree_rider/common/models/load_failure.dart';
import 'package:doghree_rider/helper/first_load_notice.dart';
import 'package:doghree_rider/helper/image_upload_rules.dart';
import 'package:doghree_rider/helper/order_ringing.dart';
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

  /// True while a history page after page 1 is loading (bottom spinner).
  bool _paginate = false;
  bool get paginate => _paginate;

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

  /// The order the proof photos belong to (audit row 24). Photos are sent
  /// only with `delivered` of this order.
  int? _proofOrderId;
  int? get proofOrderId => _proofOrderId;

  bool _isAccepting = false;
  bool _isUpdatingStatus = false;

  /// Orders whose "no longer available" message was already shown, so a
  /// later poll closes Order Details without a second message.
  final Set<int> _goneAnnounced = {};

  /// Every message of the order actions goes through here. Production always
  /// uses [showCustomSnackBar]; tests replace it only to count messages.
  @visibleForTesting
  void Function(String? message, {bool isError}) toast = showCustomSnackBar;

  /// Opens the proof picker. Tests replace it; production uses image_picker
  /// with the same quality and width as before.
  @visibleForTesting
  Future<XFile?> Function(ImageSource source) pickImageFn = _pickProofImage;

  static Future<XFile?> _pickProofImage(ImageSource source) => ImagePicker()
      .pickImage(source: source, imageQuality: 70, maxWidth: 1600);

  /// Asks whether to deliver without the photos after the server refused a
  /// too-large request (D-09). Tests replace it.
  @visibleForTesting
  Future<bool> Function() confirmDeliverWithoutPhotos = _askDeliverWithoutPhotos;

  static Future<bool> _askDeliverWithoutPhotos() async =>
      await Get.dialog<bool>(const DeliverWithoutPhotosDialog(),
          barrierDismissible: false) ==
      true;

  bool _pickingProof = false;
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

  /// One picker at a time, one message per failure, and a cancel is silent
  /// (audit rows 46, 49). A photo is kept only if it passes
  /// [ImageUploadRules], so nothing unusable reaches the delivery request.
  Future<void> pickPrescriptionImage(
      {required bool isRemove, required bool isCamera}) async {
    if (isRemove) {
      _pickedPrescriptions = [];
      update();
      return;
    }
    if (_pickingProof) return;
    if (_pickedPrescriptions.length >= 5) {
      if (Get.isDialogOpen == true) Get.back();
      toast('maximum_proof_images_5'.tr);
      return;
    }
    _pickingProof = true;
    try {
      final XFile? xFile =
          await pickImageFn(isCamera ? ImageSource.camera : ImageSource.gallery);
      if (xFile == null) return;
      final ImageCheck check = await ImageUploadRules.check(xFile);
      if (check != ImageCheck.ok) {
        toast(ImageUploadRules.messageKey(check).tr);
        return;
      }
      addProofImage(xFile);
      if (Get.isDialogOpen == true) Get.back();
    } catch (e) {
      if (kDebugMode) debugPrint('proof pick failed: ${e.runtimeType}');
      toast(pickFailureKey(classifyPickError(e)).tr);
    } finally {
      _pickingProof = false;
      update();
    }
  }

  /// Order Details calls this when it opens. Photos picked for the same order
  /// are kept; opening another order clears them.
  void prepareProofFor(int? orderId) {
    if (orderId != _proofOrderId) {
      _pickedPrescriptions = [];
      _proofOrderId = orderId;
    }
  }

  /// Adds a proof photo for the order prepared by [prepareProofFor].
  void addProofImage(XFile file) {
    if (_pickedPrescriptions.length >= 5) return;
    _pickedPrescriptions.add(file);
  }

  void _clearProof() {
    _pickedPrescriptions = [];
    _proofOrderId = null;
  }

  String get _noInternetText => ErrorMessages.getMessage(ErrorType.noInternet);

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

  /// Silent fetch (polled every 10s). It never navigates and never shows a
  /// message: the caller decides (audit row 21). A failed poll keeps the
  /// order on screen; the model is cleared only when another order loads.
  Future<OrderFetch> getOrderWithId(int? orderId) async {
    if (_orderModel?.id != orderId) {
      _orderModel = null;
    }
    OrderFetch outcome = OrderFetch.failed;
    LoadFailure? failure = LoadFailure.serverProblem;
    try {
      final OrderFetchResult result =
          await orderServiceInterface.getOrderWithId(orderId);
      outcome = result.outcome;
      if (outcome == OrderFetch.found && result.order != null) {
        _orderModel = result.order;
        failure = null;
      } else if (outcome == OrderFetch.found) {
        outcome = OrderFetch.failed;
      } else if (outcome == OrderFetch.notFound) {
        failure = null;
      } else {
        failure = LoadFailures.fromStatus(result.statusCode);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('getOrderWithId failed: ${e.runtimeType}');
      outcome = OrderFetch.failed;
    }
    _orderFetchFailure = failure;
    update();
    return outcome;
  }

  /// Why the last GET order failed (audit row 94): no internet, a server
  /// problem (5xx, 403, HTML, a body that does not parse), or null after a
  /// success, a not-found and a 401 (the session sheet is the message).
  LoadFailure? _orderFetchFailure;
  LoadFailure? get orderFetchFailure => _orderFetchFailure;

  /// Shows "no longer available" once per order. Returns false when it was
  /// already shown (for example by a failed status change).
  bool announceOrderGone(int? orderId) {
    if (orderId == null || _goneAnnounced.contains(orderId)) return false;
    _goneAnnounced.add(orderId);
    toast('order_no_longer_available'.tr, isError: true);
    return true;
  }

  /// True when page 1 of My Orders failed. The screen shows NoInternetScreen
  /// with Retry instead of an endless spinner (audit row 13).
  bool _completedOrdersFailed = false;
  bool get completedOrdersFailed => _completedOrdersFailed;

  // ---------- My Orders history paging (audit rows 26, 27) ----------
  // The controller owns the paging. Whether more pages exist comes from the
  // pages the server returned, never from the list shown on the phone, which
  // is shorter because orders without items are filtered out.

  /// The last page that loaded. Retry asks for the page after it.
  int _lastLoadedPage = 0;

  /// The server `total_size` of the history.
  int _historyTotal = 0;

  /// A page came back empty (or without `orders`): the history ended.
  bool _historyEnded = false;

  /// The last page failed. Only Retry continues, so scrolling never repeats
  /// the request on its own.
  bool _historyPageFailed = false;
  bool get historyPageFailed => _historyPageFailed;

  /// At most one page request is in flight.
  bool _pageInFlight = false;

  /// Page 1 bumps this. A page that comes back for an older generation is
  /// thrown away, so a late page cannot land on a refreshed list.
  int _historyGeneration = 0;

  bool get hasMoreHistory =>
      !_historyEnded &&
      _lastLoadedPage > 0 &&
      _lastLoadedPage * AppConstants.historyPageLimit < _historyTotal;

  bool get canLoadMoreHistory =>
      _completedOrderList != null &&
      !_pageInFlight &&
      !_historyPageFailed &&
      hasMoreHistory;

  /// Whether the screen should load the next page by itself because the
  /// list is too short to scroll.
  bool historyNeedsFill({required bool fillsScreen}) =>
      !fillsScreen && canLoadMoreHistory;

  /// Page 1 (also Retry and pull-to-refresh). A page above 1 is the same as
  /// [loadNextHistoryPage].
  Future<void> getCompletedOrders(int offset, {bool willUpdate = true}) async {
    if (offset != 1) {
      await loadNextHistoryPage();
      return;
    }
    final int generation = ++_historyGeneration;
    _completedOrderList = null;
    _completedOrdersFailed = false;
    _lastLoadedPage = 0;
    _historyTotal = 0;
    _historyEnded = false;
    _historyPageFailed = false;
    _pageInFlight = false;
    _paginate = false;
    if (willUpdate) {
      update();
    }
    await _loadFirstCompletedPage(generation);
  }

  /// Page 1 always ends in a list or the failed state, never a stuck spinner.
  Future<void> _loadFirstCompletedPage(int generation) async {
    List<OrderModel>? loaded;
    PaginatedOrderModel? page;
    try {
      page = await orderServiceInterface.getCompletedOrderList(1);
    } catch (e) {
      if (kDebugMode) debugPrint('getCompletedOrders failed: ${e.runtimeType}');
    }
    if (generation != _historyGeneration) return; // a newer load took over
    if (page != null) {
      final List<OrderModel> rows = page.orders ?? <OrderModel>[];
      loaded = _uniqueValid(rows, const <OrderModel>[]);
      _lastLoadedPage = 1;
      _historyTotal = page.totalSize ?? 0;
      _historyEnded = rows.isEmpty;
    }
    _completedOrderList = loaded;
    _completedOrdersFailed = loaded == null;
    update();
  }

  /// Loads the page after the last loaded one. Never more than one request
  /// in flight, nothing after a failed page or at the end, and the bottom
  /// loader always stops.
  Future<void> loadNextHistoryPage() async {
    if (!canLoadMoreHistory) return;
    final int generation = _historyGeneration;
    final int page = _lastLoadedPage + 1;
    _pageInFlight = true;
    _paginate = true;
    update();
    try {
      final PaginatedOrderModel? result =
          await orderServiceInterface.getCompletedOrderList(page);
      if (generation != _historyGeneration) return;
      if (result == null) {
        _historyPageFailed = true;
        return;
      }
      final List<OrderModel> rows = result.orders ?? <OrderModel>[];
      _completedOrderList = [
        ...?_completedOrderList,
        ..._uniqueValid(rows, _completedOrderList ?? const <OrderModel>[]),
      ];
      _lastLoadedPage = page;
      if (result.totalSize != null) _historyTotal = result.totalSize!;
      if (rows.isEmpty) _historyEnded = true;
    } catch (e) {
      if (kDebugMode) debugPrint('history page failed: ${e.runtimeType}');
      if (generation == _historyGeneration) _historyPageFailed = true;
    } finally {
      if (generation == _historyGeneration) {
        _pageInFlight = false;
        _paginate = false;
        update();
      }
    }
  }

  /// The footer Retry button: asks for the same page again.
  Future<void> retryHistoryPage() async {
    _historyPageFailed = false;
    await loadNextHistoryPage();
  }

  /// Orders with items (or parcels) that are not in [existing] yet. When
  /// orders move between pages the same id can arrive twice.
  List<OrderModel> _uniqueValid(
      List<OrderModel> rows, List<OrderModel> existing) {
    final Set<int?> seen = existing.map((o) => o.id).toSet();
    final List<OrderModel> result = <OrderModel>[];
    for (final OrderModel order in rows) {
      if (!_isValidOrder(order)) continue;
      if (order.id != null && !seen.add(order.id)) continue;
      result.add(order);
    }
    return result;
  }

  /// Silent load of the running orders (D-12). With [announce], a failure
  /// while no list was ever loaded shows exactly one message
  /// (FirstLoadNotice); with data on screen it stays silent. Push, resume and
  /// after-action refreshes never announce.
  Future<LoadAttempt> getCurrentOrders({bool announce = false}) async {
    final bool hadData = _currentOrderList != null;
    LoadAttempt attempt;
    try {
      final ListLoad<OrderModel> load =
          await orderServiceInterface.getCurrentOrders();
      final List<OrderModel>? currentOrderList = load.list;
      if (currentOrderList != null) {
        _currentOrderList = [];

        // ✅ فلترة Orders بدون items
        List<OrderModel> validOrders =
            currentOrderList.where(_isValidOrder).toList();

        _currentOrderList!.addAll(validOrders);
      }
      attempt = LoadAttempt(
          ok: load.ok,
          hadData: hadData,
          statusCode: load.statusCode,
          message: load.message);
    } catch (e) {
      if (kDebugMode) debugPrint('getCurrentOrders failed: ${e.runtimeType}');
      attempt = LoadAttempt(ok: false, hadData: hadData, statusCode: 0);
    }
    update();
    if (announce) {
      final String? message = FirstLoadNotice.pick([attempt]);
      if (message != null) toast(message);
    }
    return attempt;
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
      // No pending request left: nothing may ring (audit row 36).
      if (_latestOrderList!.isEmpty) OrderRinging.stop();
    }

    update();
  }

  /// One request per tap, one message, and the loader always stops
  /// (audit rows 22, 23, 24). The outcome comes from the status and
  /// errors[0].code only (backend R4).
  Future<bool> updateOrderStatus(OrderModel currentOrder, String status,
      {bool back = false,
      String? reason,
      bool? parcel = false,
      bool gotoDashboard = false}) async {
    if (_isUpdatingStatus) return false;
    _isUpdatingStatus = true;
    _isLoading = true;
    update();
    bool success = false;
    try {
      if (!await _transitionAllowed(currentOrder, status)) {
        await _onOrderChanged(currentOrder.id);
        return false;
      }

      final bool sendProof = status == AppConstants.delivered &&
          _proofOrderId != null &&
          _proofOrderId == currentOrder.id;
      // A photo that can no longer be read is dropped, never blocking the
      // delivery (B-02).
      final List<XFile> usable =
          sendProof ? await _usableProofImages() : const <XFile>[];
      final bool skippedPhotos =
          sendProof && usable.length < _pickedPrescriptions.length;
      final List<MultipartBody> multiParts = usable.isEmpty
          ? <MultipartBody>[]
          : orderServiceInterface.prepareOrderProofImages(usable);
      // Built once: a resend without photos reuses exactly these fields.
      final UpdateStatusBodyModel updateStatusBody = UpdateStatusBodyModel(
        orderId: currentOrder.id,
        status: status,
        reason: reason,
        otp: status == AppConstants.delivered ||
                (parcel == true && status == AppConstants.pickedUp)
            ? _otp
            : null,
      );
      OrderActionResult<StatusOutcome> result = await orderServiceInterface
          .updateOrderStatus(updateStatusBody, multiParts);

      // A 401 already ended the session (ApiChecker.checkSession).
      if (result.statusCode == 401) return false;

      String? successMessage =
          skippedPhotos ? 'delivered_some_photos_skipped'.tr : null;

      if (multiParts.isNotEmpty) {
        final ProofFailure failure =
            classifyProofFailure(result.statusCode, result.codes);
        if (failure != ProofFailure.none) {
          // The server state is unknown: look, never resend by itself.
          final OrderFetchResult fresh =
              await orderServiceInterface.getOrderWithId(currentOrder.id);
          final OrderModel? freshOrder = fresh.order;
          if (freshOrder != null && _orderModel?.id == freshOrder.id) {
            _orderModel = freshOrder;
          }
          if (fresh.outcome == OrderFetch.notFound) {
            await _onOrderChanged(currentOrder.id);
            return false;
          }
          if (fresh.outcome != OrderFetch.found || freshOrder == null) {
            toast('delivery_unconfirmed'.tr);
            return false;
          }
          if (freshOrder.orderStatus == AppConstants.delivered) {
            success = true;
            _onStatusUpdated(currentOrder, status,
                back: back,
                gotoDashboard: gotoDashboard,
                clearProof: true,
                message: freshOrder.hasProofImages
                    ? 'order_delivered'.tr
                    : 'delivered_photos_not_saved'.tr);
            return true;
          }
          if (freshOrder.orderStatus != AppConstants.pickedUp) {
            await _onOrderChanged(currentOrder.id);
            return false;
          }
          // Still picked up: the delivery did not happen (yet).
          switch (failure) {
            case ProofFailure.serverError:
              toast('order_not_delivered_retry'.tr);
              return false;
            case ProofFailure.unknown:
            case ProofFailure.none:
              // The request may still finish on the server.
              toast('delivery_unconfirmed'.tr);
              return false;
            case ProofFailure.tooLarge:
              if (!await confirmDeliverWithoutPhotos()) return false;
              // The refused request never ran, so this is the first send.
              result = await orderServiceInterface
                  .updateOrderStatus(updateStatusBody, const <MultipartBody>[]);
              if (result.statusCode == 401) return false;
              successMessage = null;
              break;
          }
        }
      }

      switch (result.outcome) {
        case StatusOutcome.updated:
          success = true;
          _onStatusUpdated(currentOrder, status,
              back: back,
              gotoDashboard: gotoDashboard,
              clearProof: sendProof,
              message: successMessage ?? result.message);
          break;
        case StatusOutcome.orderChanged:
          await _onOrderChanged(currentOrder.id);
          break;
        case StatusOutcome.notDelivered:
          // Not delivered: status and photos stay, the sheet stays for a retry.
          toast(result.message ?? 'order_not_delivered_retry'.tr);
          break;
        case StatusOutcome.otpMismatch:
          toast('otp_not_matched'.tr);
          break;
        case StatusOutcome.noInternet:
          toast(_noInternetText);
          break;
        case StatusOutcome.failed:
          toast(result.message ?? 'error_occurred'.tr);
          break;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('updateOrderStatus failed: ${e.runtimeType}');
      toast('error_occurred'.tr);
      success = false;
    } finally {
      _isUpdatingStatus = false;
      _isLoading = false;
      update();
    }
    return success;
  }

  /// The success path of a status change (D-04), shared with a delivery the
  /// D-09 check found already done.
  void _onStatusUpdated(OrderModel currentOrder, String status,
      {required bool back,
      required bool gotoDashboard,
      required bool clearProof,
      String? message}) {
    if (Get.isBottomSheetOpen == true || Get.isDialogOpen == true) {
      Get.back(result: true);
    }
    if (back) {
      Get.back();
    }
    if (gotoDashboard) {
      Get.offAllNamed(RouteHelper.getInitialRoute(fromOrderDetails: true));
    }
    currentOrder.orderStatus = status;
    // Only the delivered order's own photos are spent.
    if (clearProof) _clearProof();
    Get.find<ProfileController>().getProfile();
    if (Get.isRegistered<WalletController>()) {
      Get.find<WalletController>().getWallet();
    }
    getCurrentOrders();
    toast(message, isError: false);
  }

  /// The bound proof photos that can still be read and uploaded.
  Future<List<XFile>> _usableProofImages() async {
    final List<XFile> usable = <XFile>[];
    for (final XFile file in _pickedPrescriptions) {
      if (await ImageUploadRules.check(file) == ImageCheck.ok) {
        usable.add(file);
      }
    }
    return usable;
  }

  /// The R4 transition map. A stale local status is not trusted: when it
  /// refuses the move, the order is fetched again and the fresh status
  /// decides. If the fetch fails, the request is sent and the server decides.
  Future<bool> _transitionAllowed(OrderModel order, String status) async {
    if (riderMayMoveTo(order.orderStatus, status,
        isParcel: order.orderType == 'parcel')) {
      return true;
    }
    final OrderFetchResult fresh =
        await orderServiceInterface.getOrderWithId(order.id);
    if (fresh.outcome == OrderFetch.failed || fresh.order == null) {
      return fresh.outcome != OrderFetch.notFound;
    }
    final OrderModel freshOrder = fresh.order!;
    if (_orderModel?.id == freshOrder.id) _orderModel = freshOrder;
    order.orderStatus = freshOrder.orderStatus;
    return riderMayMoveTo(freshOrder.orderStatus, status,
        isParcel: freshOrder.orderType == 'parcel');
  }

  /// The order changed on the server (403 invalid_status_transition or
  /// not_found, 404 order, or a refused move): one message, then refresh the
  /// running orders and the open order silently.
  Future<void> _onOrderChanged(int? orderId) async {
    if (Get.isBottomSheetOpen == true || Get.isDialogOpen == true) {
      Get.back(result: false);
    }
    toast('order_status_changed'.tr);
    await getCurrentOrders();
    if (orderId != null && _orderModel?.id == orderId) {
      final OrderFetch fetch = await getOrderWithId(orderId);
      // The message above already told the rider; the screen closes quietly.
      if (fetch == OrderFetch.notFound) _goneAnnounced.add(orderId);
    }
    getLatestOrders();
  }

  /// Why the order lines failed to load (audit row 95). Order Details shows
  /// it as a Retry state, which is the one message (audit row 25): no toast.
  /// Null while loading, after a success and after a 401 (session sheet).
  LoadFailure? _detailsFailure;
  LoadFailure? get detailsFailure => _detailsFailure;

  int _detailsRequestId = 0;
  int? _detailsInFlight;

  /// Silent. The screen shows a loader while it runs (the failure is cleared
  /// first) and the Retry state when it fails. One request per order at a
  /// time; an answer for an older request is dropped. The parcel branch also
  /// rebuilds the screen (audit row 28).
  Future<void> getOrderDetails(int? orderID, bool parcel) async {
    if (parcel) {
      _detailsRequestId++;
      _detailsInFlight = null;
      _detailsFailure = null;
      _orderDetailsModel = [];
      update();
      return;
    }
    if (_detailsInFlight == orderID && _orderDetailsModel == null) return;
    final int requestId = ++_detailsRequestId;
    _detailsInFlight = orderID;
    _orderDetailsModel = null;
    _detailsFailure = null;
    update();
    LoadFailure? failure = LoadFailure.serverProblem;
    List<OrderDetailsModel>? details;
    try {
      final OrderDetailsResult result =
          await orderServiceInterface.getOrderDetails(orderID);
      if (result.details != null) {
        details = [...result.details!];
        failure = null;
      } else {
        failure = LoadFailures.fromStatus(result.statusCode);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('getOrderDetails failed: ${e.runtimeType}');
    } finally {
      if (requestId == _detailsRequestId) {
        _detailsInFlight = null;
        _orderDetailsModel = details;
        _detailsFailure = failure;
        update();
      }
    }
  }

  /// Accepts by order id, never by list index (audit row 19), and never
  /// navigates (audit row 20): the caller closed its confirm sheet already.
  /// One message per tap; [AcceptOutcome.offline] shows none, the caller
  /// prompts the online toggle.
  Future<AcceptOutcome> acceptOrder(OrderModel order) async {
    if (!_isValidOrder(order)) {
      toast('cannot_accept_order_without_items'.tr);
      return AcceptOutcome.failed;
    }
    if (_isAccepting) return AcceptOutcome.failed;
    _isAccepting = true;
    _isLoading = true;
    update();
    AcceptOutcome outcome = AcceptOutcome.failed;
    try {
      final OrderActionResult<AcceptOutcome> result =
          await orderServiceInterface.acceptOrder(order.id);
      outcome = result.outcome;
      if (result.statusCode == 401) return outcome;
      switch (outcome) {
        case AcceptOutcome.accepted:
          OrderRinging.stop();
          _latestOrderList?.removeWhere((o) => o.id == order.id);
          _currentOrderList ??= [];
          if (!_currentOrderList!.any((o) => o.id == order.id)) {
            _currentOrderList!.add(order);
          }
          break;
        case AcceptOutcome.taken:
          OrderRinging.stop();
          _latestOrderList?.removeWhere((o) => o.id == order.id);
          toast('order_no_longer_available'.tr);
          await getLatestOrders();
          break;
        case AcceptOutcome.offline:
          break;
        case AcceptOutcome.refused:
          toast(result.message ?? 'error_occurred'.tr);
          break;
        case AcceptOutcome.noInternet:
          toast(_noInternetText);
          break;
        case AcceptOutcome.failed:
          toast(result.message ?? 'error_occurred'.tr);
          await getLatestOrders();
          break;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('acceptOrder failed: ${e.runtimeType}');
      toast('error_occurred'.tr);
      outcome = AcceptOutcome.failed;
    } finally {
      _isAccepting = false;
      _isLoading = false;
      update();
    }
    return outcome;
  }

  void getIgnoreList() {
    _ignoredRequests = [];
    _ignoredRequests.addAll(orderServiceInterface.getIgnoreList());
  }

  void removePrescriptionImage(XFile file) {
    _pickedPrescriptions.remove(file);
    update();
  }

  /// Ignores by order id, never by list index (audit row 97): a poll may
  /// change the list while the confirm sheet or the map screen is open.
  void ignoreOrderById(int? orderId) {
    OrderRinging.stop();
    if (orderId == null) return;
    if (!_ignoredRequests.any((i) => i.id == orderId)) {
      _ignoredRequests.add(IgnoreModel(id: orderId, time: DateTime.now()));
    }
    _latestOrderList?.removeWhere((o) => o.id == orderId);
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
