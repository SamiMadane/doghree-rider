import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:vibration/vibration.dart';

class SliderButton extends StatefulWidget {
  ///To make button more customizable add your child widget
  final Widget? child;

  ///Sets the radius of corners of a button.
  final double radius;

  final double height;
  final double width;
  final double buttonSize;

  final Color backgroundColor;
  final Color baseColor;
  final Color highlightedColor;
  final Color buttonColor;

  ///Accepts either String or Widget
  final Object? label;

  final Alignment alignLabel;
  final BoxShadow boxShadow;
  final Widget icon;
  final Function action;

  final bool shimmer;
  final bool dismissible;
  final bool vibrationFlag;
  final double dismissThresholds;
  final bool disable;
  final bool isLtr;

  const SliderButton({
    super.key,
    required this.action,
    this.radius = 100,
    this.boxShadow = const BoxShadow(color: Colors.black, blurRadius: 4),
    this.child,
    this.isLtr = true,
    this.vibrationFlag = true,
    this.shimmer = true,
    this.height = 70,
    this.buttonSize = 60,
    this.width = 250,
    this.alignLabel = const Alignment(0.0, 0),
    this.backgroundColor = const Color(0xffe0e0e0),
    this.baseColor = Colors.black87,
    this.buttonColor = Colors.white,
    this.highlightedColor = Colors.white,
    this.label,
    this.icon = const Icon(
      Icons.power_settings_new,
      color: Colors.red,
      size: 30.0,
    ),
    this.dismissible = true,
    this.dismissThresholds = 1.0,
    this.disable = false,
  }) : assert(buttonSize <= height);

  @override
  SliderButtonState createState() => SliderButtonState();
}

class SliderButtonState extends State<SliderButton>
    with SingleTickerProviderStateMixin {
  bool? flag;
  Widget? _child;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Key _dismissibleKey = UniqueKey(); // مفتاح فريد للـ Dismissible

  @override
  void initState() {
    super.initState();
    flag = true;
    _child = widget.child;
    
    // تهيئة الـ AnimationController للتحكم في الرجوع للوضع الأساسي
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLabel() {
    if (widget.label == null) return const SizedBox();
    if (widget.label is String) {
      return Text(
        widget.label as String,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      );
    }
    if (widget.label is Widget) {
      return widget.label as Widget;
    }
    return const SizedBox();
  }

  // دالة لإعادة تعيين الزر بعد السحب
  void _resetButton() {
    setState(() {
      _dismissibleKey = UniqueKey(); // إنشاء مفتاح جديد
    });
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return flag == true
        ? _control()
        : widget.dismissible == true
            ? Container()
            : Container(child: _control());
  }

  Widget _control() => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: widget.disable
              ? Colors.grey.shade700
              : Get.isDarkMode
                  ? Colors.white12
                  : widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
        alignment: Alignment.centerLeft,
        child: Stack(alignment: Alignment.centerLeft, children: <Widget>[
          Container(
            alignment: widget.alignLabel,
            child: widget.shimmer && !widget.disable
                ? Shimmer(
                    color: ManagerColors.shimmer,
                    child: _buildLabel(),
                  )
                : _buildLabel(),
          ),
          widget.disable
              ? Tooltip(
                  verticalOffset: 50,
                  message: 'Button is disabled',
                  child: _buildButtonContainer(),
                )
              : Dismissible(
                  key: _dismissibleKey, // استخدام المفتاح الفريد
                  direction: DismissDirection.startToEnd, // السحب من اليسار لليمين دائماً
                  movementDuration: const Duration(milliseconds: 300),
                  confirmDismiss: (direction) async {
                    // تنفيذ الإجراء
                    widget.action();
                    
                    // تفعيل الاهتزاز إن أردت
                    if (widget.vibrationFlag && await Vibration.hasVibrator()) {
                      Vibration.vibrate(duration: 200);
                    }
                    
                    // إعادة تعيين الزر بعد تأخير قصير
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _resetButton();
                    });
                    
                    // إرجاع false لمنع الإزالة الفعلية للـ widget
                    return false;
                  },
                  child: _buildButtonContainer(),
                ),
          const SizedBox.expand(),
        ]),
      );

  Widget _buildButtonContainer() {
    return Container(
      width: widget.width - (widget.height),
      height: widget.height,
      alignment: widget.isLtr ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.only(left: (widget.height - widget.buttonSize) / 2),
      child: _child ??
          Container(
            height: widget.buttonSize,
            width: widget.buttonSize,
            decoration: BoxDecoration(
              boxShadow: [widget.boxShadow],
              color: widget.disable ? Colors.grey : widget.buttonColor,
              borderRadius: BorderRadius.circular(widget.radius),
            ),
            child: Center(child: widget.icon),
          ),
    );
  }
}