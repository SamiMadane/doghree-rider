import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/helper/date_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';
import 'package:doghree_rider/features/order/screens/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryOrderWidget extends StatelessWidget {
  final OrderModel orderModel;
  final bool isRunning;
  final int index;
  const HistoryOrderWidget(
      {super.key,
      required this.orderModel,
      required this.isRunning,
      required this.index});

  @override
  Widget build(BuildContext context) {
    bool parcel = orderModel.orderType == 'parcel';

    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(
                  orderId: orderModel.id,
                  isRunningOrder: isRunning,
                  orderIndex: index))),
      child: CustomCard(
        borderRadius: Dimensions.r16,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.w16,
          vertical: Dimensions.h16,
        ),
        margin: EdgeInsets.only(bottom: Dimensions.h16),
        child: Row(children: [
          CustomCard(
            height: 75,
            width: 90,
            isBorder: true,
            borderRadius: Dimensions.r10,
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.w10, vertical: Dimensions.fs10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.r4),
              child: CustomImageWidget(
                image: parcel
                    ? '${orderModel.parcelCategory != null ? orderModel.parcelCategory!.imageFullUrl : ''}'
                    : orderModel.storeLogoFullUrl ?? '',
                height: parcel ? 45 : 70,
                width: parcel ? 45 : 70,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: Dimensions.w16),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${'id_label'.tr}: ',
                        style: textSemiBold().copyWith(
                          fontSize: Dimensions.fs14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      TextSpan(
                        text: '#${orderModel.id}',
                        style: textSemiBold().copyWith(
                          fontSize: Dimensions.fs14,
                          color: ManagerColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                parcel
                    ? CustomCard(
                        width: 60,
                        padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.w4, vertical: Dimensions.h4),
                        borderRadius: Dimensions.r10,
                        fillColor: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.1),
                        child: Center(
                          child: Text('parcel'.tr,
                              style: textMedium().copyWith(
                                fontSize: Dimensions.fs14,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              )),
                        ),
                      )
                    : const SizedBox(),
              ]),
              SizedBox(height: Dimensions.h4),
              Text(
                parcel
                    ? orderModel.parcelCategory != null
                        ? orderModel.parcelCategory!.name!
                        : 'no_parcel_category_data_found'.tr
                    : orderModel.storeName ?? 'no_store_data_found'.tr,
                style: textSemiBold().copyWith(
                    fontSize: Dimensions.fs14,
                    color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
              SizedBox(height: Dimensions.h4),
              Row(children: [
                Icon(
                  Icons.access_time,
                  size: 15,
                  color: Theme.of(context).disabledColor,
                ),
                SizedBox(width: Dimensions.w4),
                Text(
                  DateConverterHelper.dateTimeStringToDateTime(
                      orderModel.createdAt!),
                  style: textMedium().copyWith(
                      color: Theme.of(context).disabledColor,
                      fontSize: Dimensions.fs12),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
