import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:wefrh_rider/helper/route_helper.dart';

class CaptureIdScreen extends StatefulWidget {
  @override
  _CaptureIdScreenState createState() => _CaptureIdScreenState();
}

class _CaptureIdScreenState extends State<CaptureIdScreen> {
  CameraController? controller;

  final double frameWidth = 320;
  final double frameHeight = 200;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(cameras.first, ResolutionPreset.high);
    await controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (controller == null || !controller!.value.isInitialized) return;

    final image = await controller!.takePicture();

    // قراءة الصورة كـ bytes
    final bytes = await File(image.path).readAsBytes();
    img.Image captured = img.decodeImage(bytes)!;

    // أبعاد الصورة الفعلية من الكاميرا
    final imageWidth = captured.width;
    final imageHeight = captured.height;

    // أبعاد الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // نسبة العرض للارتفاع للكاميرا والشاشة
    final cameraAspectRatio = imageWidth / imageHeight;
    final screenAspectRatio = screenWidth / screenHeight;

    // حساب الأبعاد الحقيقية للـ preview على الشاشة
    double previewWidth, previewHeight;
    double offsetX = 0, offsetY = 0;

    if (cameraAspectRatio > screenAspectRatio) {
      // الكاميرا أعرض من الشاشة - سيكون هناك قص من الأعلى والأسفل
      previewWidth = screenWidth;
      previewHeight = screenWidth / cameraAspectRatio;
      offsetY = (screenHeight - previewHeight) / 2;
    } else {
      // الكاميرا أطول من الشاشة - سيكون هناك قص من الجانبين
      previewHeight = screenHeight;
      previewWidth = screenHeight * cameraAspectRatio;
      offsetX = (screenWidth - previewWidth) / 2;
    }

    // حساب موقع المربع الأبيض نسبة للـ preview الفعلي
    final frameCenterX = screenWidth / 2;
    final frameCenterY = screenHeight / 2;
    
    // تحويل إحداثيات المربع من إحداثيات الشاشة إلى إحداثيات الـ preview
    final frameLeftOnPreview = frameCenterX - frameWidth / 2 - offsetX;
    final frameTopOnPreview = frameCenterY - frameHeight / 2 - offsetY;

    // حساب النسب داخل الـ preview
    final leftRatio = frameLeftOnPreview / previewWidth;
    final topRatio = frameTopOnPreview / previewHeight;
    final widthRatio = frameWidth / previewWidth;
    final heightRatio = frameHeight / previewHeight;

    // تطبيق هذه النسب على الصورة الفعلية
    int cropX = (imageWidth * leftRatio).clamp(0, imageWidth).toInt();
    int cropY = (imageHeight * topRatio).clamp(0, imageHeight).toInt();
    int cropWidth = (imageWidth * widthRatio).clamp(0, imageWidth - cropX).toInt();
    int cropHeight = (imageHeight * heightRatio).clamp(0, imageHeight - cropY).toInt();

    print('Original image: ${imageWidth}x${imageHeight}');
    print('Screen: ${screenWidth.toInt()}x${screenHeight.toInt()}');
    print('Preview: ${previewWidth.toInt()}x${previewHeight.toInt()}');
    print('Crop: x=$cropX, y=$cropY, w=$cropWidth, h=$cropHeight');

    // تنفيذ القص
    img.Image cropped = img.copyCrop(
      captured,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    // حفظ الصورة الجديدة
    final croppedPath = '${image.path}_cropped.jpg';
    File(croppedPath).writeAsBytesSync(img.encodeJpg(cropped));

    print('Cropped image saved: $croppedPath');
    print('Cropped size: ${cropped.width}x${cropped.height}');

    // إرسالها لصفحة المعاينة
    Get.toNamed(RouteHelper.getPreviewIdRoute(), arguments: croppedPath);
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // ملء الشاشة بالكامل بالكاميرا
          Positioned.fill(
            child: CameraPreview(controller!),
          ),

          // تغطية داكنة + فتحة في النص
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: frameWidth,
                    height: frameHeight,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // نص توضيحي
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - frameHeight / 2 - 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ضع الهوية داخل المربع',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // زر التقاط
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 5),
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // زر الإغلاق
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}