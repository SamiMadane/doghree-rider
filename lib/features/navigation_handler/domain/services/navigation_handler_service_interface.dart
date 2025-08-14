import 'package:get/get.dart';

abstract class NavigationHandlerServiceInterface {
  Future<Response> getConfigData();
  Future<bool> initSharedData();
  Future<bool> removeSharedData();
}