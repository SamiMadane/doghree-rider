import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/screens/order_details_screen.dart';
import 'package:doghree_rider/features/order/widgets/order_status_helper.dart';
import 'package:doghree_rider/helper/date_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

/// كرت مختصر لسجل الطلبات: يجاوب بنظرة وحدة (مين؟ إيمتى؟ شو النتيجة؟ كم؟)،
/// والتفاصيل الكاملة (العناوين، المسار...) بصفحة الطلب.
class HistoryOrderWidget extends StatelessWidget {
  final OrderModel orderModel;
  final bool isRunning;
  final int index;

  const HistoryOrderWidget({
    super.key,
    required this.orderModel,
    required this.isRunning,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final BorderRadius radius = BorderRadius.circular(Dimensions.r24);
    final String? createdAt = orderModel.createdAt;

    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.h12),
      child: Material(
        color: theme.cardColor,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: radius,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(
                orderId: orderModel.id,
                isRunningOrder: isRunning,
                orderIndex: index,
              ),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: scheme.outline),
            ),
            child: Padding(
              padding: EdgeInsets.all(Dimensions.w16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(Dimensions.w2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.outline),
                    ),
                    child: ClipOval(
                      child: CustomImageWidget(
                        image: orderModel.historyImage,
                        width: Dimensions.w56,
                        height: Dimensions.w56,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: Dimensions.w12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderModel.historyTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textBold().copyWith(
                            fontSize: Dimensions.fs16,
                            color: scheme.onSurface,
                          ),
                        ),
                        SizedBox(height: Dimensions.h4),
                        Row(
                          children: [
                            Flexible(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${'id_label'.tr}: ',
                                      style: textRegular().copyWith(
                                        fontSize: Dimensions.fs13,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '#${orderModel.id}',
                                      style: textBold().copyWith(
                                        fontSize: Dimensions.fs13,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (orderModel.isParcel) ...[
                              SizedBox(width: Dimensions.w6),
                              _ParcelTag(label: 'parcel'.tr),
                            ],
                          ],
                        ),
                        SizedBox(height: Dimensions.h4),
                        Text(
                          createdAt == null
                              ? ''
                              : DateConverterHelper.dateTimeStringToDateTime(
                                  createdAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textMedium().copyWith(
                            fontSize: Dimensions.fs12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: Dimensions.w8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (orderModel.orderStatus != null)
                        _StatusLabel(
                          label: orderModel.orderStatus!.tr,
                          dotColor: orderModel.statusColor,
                          textColor: scheme.onSurface,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// حالة الطلب: نقطة بلون الحالة + نص (مثل "● Rejected" بشاشة Balance).
class _StatusLabel extends StatelessWidget {
  final String label;
  final Color dotColor;
  final Color textColor;

  const _StatusLabel({
    required this.label,
    required this.dotColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: Dimensions.w8,
          height: Dimensions.w8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
        ),
        SizedBox(width: Dimensions.w6),
        Text(
          label,
          maxLines: 1,
          style: textBold().copyWith(
            fontSize: Dimensions.fs13,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

/// وسم الطرد: خلفية أصفر ناعم + نص أسفلت.
class _ParcelTag extends StatelessWidget {
  final String label;
  const _ParcelTag({required this.label});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w8,
        vertical: Dimensions.h2,
      ),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(Dimensions.r50),
      ),
      child: Text(
        label,
        style: textBold().copyWith(
          fontSize: Dimensions.fs11,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
