import 'package:permission_handler/permission_handler.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/profile/widgets/account_section.dart';
import 'package:sixam_mart_delivery/features/profile/widgets/legal_section.dart';
import 'package:sixam_mart_delivery/features/profile/widgets/user_profile_info_card.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();

    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
    );
    Get.find<ProfileController>().getProfile();
  }

  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        checkBatteryPermission();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  void checkBatteryPermission() async {
    Future.delayed(const Duration(milliseconds: 400), () async {
      if (await Permission.ignoreBatteryOptimizations.status.isDenied) {
        Get.find<ProfileController>().setBackgroundNotificationActive(false);
      } else {
        Get.find<ProfileController>().setBackgroundNotificationActive(true);
      }
    });
  }

  @override
  dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
        title: 'profile'.tr,
        isBackButtonExist: false,
      ),
      body: GetBuilder<ProfileController>(builder: (profileController) {
        return profileController.profileModel == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(children: [
                    UserProfileInfoCard(profileController: profileController),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    AccountSection(profileController: profileController),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    LegalSection(profileController: profileController),
                  ]),
                ));
      }),
    );
  }
}
