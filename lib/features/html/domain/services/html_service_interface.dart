import 'package:doghree_rider/common/models/data_load.dart';

abstract class HtmlServiceInterface {
  Future<DataLoad<String>> getHtmlText(bool isPrivacyPolicy);
}
