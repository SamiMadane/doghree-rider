import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/chat/controllers/chat_controller.dart';
import 'package:sixam_mart_delivery/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_delivery/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart_delivery/helper/responsive_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/paginated_list_view_widget.dart';
import 'package:sixam_mart_delivery/features/chat/widgets/message_bubble_widget.dart';
import 'package:sixam_mart_delivery/util/theme_extension.dart';

class ChatScreen extends StatefulWidget {
  final NotificationBodyModel? notificationBody;
  final User? user;
  final int? conversationId;
  final bool fromNotification;
  const ChatScreen(
      {super.key,
      required this.notificationBody,
      required this.user,
      this.conversationId,
      this.fromNotification = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputMessageController = TextEditingController();
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    Get.find<ChatController>().getMessages(
        1, widget.notificationBody!, widget.user, widget.conversationId,
        firstLoad: true);
  }

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return GetBuilder<ChatController>(builder: (chatController) {
      // String? baseUrl = '';
      // if(widget.notificationBody!.customerId != null || (widget.notificationBody!.conversationId != null && widget.notificationBody!.type == 'user')) {
      //   baseUrl = ImageType.customer_image_url.name;
      // }else {
      //   baseUrl = ImageType.store_image_url.name;
      // }

      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if (widget.fromNotification && !didPop) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          } else {
            return;
          }
        },
        child: Scaffold(
          appBar: CustomAppBarWidget(
            titleWidget: Row(
              children: [
                ClipOval(
                  child: CustomImageWidget(
                    image: chatController.messageModel != null
                        ? chatController
                            .messageModel!.conversation!.receiver!.imageFullUrl
                        : '',
                    fit: BoxFit.cover,
                    height: 40,
                    width: 40,
                  ),
                ),
                SizedBox(width: Dimensions.p8),
                Expanded(
                  child: Text(
                    chatController.messageModel != null
                        ? '${chatController.messageModel!.conversation!.receiver!.fName ?? ''} '
                            '${chatController.messageModel!.conversation!.receiver!.lName ?? ''}'
                        : 'receiver_name'.tr,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            onBackPressed: () {
              if (widget.fromNotification) {
                Get.offAllNamed(RouteHelper.getInitialRoute());
              } else {
                Get.back();
              }
            },
          ),
          body: _isLoggedIn
              ? SafeArea(
                  child: Container(
                    margin: EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                    color: Theme.of(context).cardColor,
                    child: Column(
                      children: [
                        // قائمة الرسائل
                        Expanded(
                          child: chatController.messageModel != null
                              ? chatController
                                      .messageModel!.messages!.isNotEmpty
                                  ? SingleChildScrollView(
                                      controller: _scrollController,
                                      reverse: true,
                                      child: PaginatedListViewWidget(
                                        scrollController: _scrollController,
                                        totalSize: chatController
                                            .messageModel?.totalSize,
                                        offset:
                                            chatController.messageModel?.offset,
                                        onPaginate: (int? offset) async =>
                                            await chatController.getMessages(
                                          offset!,
                                          widget.notificationBody!,
                                          widget.user,
                                          widget.conversationId,
                                        ),
                                        productView: ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          reverse: true,
                                          itemCount: chatController
                                              .messageModel!.messages!.length,
                                          itemBuilder: (context, index) {
                                            return MessageBubbleWidget(
                                              message: chatController
                                                  .messageModel!
                                                  .messages![index],
                                              user: chatController.messageModel!
                                                  .conversation!.receiver,
                                              sender: chatController
                                                  .messageModel!
                                                  .conversation!
                                                  .sender,
                                              userType: widget.notificationBody!
                                                              .customerId !=
                                                          null ||
                                                      (widget.notificationBody!
                                                                  .conversationId !=
                                                              null &&
                                                          widget.notificationBody!
                                                                  .type ==
                                                              'user')
                                                  ? AppConstants.user
                                                  : AppConstants.vendor,
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : const SizedBox()
                              : const Center(
                                  child: CircularProgressIndicator()),
                        ),

                        // قسم إدخال الرسائل (دائمًا ظاهر)
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow:  [
                              BoxShadow(
                                  color: Theme.of(context).shadowColor,
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                  offset: const Offset(0, -3),
                                  )
                            ],
                          ),
                          padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeDefault,
                              left: Dimensions.paddingSizeDefault,
                              right: Dimensions.paddingSizeDefault,
                              bottom: Dimensions.paddingSizeExtraSmall),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // صور المرفقات إذا كانت موجودة
                              if (chatController.chatImage!.isNotEmpty)
                                Container(
                                  margin: EdgeInsets.only(
                                      bottom: Dimensions.paddingSizeSmall),
                                  height: 100,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount:
                                          chatController.chatImage!.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: EdgeInsets.only(
                                              right: Dimensions
                                                  .paddingSizeDefault), // هنا فقط مسافة بين الصور
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions
                                                            .radiusMedium),
                                                child: ResponsiveHelper.isWeb()
                                                    ? Image.network(
                                                        chatController
                                                            .chatImage![index]
                                                            .path,
                                                        width: 100,
                                                        height: 100,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.file(
                                                        File(chatController
                                                            .chatImage![index]
                                                            .path),
                                                        width: 100,
                                                        height: 100,
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                              Positioned(
                                                top: 4,
                                                left: 4,
                                                child: InkWell(
                                                  onTap: () => chatController
                                                      .removeImage(index),
                                                  child: Container(
                                                    width:
                                                        28, // الدائرة الخارجية
                                                    height: 28,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withAlpha(
                                                          200), // الدائرة البيضاء
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Container(
                                                        width:
                                                            20, // الإطار الأسود
                                                        height: 20,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black,
                                                              width: 1.5),
                                                        ),
                                                        child: const Center(
                                                          child: Icon(
                                                              Icons.clear,
                                                              color:
                                                                  Colors.black,
                                                              size: 12),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),

                              // TextField + زر الإرسال
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radiusLarge),
                                        border: Border.all(
                                            color: customColor.strock1),
                                      ),
                                      child: TextField(
                                        controller: _inputMessageController,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        style: robotoRegular,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(
                                              Dimensions.messageInputLength),
                                        ],
                                        decoration: InputDecoration(
                                          hintText: 'type_text'.tr,
                                          hintStyle: robotoRegular.copyWith(
                                            color: Theme.of(context).hintColor,
                                            fontSize: Dimensions.fontSizeLarge,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.all(
                                              Dimensions.paddingSizeDefault),
                                          suffixIcon: InkWell(
                                            onTap: () async =>
                                                chatController.pickImage(false),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                  Dimensions
                                                      .paddingSizeDefault),
                                              child: SvgPicture.asset(
                                                ManagerAssets.attachedIcon,
                                                width: 16,
                                                height: 16,
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onChanged: (text) {
                                          if (text.trim().isNotEmpty &&
                                              !chatController
                                                  .isSendButtonActive) {
                                            chatController
                                                .toggleSendButtonActivity();
                                          } else if (text.isEmpty &&
                                              chatController
                                                  .isSendButtonActive) {
                                            chatController
                                                .toggleSendButtonActivity();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.p8),
                                  GetBuilder<ChatController>(
                                      builder: (chatController) {
                                    return !chatController.isLoading
                                        ? InkWell(
                                            onTap: () async {
                                              if (chatController
                                                  .isSendButtonActive) {
                                                if (chatController
                                                        .chatImage!.length >
                                                    3) {
                                                  showCustomSnackBar(
                                                      'you_do_not_send_more_then_3_photos'
                                                          .tr);
                                                } else {
                                                  chatController
                                                      .sendMessage(
                                                    message:
                                                        _inputMessageController
                                                            .text,
                                                    notificationBody:
                                                        widget.notificationBody,
                                                    conversationId:
                                                        widget.conversationId,
                                                  )
                                                      .then((success) {
                                                    _inputMessageController
                                                        .clear();
                                                    if (success) {
                                                      Future.delayed(
                                                          const Duration(
                                                              seconds: 2), () {
                                                        chatController
                                                            .getMessages(
                                                          1,
                                                          widget
                                                              .notificationBody!,
                                                          widget.user,
                                                          widget.conversationId,
                                                        );
                                                      });
                                                    }
                                                  });
                                                }
                                              } else {
                                                showCustomSnackBar(
                                                    'write_somethings'.tr);
                                              }
                                            },
                                            child: SvgPicture.asset(
                                              ManagerAssets.sendIcon,
                                              width: 25,
                                              height: 25,
                                              color: chatController
                                                      .isSendButtonActive
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : Get.isDarkMode
                                                      ? Colors.white
                                                      : Theme.of(context)
                                                          .hintColor,
                                            ),
                                          )
                                        : const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeDefault),
                                            child: SizedBox(
                                              width: 25,
                                              height: 25,
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(child: Text('Not Login')),
        ),
      );
    });
  }
}
