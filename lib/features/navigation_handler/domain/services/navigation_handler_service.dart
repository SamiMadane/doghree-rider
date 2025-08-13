import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/navigation_handler/domain/repositories/navigation_handler_repository_interface.dart';
import 'package:sixam_mart_delivery/features/navigation_handler/domain/services/navigation_handler_service_interface.dart';

class NavigationHandlerService implements NavigationHandlerServiceInterface {
  final NavigationHandlerRepositoryInterface navigationHandlerRepositoryInterface;
  NavigationHandlerService({required this.navigationHandlerRepositoryInterface});

  @override
  Future<Response> getConfigData() async {
    return await navigationHandlerRepositoryInterface.getConfigData();
  }

  @override
  Future<bool> initSharedData() {
    return navigationHandlerRepositoryInterface.initSharedData();
  }

  @override
  Future<bool> removeSharedData() {
    return navigationHandlerRepositoryInterface.removeSharedData();
  }

}