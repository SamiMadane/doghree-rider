import 'dart:async';

import 'package:wefrh_rider/common/models/config_model.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/doghree_map/map_config.dart';
import 'package:wefrh_rider/features/splash/domain/services/splash_service_interface.dart';

class SplashController extends GetxController implements GetxService {
  final SplashServiceInterface navigationHandlerServiceInterface;
  SplashController({required this.navigationHandlerServiceInterface});

  ConfigModel? _configModel;
  ConfigModel? get configModel => _configModel;
  DoghreeMapConfig? _doghreeMapConfig;
  DoghreeMapConfig? get doghreeMapConfig => _doghreeMapConfig;

  bool _firstTimeConnectionCheck = true;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;

  int? _storeCategoryID;
  int? get storeCategoryID => _storeCategoryID;

  String? _storeType;
  String? get storeType => _storeType;

  Map<String, dynamic>? _data = {};

  DateTime get currentTime => DateTime.now();

  Future<bool> getConfigData() async {
    try {
      Response response = await navigationHandlerServiceInterface
          .getConfigData()
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        _data = response.body;
        _configModel = ConfigModel.fromJson(response.body);
        try {
          _doghreeMapConfig = DoghreeMapConfig.fromConfigJson(
              Map<String, dynamic>.from(response.body));
        } catch (e) {
          // فشل قراءة إعدادات الخريطة ما لازم يفشّل تحميل الـ config كله
          print('Doghree map config parse failed: $e');
        }
        // طباعة البيانات بالكامل
        print("=== Config Data Loaded ===");
        print(_data);
        print("==========================");

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

  // جلب اعدادات موديول معين من السيرفر والموديول يتم تمريره
  // في حال كانت ال moduleType هي food يتم اضافة خاصية newVariation
  Module getModuleConfig(String? moduleType) {
    Module module = Module.fromJson(_data!['module_config'][moduleType]);
    moduleType == 'food'
        ? module.newVariation = true
        : module.newVariation = false;
    return module;
  }

  // جلب اعدادات موديول معين من الذاكرة
  // دون اي تعديل على الخاصية newVariation
  Module getModule(String? moduleType) =>
      Module.fromJson(_data!['module_config'][moduleType]);

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
