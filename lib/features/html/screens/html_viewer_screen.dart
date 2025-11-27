import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:wefrh_rider/common/widgets/custom_image_widget.dart';
import 'package:wefrh_rider/features/html/controllers/html_controller.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:url_launcher/url_launcher_string.dart';

class HtmlViewerScreen extends StatefulWidget {
  final bool isPrivacyPolicy;
  const HtmlViewerScreen({super.key, required this.isPrivacyPolicy});

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<HtmlController>().getHtmlText(widget.isPrivacyPolicy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title:
            widget.isPrivacyPolicy ? 'privacy_policy'.tr : 'terms_condition'.tr,
      ),
      body: GetBuilder<HtmlController>(builder: (htmlController) {
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.all(Dimensions.p16),
          margin: const EdgeInsets.only(top: Dimensions.p16),
          child: htmlController.htmlText != null
              ? SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CustomImageWidget(
                            image: ManagerAssets.privacyTermsImage,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(width: Dimensions.p12),
                          Expanded(
                            child: Text(
                              widget.isPrivacyPolicy
                                  ? 'read_our_privacy_policy'.tr
                                  : 'read_our_terms_condition'.tr,
                              style: robotoSemiBold.copyWith(
                                fontSize: Dimensions.fs18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.p24),
                      HtmlWidget(
                        htmlController.htmlText ?? '',
                        key: Key(widget.isPrivacyPolicy
                            ? 'privacy_policy'
                            : 'terms_condition'),
                        onTapUrl: (String url) {
                          return launchUrlString(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                    ],
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        );
      }),
    );
  }
}
