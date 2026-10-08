import 'package:flutter/material.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ProfileOrderCardWidget extends StatelessWidget {
  final String title;
  final String? value;
  final String imagePath;
  final double height;
  final bool isTopCard;

  const ProfileOrderCardWidget({
    super.key,
    required this.title,
    this.value,
    required this.imagePath,
    required this.height,
    this.isTopCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.contain,
        ),
        borderRadius: BorderRadius.circular(Dimensions.r10),
      ),
      padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textSemiBold().copyWith(
              color: Colors.white,
              fontSize: isTopCard ? Dimensions.fs24:Dimensions.fs18,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Dimensions.h4),
          value != null
              ? Text(
                  value!,
                  style: textSemiBold().copyWith(
                    fontSize: Dimensions.fs24,
                    color: Colors.white, // أو overlay لون إذا الصورة فاتحة
                  ),
                  textAlign: TextAlign.center,
                )
              : Shimmer(
                  duration: const Duration(seconds: 2),
                  color: Colors.grey[500]!,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
