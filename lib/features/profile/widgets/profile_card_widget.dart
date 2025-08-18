import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:flutter/material.dart';

class ProfileCardWidget extends StatelessWidget {
  final String title;
  final String data;
  const ProfileCardWidget({super.key, required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: CustomCard(
      height: 100,
     isBorder: false,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(data,
            style: robotoSemiBold.copyWith(
              fontSize: Dimensions.fontSizeExtraLarge,
            )),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(title,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).hintColor,
            )),
      ]),
    ));
  }
}
