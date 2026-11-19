import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/order/domain/models/ignore_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_action_result.dart';
import 'package:doghree_rider/features/order/domain/models/update_status_body_model.dart';
import 'package:doghree_rider/interface/repository_interface.dart';
import 'package:latlong2/latlong.dart' show LatLng;

abstract class OrderRepositoryInterface implements RepositoryInterface {
  Future<dynamic> getCancelReasons();
  Future<dynamic> getCompletedOrderList(int offset);
  Future<dynamic> getLatestOrders();
  Future<OrderActionResult<StatusOutcome>> updateOrderStatus(
      UpdateStatusBodyModel updateStatusBody,
      List<MultipartBody> proofAttachment);
  Future<OrderDetailsResult> getOrderDetails(int? orderID);
  Future<OrderActionResult<AcceptOutcome>> acceptOrder(int? orderID);
  @override
  Future<OrderFetchResult> get(int? id);
  List<IgnoreModel> getIgnoreList();
  void setIgnoreList(List<IgnoreModel> ignoreList);
  Future<dynamic> getRoute(LatLng origin, LatLng destination);
}
