import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/common/widgets/empty_state_widget.dart';
import 'package:doghree_rider/features/chat/controllers/chat_controller.dart';
import 'package:doghree_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:doghree_rider/features/chat/domain/models/conversation_model.dart';
import 'package:doghree_rider/helper/date_converter_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';
import 'package:doghree_rider/common/widgets/custom_ink_well_widget.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/common/widgets/paginated_list_view_widget.dart';
import 'package:doghree_rider/features/chat/widgets/search_field_widget.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Get.find<ChatController>().getConversationList(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(title: 'conversations'.tr),
      body: GetBuilder<ChatController>(builder: (chatController) {
        ConversationsModel? conversation0;
        if (chatController.searchConversationModel != null) {
          conversation0 = chatController.searchConversationModel;
        } else {
          conversation0 = chatController.conversationModel;
        }

        return Container(
          color: Theme.of(context).cardColor,
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.w16,
            vertical: Dimensions.h16,
          ),
          margin: EdgeInsets.only(top: Dimensions.h16),
          child: Column(children: [
            (conversation0 != null && conversation0.conversations != null)
                ? SearchFieldWidget(
                    controller: _searchController,
                    hint: 'search'.tr,
                    suffixIcon: chatController.searchConversationModel != null
                        ? Icon(Icons.close)
                        : SvgPicture.asset(
                            ManagerAssets.searchIcon,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                    onSubmit: (String text) {
                      if (_searchController.text.trim().isNotEmpty) {
                        chatController
                            .searchConversation(_searchController.text.trim());
                      } else {
                        showCustomSnackBar('write_somethings'.tr);
                      }
                    },
                    iconPressed: () {
                      if (chatController.searchConversationModel != null) {
                        _searchController.text = '';
                        chatController.removeSearchMode();
                      } else {
                        if (_searchController.text.trim().isNotEmpty) {
                          chatController.searchConversation(
                              _searchController.text.trim());
                        } else {
                          showCustomSnackBar('write_somethings'.tr);
                        }
                      }
                    },
                  )
                : const SizedBox(),
            SizedBox(
                height: (conversation0 != null &&
                        conversation0.conversations != null &&
                        chatController
                            .conversationModel!.conversations!.isNotEmpty)
                    ? Dimensions.h10
                    : 0),
            Expanded(
              child:
                  (conversation0 != null && conversation0.conversations != null)
                      ? conversation0.conversations!.isNotEmpty
                          ? RefreshIndicator(
                              onRefresh: () async {
                                chatController.getConversationList(1);
                              },
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Center(
                                    child: SizedBox(
                                        width: double.infinity,
                                        child: PaginatedListViewWidget(
                                          scrollController: _scrollController,
                                          onPaginate: (int? offset) =>
                                              chatController
                                                  .getConversationList(offset!),
                                          totalSize: conversation0.totalSize,
                                          offset: conversation0.offset,
                                          enabledPagination: chatController
                                                  .searchConversationModel ==
                                              null,
                                          productView: ListView.builder(
                                            itemCount: conversation0
                                                .conversations!.length,
                                            padding: EdgeInsets.zero,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              Conversation conversation =
                                                  conversation0!
                                                      .conversations![index];

                                              User? user;
                                              String? type;
                                              if (conversation.senderType ==
                                                  AppConstants.deliveryMan) {
                                                user = conversation.receiver;
                                                type =
                                                    conversation.receiverType;
                                              } else {
                                                user = conversation.sender;
                                                type = conversation.senderType;
                                              }

                                              return CustomCard(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: Dimensions.h16),
                                                isBorder: false,
                                                child: CustomInkWellWidget(
                                                  onTap: () {
                                                    if (user != null) {
                                                      Get.toNamed(RouteHelper
                                                              .getChatRoute(
                                                        notificationBody:
                                                            NotificationBodyModel(
                                                          type: conversation
                                                              .senderType,
                                                          notificationType:
                                                              NotificationType
                                                                  .message,
                                                          customerId: type ==
                                                                  AppConstants
                                                                      .customer
                                                              ? user.userId
                                                              : null,
                                                          vendorId: type ==
                                                                  AppConstants
                                                                      .vendor
                                                              ? user.vendorId
                                                              : null,
                                                        ),
                                                        conversationId:
                                                            conversation.id,
                                                      ))!
                                                          .then((value) => Get.find<
                                                                  ChatController>()
                                                              .getConversationList(
                                                                  1));
                                                    } else {
                                                      showCustomSnackBar(
                                                          '${'sorry_cannot_view_this_conversation'.tr} ${type!.tr} ${'may_have_been_removed_from'.tr} ${AppConstants.appName}');
                                                    }
                                                  },
                                                  highlightColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .surface
                                                          .withValues(
                                                              alpha: 0.1),
                                                  radius: Dimensions.r8,
                                                  child: Stack(children: [
                                                    Row(children: [
                                                      ClipOval(
                                                        child:
                                                            CustomImageWidget(
                                                          height: 55, width: 55,
                                                          fit: BoxFit.cover,
                                                          image:
                                                              '${user != null ? user.imageFullUrl : ''}',
                                                          // imageType: baseUrl,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width:
                                                              Dimensions.w10),
                                                      Expanded(
                                                          child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                user != null
                                                                    ? Text(
                                                                        '${user.fName} ${user.lName}',
                                                                        style: textSemiBold()
                                                                            .copyWith(
                                                                          fontSize:
                                                                              Dimensions.fs14,
                                                                        ),
                                                                      )
                                                                    : Text(
                                                                        '${type!.tr} ${'deleted'.tr}',
                                                                        style: textSemiBold()
                                                                            .copyWith(
                                                                          fontSize:
                                                                              Dimensions.fs14,
                                                                        ),
                                                                      ),
                                                                Text(
                                                                  DateConverterHelper.localTimeOnly(
                                                                      DateConverterHelper.dateTimeStringToDate(
                                                                          conversation
                                                                              .lastMessageTime!)),
                                                                  style: textMedium().copyWith(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .hintColor,
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fs10),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height:
                                                                    Dimensions
                                                                        .h8),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  conversation
                                                                          .lastMessage!
                                                                          .message ??
                                                                      ''.tr,
                                                                  style: textMedium().copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fs12,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .hintColor),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                if (conversation
                                                                            .unreadMessageCount! >
                                                                        0 &&
                                                                    conversation
                                                                            .lastMessage!
                                                                            .senderId ==
                                                                        user?.id)
                                                                  Container(
                                                                    padding: (conversation.lastMessage!.senderId ==
                                                                            user
                                                                                ?.id)
                                                                        ? EdgeInsets.symmetric(
                                                                            horizontal: Dimensions
                                                                                .w4,
                                                                            vertical: Dimensions
                                                                                .h4)
                                                                        : EdgeInsets
                                                                            .zero,
                                                                    decoration: BoxDecoration(
                                                                        color: ManagerColors
                                                                            .darkGreen,
                                                                        shape: BoxShape
                                                                            .circle),
                                                                    child: Text(
                                                                      conversation.lastMessage !=
                                                                              null
                                                                          ? (conversation.lastMessage!.senderId == user?.id)
                                                                              ? conversation.unreadMessageCount.toString()
                                                                              : ''
                                                                          : conversation.unreadMessageCount.toString(),
                                                                      style: textMedium().copyWith(
                                                                          color: Theme.of(context)
                                                                              .cardColor,
                                                                          fontSize:
                                                                              Dimensions.fs10),
                                                                    ),
                                                                  )
                                                              ],
                                                            ),
                                                          ])),
                                                    ]),
                                                  ]),
                                                ),
                                              );
                                            },
                                          ),
                                        ))),
                              ),
                            )
                          : Center(
                              child: SizedBox(
                              height: 500,
                              child: EmptyStateWidget(
                                imageScale: 1.2,
                                spacing: Dimensions.h20,
                                image: ManagerAssets.noConversationImage,
                                title: 'no_conversation_found'.tr,
                              ),
                            ))
                      : const Center(child: CircularProgressIndicator()),
            ),
          ]),
        );
      }),
    );
  }
}
