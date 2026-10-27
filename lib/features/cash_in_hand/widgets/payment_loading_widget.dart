import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:get/get.dart';

class PaymentLoadingWidget extends StatelessWidget {
  const PaymentLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ManagerColors.white,
            ManagerColors.primaryLight.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom animated payment card
            _AnimatedPaymentCard(
              primaryColor: ManagerColors.primaryLight,
            ),

            const SizedBox(height: 48),

            // Progress indicator with percentage
            _AnimatedProgressIndicator(
              primaryColor: ManagerColors.primaryLight,
            ),

            const SizedBox(height: 32),

            Text(
              'processing_payment'.tr,
              style: textMedium().copyWith(
                fontSize: Dimensions.fs20,
                color: ManagerColors.TextColorLight,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'please_wait'.tr,
                textAlign: TextAlign.center,
                style: textRegular().copyWith(
                  fontSize: Dimensions.fs14,
                  color: ManagerColors.TextColorLight.withOpacity(0.6),
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Security indicators
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: ManagerColors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.green.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_user,
                    size: 18,
                    color: Colors.green,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'secure_connection'.tr,
                    style: textMedium().copyWith(
                      fontSize: Dimensions.fs13,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: 8),
                  const Icon(
                    Icons.lock,
                    size: 16,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedPaymentCard extends StatefulWidget {
  final Color primaryColor;

  const _AnimatedPaymentCard({required this.primaryColor});

  @override
  State<_AnimatedPaymentCard> createState() => _AnimatedPaymentCardState();
}

class _AnimatedPaymentCardState extends State<_AnimatedPaymentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 200,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    widget.primaryColor,
                    widget.primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.3),
                    blurRadius: 25,
                    spreadRadius: 3,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Card chip
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Container(
                      width: 40,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  // Card icon
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: Icon(
                      Icons.credit_card,
                      color: Colors.white.withOpacity(0.9),
                      size: 40,
                    ),
                  ),
                  // Animated waves
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomPaint(
                        painter: _WavePainter(
                          animationValue: _controller.value,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;

  _WavePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 10.0;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height * 0.7);

    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.7 +
            waveHeight *
                math.sin((i / waveLength * 2 * math.pi) +
                    (animationValue * 2 * math.pi)),
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AnimatedProgressIndicator extends StatefulWidget {
  final Color primaryColor;

  const _AnimatedProgressIndicator({required this.primaryColor});

  @override
  State<_AnimatedProgressIndicator> createState() =>
      _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<_AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          children: [
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progressAnimation.value,
                  minHeight: 8,
                  backgroundColor: widget.primaryColor.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(_progressAnimation.value * 100).toInt()}%',
              style: textMedium().copyWith(
                fontSize: Dimensions.fs16,
                color: widget.primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }
}