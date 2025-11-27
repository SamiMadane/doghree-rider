import 'package:wefrh_rider/interface/repository_interface.dart';

abstract class HtmlRepositoryInterface extends RepositoryInterface {
  Future<dynamic> getHtmlText(bool isPrivacyPolicy);
}