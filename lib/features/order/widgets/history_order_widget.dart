import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/features/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/features/order/screens/order_details_screen.dart';
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
        padding: const EdgeInsets.all(Dimensions.p16),
        margin: const EdgeInsets.only(bottom: Dimensions.p16),
        child: Row(children: [
          CustomCard(
            height: 75,
            width: 90,
            isBorder: true,
            borderRadius: Dimensions.r10,
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.p10,
                vertical: Dimensions
                    .fs10), // المسافة بين الصورة والبرواز
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
          const SizedBox(width: Dimensions.p16),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${'id_label'.tr}: ',
                        style: robotoSemiBold.copyWith(
                          fontSize: Dimensions.fs14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      TextSpan(
                        text: '#${orderModel.id}',
                        style: robotoSemiBold.copyWith(
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
                        padding: const EdgeInsets.all(
                            Dimensions.p5),
                        borderRadius: Dimensions.r10,
                        fillColor: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                        child: Center(
                          child: Text('parcel'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fs14,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              )),
                        ),
                      )
                    : const SizedBox(),
              ]),
              const SizedBox(height: Dimensions.p5),
              Text(
                parcel
                    ? orderModel.parcelCategory != null
                        ? orderModel.parcelCategory!.name!
                        : 'no_parcel_category_data_found'.tr
                    : orderModel.storeName ?? 'no_store_data_found'.tr,
                style: robotoSemiBold.copyWith(
                    fontSize: Dimensions.fs14,
                    color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: Dimensions.p5),
              Row(children: [
                Icon(
                  Icons.access_time,
                  size: 15,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(width: Dimensions.p5),
                Text(
                  DateConverterHelper.dateTimeStringToDateTime(
                      orderModel.createdAt!),
                  style: robotoMedium.copyWith(
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
