import 'package:doghree_rider/features/address/domain/models/zone_model.dart';

abstract class AddressServiceInterface {
  Future<List<ZoneModel>?> getZoneList();
  String? getUserAddress();
  Future<bool> saveUserAddress(String address, List<int>? zoneIDs);
  int? setSelectedZoneIndex(List<int>? zoneIds, int? selectedZoneIndex, List<ZoneModel>? zoneList);
}