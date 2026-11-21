import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/common/models/data_load.dart';
import 'package:doghree_rider/common/models/load_failure.dart';
import 'package:doghree_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:doghree_rider/features/chat/domain/models/conversation_model.dart';
import 'package:doghree_rider/features/chat/domain/models/message_model.dart';
import 'package:doghree_rider/features/chat/domain/services/chat_service_interface.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';

class ChatController extends GetxController implements GetxService {
  final ChatServiceInterface chatServiceInterface;
  ChatController({required this.chatServiceInterface});

  List<bool>? _showDate;
  List<bool>? get showDate => _showDate;

  List<XFile>? _imageFiles;
  List<XFile>? get imageFiles => _imageFiles;

  bool _isSendButtonActive = false;
  bool get isSendButtonActive => _isSendButtonActive;

  final bool _isSeen = false;
  bool get isSeen => _isSeen;

  final bool _isSend = true;
  bool get isSend => _isSend;

  final bool _isMe = false;
  bool get isMe => _isMe;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<XFile>? _chatImage = [];
  List<XFile>? get chatImage => _chatImage;

  int? _pageSize;
  int? get pageSize => _pageSize;

  int? _offset;
  int? get offset => _offset;

  ConversationsModel? _conversationModel;
  ConversationsModel? get conversationModel => _conversationModel;

  ConversationsModel? _searchConversationModel;
  ConversationsModel? get searchConversationModel => _searchConversationModel;

  MessageModel? _messageModel;
  MessageModel? get messageModel => _messageModel;

  int _searchRequestId = 0;

  Future<void> searchConversation(String name) async {
    final int requestId = ++_searchRequestId;
    _searchConversationModel = ConversationsModel();
    update();
    final ConversationsModel? result =
        await chatServiceInterface.searchConversationList(name);
    if (requestId != _searchRequestId) return;
    _searchConversationModel = result ?? ConversationsModel(conversations: []);
    update();
  }

  void removeSearchMode() {
    _searchRequestId++;
    _searchConversationModel = null;
    update();
  }

  LoadFailure? _conversationFailure;

  /// Why the conversation list could not be loaded, when there is no list
  /// to show. Null while loading, after a success, or for a 401 (D-13).
  LoadFailure? get conversationFailure => _conversationFailure;

  LoadFailure? _messageFailure;

  /// Why the messages could not be loaded, when there are none to show
  /// (D-13).
  LoadFailure? get messageFailure => _messageFailure;

  /// Page 1 replaces the list and later pages append. A failed load keeps
  /// the list on screen; the failure state shows only when there is no list
  /// (D-13). The list is no longer cleared before a load: that showed an
  /// endless spinner on a failed refresh, and page 2 read the cleared list
  /// and threw. Returns false when the page failed, so a paginated list can
  /// ask for it again on the next scroll.
  Future<bool> getConversationList(int offset) async {
    _searchConversationModel = null;
    // No update() here: this runs from initState too. The screen's first
    // build reads the cleared state.
    if (_conversationModel == null) _conversationFailure = null;
    bool ok = false;
    try {
      final DataLoad<ConversationsModel> load =
          await chatServiceInterface.getConversationList(offset);
      final ConversationsModel? page = load.data;
      if (page != null) {
        page.conversations ??= [];
        if (offset == 1 || _conversationModel == null) {
          _conversationModel = page;
        } else {
          _conversationModel!.totalSize = page.totalSize;
          _conversationModel!.offset = page.offset;
          (_conversationModel!.conversations ??= [])
              .addAll(page.conversations!);
        }
        _conversationFailure = null;
        ok = true;
      } else if (_conversationModel == null) {
        _conversationFailure = LoadFailures.fromStatus(load.statusCode);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('conversation list failed: ${e.runtimeType}');
      if (_conversationModel == null) {
        _conversationFailure = LoadFailure.serverProblem;
      }
    } finally {
      update();
    }
    return ok;
  }

  /// Retry from the failure state: the spinner shows, then one request.
  Future<void> retryConversationList() async {
    _conversationFailure = null;
    update();
    await getConversationList(1);
  }

  /// Loads one page of messages. A failed refresh (after a send or a push)
  /// keeps the messages on screen; the failure state shows only when there
  /// are none (D-13). Returns false when the page failed.
  Future<bool> getMessages(int offset, NotificationBodyModel notificationBody,
      User? user, int? conversationID,
      {bool firstLoad = false}) async {
    if (firstLoad) {
      // No update() here: this runs from initState.
      _messageModel = null;
      _messageFailure = null;
    }
    bool ok = false;
    try {
      final DataLoad<MessageModel> load = await chatServiceInterface
          .processGetMessage(offset, notificationBody, conversationID);
      final MessageModel? messageModel = load.data;
      if (messageModel != null) {
        if (offset == 1) {
          final ProfileController profile = Get.find<ProfileController>();
          if (profile.profileModel == null) {
            await profile.getProfile();
          }
          // The rider's own data is read null-safe: a failed profile load
          // must not throw after the messages arrived (D-13).
          if (messageModel.conversation == null && user != null) {
            messageModel.conversation = Conversation(
                sender: User(
                  id: profile.profileModel?.id,
                  imageFullUrl: profile.profileModel?.imageFullUrl,
                  fName: profile.profileModel?.fName,
                  lName: profile.profileModel?.lName,
                ),
                receiver: user);
          } else if (messageModel.conversation != null &&
              messageModel.conversation!.receiverType == 'delivery_man') {
            User? receiver = messageModel.conversation!.receiver;
            messageModel.conversation!.receiver =
                messageModel.conversation!.sender;
            messageModel.conversation!.sender = receiver;
          }
          _messageModel = messageModel;
        } else if (_messageModel != null) {
          _messageModel!.totalSize = messageModel.totalSize;
          _messageModel!.offset = messageModel.offset;
          (_messageModel!.messages ??= [])
              .addAll(messageModel.messages ?? []);
        }
        _messageFailure = null;
        ok = true;
      } else if (_messageModel == null) {
        _messageFailure = LoadFailures.fromStatus(load.statusCode);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('messages failed: ${e.runtimeType}');
      if (_messageModel == null) _messageFailure = LoadFailure.serverProblem;
    } finally {
      _isLoading = false;
      update();
    }
    return ok;
  }

  /// Retry from the failure state: the spinner shows, then one request.
  Future<void> retryMessages(NotificationBodyModel notificationBody,
      User? user, int? conversationID) async {
    _messageFailure = null;
    update();
    await getMessages(1, notificationBody, user, conversationID);
  }

  Future<bool> sendMessage(
      {required String message,
      required NotificationBodyModel? notificationBody,
      required int? conversationId}) async {
    bool isSuccess = false;
    _isLoading = true;
    update();

    // The loader stops on every path: a failed send or an exception used to
    // leave the send button spinning (D-12, C2).
    try {
      List<MultipartBody> chatImage =
          chatServiceInterface.processMultipartBody(_chatImage ?? []);
      MessageModel? messageModel = await chatServiceInterface.processSendMessage(
          notificationBody, chatImage, message, conversationId);

      if (messageModel != null) {
        _imageFiles = [];
        _chatImage = [];
        _isSendButtonActive = false;
        _messageModel = messageModel;
        if (_messageModel!.conversation != null &&
            _messageModel!.conversation!.receiverType == 'delivery_man') {
          User? receiver = _messageModel!.conversation!.receiver;
          _messageModel!.conversation!.receiver =
              _messageModel!.conversation!.sender;
          _messageModel!.conversation!.sender = receiver;
        }
        isSuccess = true;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('sendMessage failed: ${e.runtimeType}');
    } finally {
      _isLoading = false;
      update();
    }
    return isSuccess;
  }

  void pickImage(bool isRemove) async {
    final ImagePicker picker = ImagePicker();
    if (isRemove) {
      _imageFiles = [];
      _chatImage = [];
      _isSendButtonActive = false;
    } else {
      _imageFiles =
          await picker.pickMultiImage(imageQuality: 60, maxWidth: 1600);
      if (_imageFiles != null) {
        _chatImage = imageFiles;
        _isSendButtonActive = true;
      }
    }
    update();
  }

  void removeImage(int index) {
    if (_chatImage != null && _chatImage!.isNotEmpty) {
      _chatImage!.removeAt(index);
    }
    _isSendButtonActive = (_chatImage != null && _chatImage!.isNotEmpty);
    update();
  }

  void toggleSendButtonActivity() {
    _isSendButtonActive = !_isSendButtonActive;
    update();
  }
}
