import 'package:doghree_rider/common/widgets/custom_image_widget.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/screens/order_details_screen.dart';
import 'package:doghree_rider/features/order/widgets/order_status_helper.dart';
import 'package:doghree_rider/helper/date_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final BorderRadius radius = BorderRadius.circular(Dimensions.r18);

    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.h12),
      child: Material(
        color: theme.cardColor,
        borderRadius: radius,
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
            child: ClipRRect(
              borderRadius: radius,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        width: Dimensions.w4, color: orderModel.statusColor),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.w16,
                          vertical: Dimensions.h18,
                        ),
                        child: Row(
                          children: [
                            ClipOval(
                              child: CustomImageWidget(
                                image: orderModel.historyImage,
                                width: Dimensions.w60,
                                height: Dimensions.w60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: Dimensions.w12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '${'id_label'.tr}: ',
                                                style: textRegular().copyWith(
                                                  // was textSemiBold
                                                  fontSize: Dimensions.fs14,
                                                  color: Theme.of(context)
                                                      .hintColor,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '#${orderModel.id}',
                                                style: textBold().copyWith(
                                                  // was textSemiBold
                                                  fontSize: Dimensions.fs14,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface, 
                                                ),
                                              ),
                                            ],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: Dimensions.fs14),
                                        ),
                                      ),
                                      if (orderModel.isParcel) ...[
                                        SizedBox(width: Dimensions.w8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: Dimensions.w8,
                                            vertical: Dimensions.h2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: scheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.r8),
                                          ),
                                          child: Text(
                                            'parcel'.tr,
                                            style: TextStyle(
                                              fontSize: Dimensions.fs11,
                                              fontWeight: FontWeight.w700,
                                              color: scheme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: Dimensions.h4),
                                  Text(
                                    orderModel.historyTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: Dimensions.fs15,
                                      fontWeight: FontWeight.w700,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: Dimensions.h6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: Dimensions.fs14,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                      SizedBox(width: Dimensions.w4),
                                      Flexible(
                                        child: Text(
                                          DateConverterHelper
                                              .dateTimeStringToDateTime(
                                                  orderModel.createdAt!),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: Dimensions.fs12,
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (orderModel.orderStatus != null) ...[
                              SizedBox(width: Dimensions.w8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.w10,
                                  vertical: Dimensions.h6,
                                ),
                                decoration: BoxDecoration(
                                  color: orderModel.statusColor,
                                  borderRadius:
                                      BorderRadius.circular(Dimensions.r20),
                                ),
                                child: Text(
                                  orderModel.orderStatus!.tr,
                                  style: TextStyle(
                                    fontSize: Dimensions.fs11,
                                    fontWeight: FontWeight.w700,
                                    color: orderModel.onStatusColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
