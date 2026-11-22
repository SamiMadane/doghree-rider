import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/common/models/data_load.dart';
import 'package:doghree_rider/features/chat/domain/models/conversation_model.dart';
import 'package:doghree_rider/features/chat/domain/models/message_model.dart';
import 'package:doghree_rider/interface/repository_interface.dart';

abstract class ChatRepositoryInterface implements RepositoryInterface {
  Future<dynamic> getConversationList(int offset);
  Future<DataLoad<ConversationsModel>> loadConversationList(int offset);
  Future<dynamic> searchConversationList(String name);
  Future<dynamic> getMessages(int offset, int? userId, String userType, int? conversationID);
  Future<DataLoad<MessageModel>> loadMessages(int offset, int? userId, String userType, int? conversationID);
  Future<dynamic> sendMessage(String message, List<MultipartBody> file, int? conversationId, int? userId, String userType);
}
