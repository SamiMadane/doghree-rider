import 'dart:async';

import 'package:sixam_mart_delivery/common/models/config_model.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/navigation_handler/domain/services/navigation_handler_service_interface.dart';

class NavigationHandlerController extends GetxController implements GetxService {
  final NavigationHandlerServiceInterface navigationHandlerServiceInterface;
  NavigationHandlerController({required this.navigationHandlerServiceInterface});

  ConfigModel? _configModel;
  ConfigModel? get configModel => _configModel;

  bool _firstTimeConnectionCheck = true;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;

  int? _storeCategoryID;
  int? get storeCategoryID => _storeCategoryID;

  String? _storeType;
  String? get storeType => _storeType;

  Map<String, dynamic>? _data = {};

  DateTime get currentTime => DateTime.now();

  Module getModuleConfig(String? moduleType) {
    Module module = Module.fromJson(_data!['module_config'][moduleType]);
    moduleType == 'food' ? module.newVariation = true : module.newVariation = false;
    return module;
  }

  Future<bool> getConfigData() async {
  try {
    Response response = await navigationHandlerServiceInterface.getConfigData()
      .timeout(Duration(seconds: 10)); // تعيين مهلة 10 ثواني
    
    if (response.statusCode == 200) {
      _data = response.body;
      _configModel = ConfigModel.fromJson(response.body);
      update();
      return true;
    } else {
      return false;
    }
  } on TimeoutException catch (_) {
    print("getConfigData: Timeout Exception");
    return false;
  } catch (e) {
    print("getConfigData: Exception caught: $e");
    return false;
  }
}


  Module getModule(String? moduleType) => Module.fromJson(_data!['module_config'][moduleType]);

  Future<bool> initSharedData() {
    return navigationHandlerServiceInterface.initSharedData();
  }

  Future<bool> removeSharedData() {
    return navigationHandlerServiceInterface.removeSharedData();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

}