import 'dart:async';

import 'package:doghree_rider/common/models/config_model.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/doghree_map/map_config.dart';
import 'package:doghree_rider/features/splash/domain/services/splash_service_interface.dart';

class SplashController extends GetxController implements GetxService {
  final SplashServiceInterface navigationHandlerServiceInterface;
  SplashController({required this.navigationHandlerServiceInterface});

  ConfigModel? _configModel;
  ConfigModel? get configModel => _configModel;
  DoghreeMapConfig? _doghreeMapConfig;
  DoghreeMapConfig? get doghreeMapConfig => _doghreeMapConfig;

  Map<String, dynamic>? _data = {};

  /// Status of the last config load: the HTTP status, 1 for no internet or
  /// a timeout, 0 when a 200 body could not be read (HTML, malformed JSON).
  /// The splash uses it to pick its Retry text (D-12).
  int? _lastConfigStatus;
  int? get lastConfigStatus => _lastConfigStatus;

  DateTime get currentTime => DateTime.now();

  Future<bool> getConfigData() async {
    try {
      Response response = await navigationHandlerServiceInterface
          .getConfigData()
          .timeout(Duration(seconds: 10));
      _lastConfigStatus = response.statusCode;

      if (response.statusCode == 200) {
        _data = response.body;
        _configModel = ConfigModel.fromJson(response.body);
        try {
          _doghreeMapConfig = DoghreeMapConfig.fromConfigJson(
              Map<String, dynamic>.from(response.body));
        } catch (e) {
          // فشل قراءة إعدادات الخريطة ما لازم يفشّل تحميل الـ config كله
        }
        // طباعة البيانات بالكامل

        update();
        return true;
      } else {
        return false;
      }
    } on TimeoutException catch (_) {
      _lastConfigStatus = 1;
      return false;
    } catch (e) {
      _lastConfigStatus = 0;
      return false;
    }
  }

  /// The settings of one module, from memory. It is called from `build`, so it
  /// never throws (audit row 30): a null or unknown [moduleType], a config
  /// that is not loaded yet, or a broken entry gives an empty `Module()`
  /// whose flags are all null (callers read them with `?? false`).
  Module getModule(String? moduleType) {
    try {
      final dynamic configs = _data?['module_config'];
      final dynamic entry =
          moduleType != null && configs is Map ? configs[moduleType] : null;
      if (entry is Map) {
        return Module.fromJson(Map<String, dynamic>.from(entry));
      }
    } catch (_) {
      // fall through to the empty module
    }
    return Module();
  }

  Future<bool> initSharedData() {
    return navigationHandlerServiceInterface.initSharedData();
  }

  Future<bool> removeSharedData() {
    return navigationHandlerServiceInterface.removeSharedData();
  }
}
