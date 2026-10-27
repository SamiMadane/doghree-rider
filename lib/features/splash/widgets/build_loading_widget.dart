// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:doghree_rider/util/dimensions.dart';
// import 'package:doghree_rider/util/manager_assets.dart';
// import 'package:doghree_rider/util/styles.dart';

// Widget buildLoadingWidget(BuildContext context) {
//   return Container(
//     decoration: BoxDecoration(color: Theme.of(context).cardColor),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Spacer(flex: 2),

//         ShimmerLogo(
//           logoPath: ManagerAssets.logo,
//         ),

//         SizedBox(height: Dimensions.h40),

//         FadeInText(
//           text: "Wefrh Rider".tr,
//           style: textSemiBold().copyWith(
//             fontSize: Dimensions.fs24,
//             color: Theme.of(context).textTheme.bodyMedium!.color,
//             letterSpacing: 1.0,
//           ),
//         ),

//         SizedBox(height: Dimensions.h20),

//         // نقاط نابضة
//         const PulsingDots(),

//         // SizedBox(height: Dimensions.h50),

//         // // شريط تحميل متموج
//         // const WaveProgressIndicator(),

//         SizedBox(height: Dimensions.h25),

//         // رسائل منزلقة
//         const SlidingMessages(),

//         const Spacer(flex: 2),

//         // شاشة تحتية بسيطة
//         Text(
//           'ensuring_safe_delivery'.tr,
//           style: textRegular().copyWith(
//             fontSize: Dimensions.fs12,
//             color:
//                 Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
//           ),
//         ),

//         SizedBox(height: Dimensions.h30),
//       ],
//     ),
//   );
// }

// // شعار مع تأثير البريق (Shimmer)
// class ShimmerLogo extends StatefulWidget {
//   final String logoPath;
//   const ShimmerLogo({super.key, required this.logoPath});

//   @override
//   State<ShimmerLogo> createState() => _ShimmerLogoState();
// }

// class _ShimmerLogoState extends State<ShimmerLogo>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _shimmerAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 2500),
//       vsync: this,
//     );

//     _shimmerAnimation = Tween<double>(
//       begin: -2.0,
//       end: 2.0,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     ));

//     _controller.repeat();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
// Widget build(BuildContext context) {
//   return AnimatedBuilder(
//     animation: _shimmerAnimation,
//     builder: (context, child) {
//       return ShaderMask(
//         shaderCallback: (bounds) {
//           return LinearGradient(
//             begin: Alignment(_shimmerAnimation.value - 1, -1),
//             end: Alignment(_shimmerAnimation.value, 1),
//             colors: [
//               Colors.transparent,
//               Colors.white.withOpacity(0.5),
//               Colors.transparent,
//             ],
//             stops: const [0.0, 0.5, 1.0],
//           ).createShader(bounds);
//         },
//         blendMode: BlendMode.srcATop, // يخلي التدرج يطبق فقط على صورة اللوجو
//         child: Image.asset(
//           widget.logoPath,
//           width: 120,
//           height: 120,
//         ),
//       );
//     },
//   );
// }

// }

// // نص يظهر تدريجياً
// class FadeInText extends StatefulWidget {
//   final String text;
//   final TextStyle style;

//   const FadeInText({
//     super.key,
//     required this.text,
//     required this.style,
//   });

//   @override
//   State<FadeInText> createState() => _FadeInTextState();
// }

// class _FadeInTextState extends State<FadeInText>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.3,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     ));

//     _controller.repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _fadeAnimation,
//       builder: (context, child) {
//         return Opacity(
//           opacity: _fadeAnimation.value,
//           child: Text(
//             widget.text,
//             style: widget.style,
//           ),
//         );
//       },
//     );
//   }
// }

// // نقاط نابضة بشكل دائري
// class PulsingDots extends StatefulWidget {
//   const PulsingDots({super.key});

//   @override
//   State<PulsingDots> createState() => _PulsingDotsState();
// }

// class _PulsingDotsState extends State<PulsingDots>
//     with TickerProviderStateMixin {
//   late List<AnimationController> _controllers;

//   @override
//   void initState() {
//     super.initState();
//     _controllers = List.generate(
//       5,
//       (index) => AnimationController(
//         duration: const Duration(milliseconds: 1200),
//         vsync: this,
//       ),
//     );

//     for (int i = 0; i < _controllers.length; i++) {
//       Future.delayed(Duration(milliseconds: i * 200), () {
//         if (mounted) {
//           _controllers[i].repeat(reverse: true);
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(5, (index) {
//         return AnimatedBuilder(
//           animation: _controllers[index],
//           builder: (context, child) {
//             return Container(
//               margin: EdgeInsets.symmetric(horizontal: 4),
//               width: 8,
//               height: 8,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Theme.of(context).primaryColor.withOpacity(
//                       0.3 + 0.7 * _controllers[index].value,
//                     ),
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }
// }

// // مؤشر تحميل متموج
// class WaveProgressIndicator extends StatefulWidget {
//   const WaveProgressIndicator({super.key});

//   @override
//   State<WaveProgressIndicator> createState() => _WaveProgressIndicatorState();
// }

// class _WaveProgressIndicatorState extends State<WaveProgressIndicator>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );
//     _controller.repeat();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width * 0.6,
//       height: 6,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(3),
//         color: Theme.of(context).dividerColor.withOpacity(0.2),
//       ),
//       child: AnimatedBuilder(
//         animation: _controller,
//         builder: (context, child) {
//           return CustomPaint(
//             painter: WavePainter(
//               animationValue: _controller.value,
//               color: Theme.of(context).primaryColor,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // رسام الموجة
// class WavePainter extends CustomPainter {
//   final double animationValue;
//   final Color color;

//   WavePainter({required this.animationValue, required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color.withOpacity(0.7)
//       ..style = PaintingStyle.fill;

//     final path = Path();
//     final waveLength = size.width / 2;
//     final waveHeight = size.height * 0.3;

//     path.moveTo(0, size.height / 2);

//     for (double x = 0; x <= size.width; x += 1) {
//       double y = size.height / 2 +
//           waveHeight *
//               sin((x / waveLength * 2 * pi) + (animationValue * 2 * pi));
//       path.lineTo(x, y);
//     }

//     path.lineTo(size.width, size.height);
//     path.lineTo(0, size.height);
//     path.close();

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// // رسائل منزلقة
// class SlidingMessages extends StatefulWidget {
//   const SlidingMessages({super.key});

//   @override
//   State<SlidingMessages> createState() => _SlidingMessagesState();
// }

// class _SlidingMessagesState extends State<SlidingMessages>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   int _currentIndex = 0;
//   late Timer _timer;

//   final List<String> _messages = [
//     'loading_new_orders'.tr,
//     'tracking_parcels_map'.tr,
//     'preparing_food_relief_parcels'.tr,
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );


//     _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
//       if (mounted) {
//         _slideNext();
//       }
//     });
//   }

//   void _slideNext() {
//     _controller.reset();
//     _controller.forward().then((_) {
//       setState(() {
//         _currentIndex = (_currentIndex + 1) % _messages.length;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _timer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 30,
//       alignment: Alignment.center,
//       child: AnimatedSwitcher(
//         duration: const Duration(milliseconds: 500),
//         transitionBuilder: (child, animation) {
//           return SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(0, 1),
//               end: const Offset(0, 0),
//             ).animate(animation),
//             child: child,
//           );
//         },
//         child: Text(
//           _messages[_currentIndex],
//           key: ValueKey(_currentIndex),
//           style: TextStyle(
//             fontSize: 14,
//             color:
//                 Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }
// }
