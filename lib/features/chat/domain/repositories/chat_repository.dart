import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/chat/domain/models/conversation_model.dart';
import 'package:doghree_rider/features/chat/domain/models/message_model.dart';
import 'package:doghree_rider/features/chat/domain/repositories/chat_repository_interface.dart';
import 'package:doghree_rider/util/app_constants.dart';

class ChatRepository implements ChatRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  ChatRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<ConversationsModel?> getConversationList(int offset) async {
    ConversationsModel? conversationModel;
    Response response = await apiClient.getData(AppConstants.getConversationListUri,
        query: {'offset': offset, 'limit': 10});
    // Only a JSON object is parsed: a 200 with an HTML page (captive Wi-Fi)
    // is a failure (null), not a TypeError (D-12, C1).
    if(response.statusCode == 200 && response.body is Map<String, dynamic>) {
      conversationModel = ConversationsModel.fromJson(response.body);
    }
    return conversationModel;
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
  Future<MessageModel?> getMessages(int offset, int? userId, String userType, int? conversationID) async {
    MessageModel? messageModel;
    final String idKey = conversationID != null
        ? 'conversation_id'
        : userType == AppConstants.user ? 'user_id' : 'vendor_id';
    Response response = await apiClient.getData(AppConstants.getMessageListUri,
        query: {idKey: conversationID ?? userId, 'offset': offset, 'limit': 10});
    // The old check `body['messages'] != {}` was always true and threw on a
    // List body. Only a Map is parsed; an empty `messages` list still gives a
    // model, so a new conversation opens (audit row 54).
    final dynamic body = response.body;
    if(response.statusCode == 200 && body is Map<String, dynamic>) {
      messageModel = MessageModel.fromJson(body);
    }
    return messageModel;
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