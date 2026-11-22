import 'package:doghree_rider/common/models/data_load.dart';
import 'package:doghree_rider/features/html/domain/repositories/html_repository_interface.dart';
import 'package:doghree_rider/features/html/domain/services/html_service_interface.dart';

class HtmlService implements HtmlServiceInterface {
  final HtmlRepositoryInterface htmlRepositoryInterface;
  HtmlService({required this.htmlRepositoryInterface});

  @override
  Future<DataLoad<String>> getHtmlText(bool isPrivacyPolicy) async {
    return await htmlRepositoryInterface.getHtmlText(isPrivacyPolicy);
  }

}