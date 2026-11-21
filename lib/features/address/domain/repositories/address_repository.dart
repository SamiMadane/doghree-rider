import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/address/domain/models/zone_model.dart';
import 'package:doghree_rider/features/address/domain/repositories/address_repository_interface.dart';
import 'package:doghree_rider/helper/json_helper.dart';
import 'package:doghree_rider/util/app_constants.dart';

class AddressRepository implements AddressRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AddressRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<List<ZoneModel>?> getList() async {
    final Response response = await apiClient.getData(AppConstants.zoneListUri);
    if (response.statusCode != 200) return null;
    // A body that is not a List is a failure; a bad zone is skipped (row 52).
    return JsonHelper.mapList(response.body, ZoneModel.fromJson, name: 'zones');
  }

  @override
  String? getUserAddress() {
    return sharedPreferences.getString(AppConstants.userAddress);
  }

  @override
  Future<bool> saveUserAddress(String address, List<int>? zoneIDs) async {
    apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.token),
      sharedPreferences.getString(AppConstants.languageCode),
    );
    return await sharedPreferences.setString(AppConstants.userAddress, address);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(int? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

}