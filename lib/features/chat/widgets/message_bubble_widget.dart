import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart_delivery/features/chat/domain/models/message_model.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/features/chat/widgets/image_diaglog_widget.dart';
import 'package:sixam_mart_delivery/util/theme_extension.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Message message;
  final User? user;
  final User? sender;
  final String userType;

  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.user,
    required this.userType,
    required this.sender,
  });

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;
    bool isReply = message.senderId == user!.id;
    final hasImages =
        message.filesFullUrl != null && message.filesFullUrl!.isNotEmpty;
    final hasText = message.message != null && message.message!.isNotEmpty;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.p16,
          vertical: Dimensions.p10,
        ),
        child: Column(
          crossAxisAlignment:
              isReply ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            // فقاعات الرسائل
            Row(
              mainAxisAlignment:
                  isReply ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isReply
                          ? customColor.receiverMessageBg
                          : customColor.senderMessageBg,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Dimensions.r16),
                        topRight: Radius.circular(Dimensions.r16),
                        bottomLeft: isReply
                            ? Radius.circular(0)
                            : Radius.circular(Dimensions.r16),
                        bottomRight: isReply
                            ? Radius.circular(Dimensions.r16)
                            : Radius.circular(0),
                      ),
                    ),
                    padding:
                        const EdgeInsets.all(Dimensions.p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // الصور
                        if (hasImages)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: hasText ? Dimensions.p10 : 0,
                            ),
                            child: _buildImagesLayout(context, message),
                          ),

                        // النص أسفل الصور أو لوحده فقط
                        if (hasText)
                          Text(
                            message.message!,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fs16,
                              color: isReply
                                  ? Colors.white
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: Dimensions.p8),

            // تاريخ ووقت الإرسال + حالة القراءة
            Row(
              mainAxisAlignment:
                  isReply ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                if (!isReply) ...[
                  Row(
                    children: [
                      Icon(
                        message.isSeen == 1 ? Icons.done_all : Icons.done,
                        size: 14,
                        color: message.isSeen == 1
                            ? ManagerColors.darkGreen
                            : Theme.of(context).hintColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        message.isSeen == 1 ? 'read'.tr : 'unread'.tr,
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fs12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: Dimensions.p5),
                ],
                Text(
                  DateConverterHelper.isoStringToLocalTimeOnly(
                      message.createdAt!),
                  style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fs12,
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.p16),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesLayout(BuildContext context, Message message) {
    final images = message.filesFullUrl!;

    // حالة صورة واحدة
    if (images.length == 1) {
      return _buildImage(context, images[0], fullWidth: true);
    }

    // حالة صورتين
    if (images.length == 2) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 1,
        ),
        itemCount: 2,
        itemBuilder: (context, index) {
          return _buildImage(context, images[index]);
        },
      );
    }

    // حالة 3 صور (2 + 1 تحت)
    if (images.length == 3) {
      return Column(
        children: [
          _buildImage(context, images[0], fullWidth: true),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1,
            ),
            itemCount: 2,
            itemBuilder: (context, index) {
              return _buildImage(context, images[index + 1]); // صور رقم 1 و 2
            },
          ),
        ],
      );
    }

    // أكثر من 3 صور → Grid 2x2
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return _buildImage(context, images[index]);
      },
    );
  }

  Widget _buildImage(BuildContext context, String imageUrl,
      {bool fullWidth = false}) {
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (ctx) => ImageDialogWidget(imageUrl: imageUrl),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.r4),
        child: CustomImageWidget(
          image: imageUrl,
          fit: BoxFit.cover,
          width: fullWidth ? double.infinity : null,
          height: fullWidth ? 200 : double.infinity,
        ),
      ),
    );
  }
}
