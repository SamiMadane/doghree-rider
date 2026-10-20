import 'package:flutter/material.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';

class EmbeddingRateWidget extends StatelessWidget {
  final String title;
  final double percentage;
  final VoidCallback? onSeeAllPressed;

  const EmbeddingRateWidget({
    super.key,
    required this.title,
    required this.percentage,
    this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final fillRatio = (percentage / 100).clamp(0.0, 1.0);

    return Container(
      height: Dimensions.h56,
      decoration: BoxDecoration(
        color: ManagerColors.darkGreen.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // الجزء المملوء (يتحرك حسب النسبة)
          LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: constraints.maxWidth * fillRatio,
                decoration: BoxDecoration(
                  color: ManagerColors.darkGreen, // أخضر غامق
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(title,
                              style: textBold().copyWith(
                                  color: ManagerColors.white,
                                  fontSize: Dimensions.fs15)),
                          GestureDetector(
                            onTap: onSeeAllPressed,
                            child: Text('See All',
                                style: textBold().copyWith(
                                  color: ManagerColors.white,
                                  decoration: TextDecoration.underline,
                                  decorationColor: ManagerColors.white,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 8),

                // الجزء الأيمن: النسبة المئوية
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${percentage.toInt()}%',
                      style: textBold().copyWith(
                          color: ManagerColors.darkGreen,
                          fontSize: Dimensions.fs15)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// مثال على الاستخدام مع تغيير ديناميكي
class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  double percentage = 64;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: EmbeddingRateWidget(
                title: 'Embedding Rate',
                percentage: percentage,
                onSeeAllPressed: () {
                  print('See All pressed');
                },
              ),
            ),

            const SizedBox(height: 40),

            // Slider لتجربة التغيير الديناميكي
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    'النسبة: ${percentage.toInt()}%',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Slider(
                    value: percentage,
                    min: 0,
                    max: 100,
                    onChanged: (value) {
                      setState(() {
                        percentage = value;
                      });
                    },
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
