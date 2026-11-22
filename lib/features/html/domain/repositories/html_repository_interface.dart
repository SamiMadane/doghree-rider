import 'package:doghree_rider/common/models/data_load.dart';
import 'package:doghree_rider/interface/repository_interface.dart';

abstract class HtmlRepositoryInterface extends RepositoryInterface {
  Future<DataLoad<String>> getHtmlText(bool isPrivacyPolicy);
}
