import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:image_picker/image_picker.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/address/domain/models/address_model.dart';
import 'package:doghree_rider/features/address/domain/models/zone_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/address/domain/services/address_service_interface.dart';

class AddressController extends GetxController implements GetxService {
  final AddressServiceInterface addressServiceInterface;
  AddressController({required this.addressServiceInterface});

  XFile? _pickedLogo;
  XFile? get pickedLogo => _pickedLogo;

  XFile? _pickedCover;
  XFile? get pickedCover => _pickedCover;

  List<ZoneModel>? _zoneList;
  List<ZoneModel>? get zoneList => _zoneList;

  int? _selectedZoneIndex = 0;
  int? get selectedZoneIndex => _selectedZoneIndex;

  List<int>? _zoneIds;
  List<int>? get zoneIds => _zoneIds;

  String? _selectedDeliveryZoneId;
  String? get selectedDeliveryZoneId => _selectedDeliveryZoneId;

  Future<void> getZoneList() async {
    _pickedLogo = null;
    _pickedCover = null;
    _selectedZoneIndex = 0;
    _zoneIds = null;
    List<ZoneModel>? zoneList = await addressServiceInterface.getZoneList();
    if (zoneList != null) {
      _zoneList = [];
      _zoneList!.addAll(zoneList);
    }
    update();
  }

  void setSelectedDeliveryZone({String? zoneId}) {
    _selectedDeliveryZoneId = zoneId;
    update();
  }

  void resetSelectedDeliveryZone() {
    _selectedDeliveryZoneId = null;
  }

  AddressModel? getUserAddress() {
    AddressModel? addressModel;
    try {
      addressModel = AddressModel.fromJson(
          jsonDecode(addressServiceInterface.getUserAddress()!));
    } catch (e) {
      if (kDebugMode) debugPrint('getUserAddress failed: $e');
      return null;
    }
    return addressModel;
  }

  Future<bool> saveUserAddress(AddressModel address) async {
    String userAddress = jsonEncode(address.toJson());
    return await addressServiceInterface.saveUserAddress(
        userAddress, address.zoneIds);
  }

  /// المسافة بالكيلومتر بين [storeLatLng] و [customerLatLng].
  /// إذا لم يُمرَّر [customerLatLng] تُستعمل آخر نقطة مسجّلة للمندوب.
  double getRestaurantDistance(LatLng storeLatLng, {LatLng? customerLatLng}) {
    double distance = 0;
    distance = Geolocator.distanceBetween(
          storeLatLng.latitude,
          storeLatLng.longitude,
          customerLatLng?.latitude ??
              Get.find<ProfileController>().recordLocationBody?.latitude ??
              0,
          customerLatLng?.longitude ??
              Get.find<ProfileController>().recordLocationBody?.longitude ??
              0,
        ) /
        1000;
    return distance;
  }
}
