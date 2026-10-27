import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/language/controllers/language_controller.dart';
import 'package:doghree_rider/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:doghree_rider/features/splash/screens/splash_screen.dart';

class LanguageInitScreen extends StatefulWidget {
  const LanguageInitScreen({super.key});

  @override
  State<LanguageInitScreen> createState() => _LanguageInitScreenState();
}

class _LanguageInitScreenState extends State<LanguageInitScreen> {
  @override
  void initState() {
    super.initState();

    // التأكد من أن اللغة لم تُختار مسبقًا
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localizationController = Get.find<LocalizationController>();
      if (localizationController.selectedLanguageIndex == -1) {
        _showLanguageBottomSheet();
      } else {
        // إذا اللغة مختارة مسبقًا نذهب مباشرة للشاشة التالية
        Get.offAll(() => const SplashScreen(body: null));
      }
    });
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => LanguageBottomSheetWidget(isFromInitScreen: true,),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
