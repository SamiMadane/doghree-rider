import 'dart:async';
import 'package:flutter/material.dart';

class LoadingDots extends StatefulWidget {
  final Color color;
  const LoadingDots({super.key, required this.color});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _dotCount = (_dotCount % 3) + 1; // 1 → 2 → 3 → 1 ...
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '.' * _dotCount,
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: widget.color,
      ),
    );
  }
}
