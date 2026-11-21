import 'package:doghree_rider/interface/repository_interface.dart';

abstract class AddressRepositoryInterface implements RepositoryInterface {
  String? getUserAddress();
  Future<bool> saveUserAddress(String address, List<int>? zoneIDs);
}