import 'dart:async';

import 'package:flutter/material.dart';

class ReplayImage extends StatefulWidget {
  final String asset;
  final double size;

  final Duration interval;

  const ReplayImage({
    super.key,
    required this.asset,
    this.size = 100,
    this.interval = const Duration(seconds: 4),
  });

  @override
  State<ReplayImage> createState() => _ReplayImageState();
}

class _ReplayImageState extends State<ReplayImage> {
  Key _key = UniqueKey();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (_) => _replay());
  }

  Future<void> _replay() async {
    if (!mounted) return;
    final ImageConfiguration config = createLocalImageConfiguration(context);
    await AssetImage(widget.asset).evict(configuration: config);
    if (mounted) setState(() => _key = UniqueKey());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      widget.asset,
      key: _key,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
    );
  }
}
