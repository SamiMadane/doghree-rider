import 'package:wefrh_rider/api/api_client.dart';
import 'package:wefrh_rider/features/order/domain/models/ignore_model.dart';
import 'package:wefrh_rider/features/order/domain/models/update_status_body_model.dart';
import 'package:wefrh_rider/interface/repository_interface.dart';

abstract class OrderRepositoryInterface implements RepositoryInterface {
  Future<dynamic> getCancelReasons();
  Future<dynamic> getCompletedOrderList(int offset);
  Future<dynamic> getLatestOrders();
  Future<dynamic> updateOrderStatus(UpdateStatusBodyModel updateStatusBody, List<MultipartBody> proofAttachment);
  Future<dynamic> getOrderDetails(int? orderID);
  Future<dynamic> acceptOrder(int? orderID);
  List<IgnoreModel> getIgnoreList();
  void setIgnoreList(List<IgnoreModel> ignoreList);
}