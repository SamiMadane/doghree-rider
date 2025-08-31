import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/navigation_handler/controllers/navigation_handler_controller.dart';
import 'package:sixam_mart_delivery/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart_delivery/features/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/title_widget.dart';

class OrderItemWidget extends StatelessWidget {
  final OrderModel order;
  final OrderDetailsModel orderDetails;
  
  // Flags to control what is visible
  final bool showImage;
  final bool showAddons;
  final bool showVariations;
  final bool showDiscount;
  final bool showUnitOrVeg;

  const OrderItemWidget({
    super.key,
    required this.order,
    required this.orderDetails,
    this.showImage = true,
    this.showAddons = true,
    this.showVariations = true,
    this.showDiscount = true,
    this.showUnitOrVeg = true,
  });

  @override
  Widget build(BuildContext context) {
    String addOnText = '';
    for (var addOn in orderDetails.addOns ?? []) {
      addOnText = '$addOnText${(addOnText.isEmpty) ? '' : ', '}${addOn.name} (${addOn.quantity})';
    }

    String variationText = '';
    if(orderDetails.variation!.isNotEmpty) {
      List<String> types = orderDetails.variation![0].type!.split('-');
      if(types.length == orderDetails.itemDetails!.choiceOptions!.length) {
        for(int i=0; i<types.length; i++) {
          variationText += '${i==0?'':' ,'}${orderDetails.itemDetails!.choiceOptions![i].title} - ${types[i]}';
        }
      } else {
        variationText = orderDetails.itemDetails!.variations![0].type!;
      }
    } else if(orderDetails.foodVariation!.isNotEmpty) {
      for(var varObj in orderDetails.foodVariation!) {
        variationText += '${variationText.isEmpty?'':' ,'}${varObj.name}(';
        for(int i=0; i<varObj.variationValues!.length; i++) {
          variationText += '${i==0?'':' ,'}${varObj.variationValues![i].level}';
        }
        variationText += ')';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if(showImage && orderDetails.itemDetails!.imageFullUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.r4),
                child: CustomImageWidget(
                  image: orderDetails.itemDetails!.imageFullUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            if(showImage) SizedBox(width: Dimensions.p10),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TitleWidget(
                        title: orderDetails.itemDetails!.name!,
                        titleStyle: robotoMedium.copyWith(
                          fontSize: Dimensions.fs14,
                        ),
                        showOrderCount: true,
                        orderCount: orderDetails.quantity!,
                      ),
                      Text(
                        PriceConverterHelper.convertPrice(orderDetails.price! - (showDiscount ? orderDetails.discountOnItem! : 0)),
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fs14,
                        ),
                      ),
                    ],
                  ),
                  if(showDiscount && orderDetails.discountOnItem! > 0)
                    Text(
                      PriceConverterHelper.convertPrice(orderDetails.price),
                      style: robotoMedium.copyWith(
                        decoration: TextDecoration.lineThrough,
                        fontSize: Dimensions.fs12,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  if(showUnitOrVeg &&
                    ((Get.find<NavigationHandlerController>().getModule(order.moduleType).unit! && orderDetails.itemDetails!.unitType != null)
                    || (Get.find<NavigationHandlerController>().configModel!.toggleVegNonVeg! && Get.find<NavigationHandlerController>().getModule(order.moduleType).vegNonVeg!))
                  )
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.p5, horizontal: Dimensions.p10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(Dimensions.r4),
                      ),
                      child: Text(
                        Get.find<NavigationHandlerController>().getModule(order.moduleType).unit!
                          ? orderDetails.itemDetails!.unitType ?? ''
                          : orderDetails.itemDetails!.veg == 0 ? 'non_veg'.tr : 'veg'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fs10, color: Theme.of(context).primaryColor),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        if(showAddons && addOnText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 60, top: Dimensions.p5),
            child: Text('addons'.tr + ': ' + addOnText,
              style: robotoRegular.copyWith(fontSize: Dimensions.fs12, color: Theme.of(context).disabledColor),
            ),
          ),

        if(showVariations && variationText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 60, top: Dimensions.p5),
            child: Text('variations'.tr + ': ' + variationText,
              style: robotoRegular.copyWith(fontSize: Dimensions.fs12, color: Theme.of(context).disabledColor),
            ),
          ),

      ],
    );
  }
}
