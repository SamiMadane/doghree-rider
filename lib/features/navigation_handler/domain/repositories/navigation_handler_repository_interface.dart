import 'package:sixam_mart_delivery/interface/repository_interface.dart';

abstract class NavigationHandlerRepositoryInterface extends RepositoryInterface {
  Future<dynamic> getConfigData();
  Future<bool> initSharedData();
  Future<bool> removeSharedData();
}