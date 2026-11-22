import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/common/models/data_load.dart';
import 'package:doghree_rider/features/chat/domain/models/conversation_model.dart';
import 'package:doghree_rider/features/chat/domain/models/message_model.dart';
import 'package:doghree_rider/features/chat/domain/repositories/chat_repository_interface.dart';
import 'package:doghree_rider/util/app_constants.dart';

class ChatRepository implements ChatRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  ChatRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<ConversationsModel?> getConversationList(int offset) async =>
      (await loadConversationList(offset)).data;

  /// Silent (D-13): the screen shows its own failure state, so there is no
  /// toast. A 401 still ends the session. Only a JSON object is parsed: a
  /// 200 with an HTML page (captive Wi-Fi) is a failure, not a TypeError
  /// (D-12, C1).
  @override
  Future<DataLoad<ConversationsModel>> loadConversationList(int offset) async {
    final Response response = await apiClient.getData(
        AppConstants.getConversationListUri,
        query: {'offset': offset, 'limit': 10},
        handleError: false);
    ApiChecker.checkSession(response);
    return _parse(response, ConversationsModel.fromJson);
  }

  @override
  Future<ConversationsModel?> searchConversationList(String name) async {
    ConversationsModel? searchConversationModel;
    // The query map is URL-encoded by ApiClient, so & # + in a name are safe (audit row 50).
    Response response = await apiClient.getData(AppConstants.searchConversationListUri,
        query: {'name': name, 'limit': 20, 'offset': 1});
    if(response.statusCode == 200 && response.body is Map<String, dynamic>) {
      searchConversationModel = ConversationsModel.fromJson(response.body);
    }
    return searchConversationModel;
  }

  @override
  Future<MessageModel?> getMessages(int offset, int? userId, String userType, int? conversationID) async =>
      (await loadMessages(offset, userId, userType, conversationID)).data;

  /// Silent (D-13), like [loadConversationList]: the first load shows the
  /// screen's failure state, and the refreshes after a send or a push stay
  /// quiet. The old check `body['messages'] != {}` was always true and threw
  /// on a List body. Only a Map is parsed; an empty `messages` list still
  /// gives a model, so a new conversation opens (audit row 54).
  @override
  Future<DataLoad<MessageModel>> loadMessages(int offset, int? userId, String userType, int? conversationID) async {
    final String idKey = conversationID != null
        ? 'conversation_id'
        : userType == AppConstants.user ? 'user_id' : 'vendor_id';
    final Response response = await apiClient.getData(AppConstants.getMessageListUri,
        query: {idKey: conversationID ?? userId, 'offset': offset, 'limit': 10},
        handleError: false);
    ApiChecker.checkSession(response);
    return _parse(response, MessageModel.fromJson);
  }

  /// A 200 with a JSON object is parsed; a 200 with anything else, or a
  /// model that cannot be read, is a failure with status 0.
  static DataLoad<T> _parse<T>(
      Response response, T Function(Map<String, dynamic> json) fromJson) {
    if (response.statusCode != 200) return DataLoad<T>.failed(response.statusCode);
    final dynamic body = response.body;
    if (body is! Map<String, dynamic>) return DataLoad<T>.failed(0);
    try {
      return DataLoad<T>(fromJson(body), statusCode: 200);
    } catch (e) {
      if (kDebugMode) debugPrint('chat parse failed: ${e.runtimeType}');
      return DataLoad<T>.failed(0);
    }
  }

  @override
  Future<MessageModel?> sendMessage(String message, List<MultipartBody> file, int? conversationId, int? userId, String userType) async {
    MessageModel? messageModel;
    Response response = await apiClient.postMultipartData(AppConstants.sendMessageUri,
      {'message': message, 'receiver_type': userType,  conversationId != null ? 'conversation_id' : 'receiver_id': '${conversationId ?? userId}', 'offset': '1', 'limit': '10'}, file);
    if(response.statusCode == 200 && response.body is Map<String, dynamic>) {
      messageModel = MessageModel.fromJson(response.body);
    }
    return messageModel;
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
  Future getList() {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

}