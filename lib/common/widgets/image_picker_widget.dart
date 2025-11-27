import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wefrh_rider/common/widgets/dotted_border_widget.dart';
import 'package:wefrh_rider/util/dimensions.dart';

class ImagePickerWidget extends StatelessWidget {
  final String? pickedImagePath;
  final String? networkImageUrl;
  final String placeholderText;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final bool showErrorBorder;
  final double height;
  final double? width;
  final bool isExpanded;

  const ImagePickerWidget({
    super.key,
    this.pickedImagePath,
    this.networkImageUrl,
    required this.placeholderText,
    required this.onPickImage,
    required this.onRemoveImage,
    this.showErrorBorder = false,
    this.height = 150,
    this.width,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = pickedImagePath != null || networkImageUrl != null;

    Widget imageWidget = Stack(
      children: [
        if (hasImage)
          _buildImageWithBorder(context)
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.r10),
            child: _buildPlaceholder(context),
          ),
        if (hasImage) _buildRemoveButton(),
      ],
    );

    if (isExpanded) {
      return Expanded(child: imageWidget);
    }

    return SizedBox(
      height: height,
      width: width,
      child: imageWidget,
    );
  }

  Widget _buildImageWithBorder(BuildContext context) {
    return CustomPaint(
      painter: AlternatingDottedBorderPainter(
        color1: (Theme.of(context).textTheme.bodyMedium!.color)!,
        color2: Theme.of(context).cardColor,
        strokeWidth: 2,
        dashPattern: [5, 3],
        radius: Dimensions.r10,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.r10 - 2),
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (pickedImagePath != null) {
      return Image.file(
        File(pickedImagePath!),
        height: height,
        width: width ?? double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      networkImageUrl!,
      height: height,
      width: width ?? double.infinity,
      fit: BoxFit.cover,
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: DottedBorderWidget(
        showErrorBorder: showErrorBorder,
        text: placeholderText,
        onTap: onPickImage,
      ),
    );
  }

  Widget _buildRemoveButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: InkWell(
        onTap: onRemoveImage,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(200),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: const Center(
                child: Icon(Icons.clear, color: Colors.black, size: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter للرسم المتناوب بين لونين
class AlternatingDottedBorderPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double strokeWidth;
  final List<double> dashPattern;
  final double radius;

  AlternatingDottedBorderPainter({
    required this.color1,
    required this.color2,
    required this.strokeWidth,
    required this.dashPattern,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    final pathMetrics = path.computeMetrics();
    
    for (var metric in pathMetrics) {
      double distance = 0;
      bool useFirstColor = true;

      while (distance < metric.length) {
        final dashLength = dashPattern[0];
        final gapLength = dashPattern[1];

        if (distance + dashLength > metric.length) {
          break;
        }

        final extractPath = metric.extractPath(
          distance,
          distance + dashLength,
        );

        final paint = Paint()
          ..color = useFirstColor ? color1 : color2
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        canvas.drawPath(extractPath, paint);

        distance += dashLength + gapLength;
        useFirstColor = !useFirstColor;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}