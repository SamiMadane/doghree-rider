import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart_delivery/features/chat/domain/models/message_model.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/features/chat/widgets/image_diaglog_widget.dart';
import 'package:sixam_mart_delivery/util/theme_extension.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Message message;
  final User? user;
  final User? sender;
  final String userType;

  const MessageBubbleWidget(
      {super.key,
      required this.message,
      required this.user,
      required this.userType,
      required this.sender});

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;
    bool isReply = message.senderId == user!.id;

    return Directionality(
      textDirection: TextDirection.ltr, 
      child: (isReply)
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (message.message != null)
                                    Flexible(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color,
                                          borderRadius: const BorderRadius.only(
                                            bottomRight: Radius.circular(
                                                Dimensions.radiusDefault),
                                            topRight: Radius.circular(
                                                Dimensions.radiusDefault),
                                            topLeft: Radius.circular(
                                                Dimensions.radiusDefault),
                                          ),
                                        ),
                                        padding: message.message != null
                                            ? EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeDefault,
                                                vertical:
                                                    Dimensions.paddingSizeSmall)
                                            : EdgeInsets.all(0),
                                        child: Directionality(
                                          textDirection: TextDirection
                                              .rtl, // اتجاه النص فقط
                                          child: Text(
                                            message.message ?? '',
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8.0),
                                  message.filesFullUrl != null
                                      ? GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            childAspectRatio: 1,
                                            crossAxisCount: 3,
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 5,
                                          ),
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              message.filesFullUrl!.length,
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            return message
                                                    .filesFullUrl!.isNotEmpty
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8),
                                                    child: InkWell(
                                                      hoverColor:
                                                          Colors.transparent,
                                                      onTap: () => showDialog(
                                                          context: context,
                                                          builder: (ctx) =>
                                                              ImageDialogWidget(
                                                                imageUrl: message
                                                                        .filesFullUrl![
                                                                    index],
                                                              )),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius
                                                            .circular(Dimensions
                                                                .paddingSizeSmall),
                                                        child:
                                                            CustomImageWidget(
                                                          height: 100,
                                                          width: 100,
                                                          fit: BoxFit.cover,
                                                          image: message
                                                                  .filesFullUrl![
                                                              index],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox();
                                          },
                                        )
                                      : const SizedBox(),
                                ]),
                          ),
                        ]),
                    const SizedBox(height: Dimensions.p8),
                    Text(
                      DateConverterHelper.isoStringToLocalTimeOnly(
                          message.createdAt!),
                      style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSizeSmall),
                    ),
                  ]),
            )
          : Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              (message.message != null &&
                                      message.message!.isNotEmpty)
                                  ? Flexible(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: customColor.senderMessageBg,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(
                                                Dimensions.radiusLarge),
                                            topRight: Radius.circular(
                                                Dimensions.radiusLarge),
                                            bottomLeft: Radius.circular(
                                                Dimensions.radiusLarge),
                                          ),
                                        ),
                                        child: Container(
                                          padding: message.message != null
                                              ? EdgeInsets.symmetric(
                                                  horizontal: Dimensions
                                                      .paddingSizeDefault,
                                                  vertical: Dimensions
                                                      .paddingSizeSmall)
                                              : EdgeInsets.all(0),
                                          child: Directionality(
                                            textDirection: TextDirection
                                                .rtl, // اتجاه النص فقط
                                            child: Text(
                                              message.message ?? '',
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color,
                                              ),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              message.filesFullUrl != null
                                  ? Container(
                                      width: double.infinity,
                                      child: Wrap(
                                        alignment: WrapAlignment
                                            .end, // محاذاة الصور لليمين
                                        runAlignment: WrapAlignment.end,
                                        spacing: 5,
                                        runSpacing: 10,
                                        children: message.filesFullUrl!
                                            .map((imageUrl) {
                                          return InkWell(
                                            onTap: () => showDialog(
                                                context: context,
                                                builder: (ctx) =>
                                                    ImageDialogWidget(
                                                      imageUrl: imageUrl,
                                                    )),
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                left:
                                                    Dimensions.paddingSizeSmall,
                                                top: (message.message != null &&
                                                        message.message!
                                                            .isNotEmpty)
                                                    ? Dimensions
                                                        .paddingSizeSmall
                                                    : 0,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions.radiusSmall),
                                                child: CustomImageWidget(
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.cover,
                                                  image: imageUrl,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  : const SizedBox(),
                            ]),
                      ),
                    ]),
                const SizedBox(height: Dimensions.p8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      message.isSeen == 1 ? 'read'.tr : 'unread'.tr,
                      style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSizeSmall),
                    ),
                    SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(
                      DateConverterHelper.isoStringToLocalTimeOnly(
                          message.createdAt!),
                      style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSizeSmall),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.paddingSizeDefault),
              ]),
            ),
    );
  }
}
