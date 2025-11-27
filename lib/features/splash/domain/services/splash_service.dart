import 'package:get/get.dart';
import 'package:wefrh_rider/features/splash/domain/repositories/splash_repository_interface.dart';
import 'package:wefrh_rider/features/splash/domain/services/splash_service_interface.dart';

class SplashService implements SplashServiceInterface {
  final SplashRepositoryInterface navigationHandlerRepositoryInterface;
  SplashService({required this.navigationHandlerRepositoryInterface});

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