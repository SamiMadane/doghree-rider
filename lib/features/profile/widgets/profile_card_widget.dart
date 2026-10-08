import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';
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
            style: textSemiBold().copyWith(
              fontSize: Dimensions.fs18,
            )),
        SizedBox(height: Dimensions.h10),
        Text(title,
            style: textRegular().copyWith(
              fontSize: Dimensions.fs14,
              color: Theme.of(context).hintColor,
            )),
      ]),
    ));
  }
}
