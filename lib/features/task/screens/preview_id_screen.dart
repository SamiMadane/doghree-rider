import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/util/theme_extension.dart';

class PreviewIdScreen extends StatefulWidget {
  final String image;
  const PreviewIdScreen({required this.image});

  @override
  _PreviewIdScreenState createState() => _PreviewIdScreenState();
}

class _PreviewIdScreenState extends State<PreviewIdScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _retakePhoto() {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
  }

  void _confirmPhoto() {
    HapticFeedback.mediumImpact();
    Navigator.pop(context, widget.image);
  }

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
        onBackPressed: _retakePhoto,
        backGroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: "preview_id_title".tr,
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(Dimensions.p20),
                  child: Column(
                    children: [
                      SizedBox(height: Dimensions.p20),

                      // حاوي الصورة البسيط
                      Expanded(
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.9,
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.65,
                            ),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.r16),
                              color: Theme.of(context).cardColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).shadowColor,
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(Dimensions.p12),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.r12),
                              child: Container(
                                color: customColor.grayBg,
                                child: Image.file(
                                  File(widget.image),
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: Dimensions.p30),

                      // مؤشر النجاح البسيط
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.p16,
                          vertical: Dimensions.p8,
                        ),
                        decoration: BoxDecoration(
                          color: customColor.greenBg,
                          borderRadius: BorderRadius.circular(Dimensions.r20),
                          border: Border.all(
                            color:
                                customColor.green.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: ManagerColors.greenLightMode,
                              size: 18,
                            ),
                            SizedBox(width: Dimensions.p8),
                            Text(
                              "preview_id_success".tr,
                              style: robotoBold.copyWith(
                                color: ManagerColors.greenLightMode,
                                fontSize: Dimensions.fs14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: Dimensions.p40),

                      // الأزرار البسيطة
                      Row(
                        children: [
                          // زر إعادة الالتقاط
                          Expanded(
                            child: CustomButtonWidget(
                              buttonText: 'preview_id_retake'.tr,
                              backgroundColor: ManagerColors.grayCirule,
                              onPressed: _retakePhoto,
                              height: Dimensions.p56,
                              radius: Dimensions.r16,
                              icon: Icon(
                                Icons.refresh,
                                color: ManagerColors.white,
                                size: 20,
                              ),
                            ),
                          ),

                          SizedBox(width: Dimensions.p12),

                          // زر التأكيد
                          Expanded(
                            child: CustomButtonWidget(
                              onPressed: _confirmPhoto,
                              buttonText: 'preview_id_confirm'.tr,
                              height: Dimensions.p56,
                              radius: Dimensions.r16,
                              fontSize: Dimensions.fs15,
                              icon: SvgPicture.asset(
                                ManagerAssets.checkIcon,
                                color: ManagerColors.white,
                                height: 20,
                                width: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: Dimensions.p20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
