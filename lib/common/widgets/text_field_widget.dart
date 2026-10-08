import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class TextFieldWidget extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final int maxLines;
  final bool isPassword;
  final Function? onTap;
  final Function? onChanged;
  final Function? onSubmit;
  final bool isEnabled;
  final TextCapitalization capitalization;
  final Color? fillColor;
  final String? titleName;
  final bool title;
  final bool isRequired;

  const TextFieldWidget({
    super.key,
    this.hintText = '',
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.isEnabled = true,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.maxLines = 1,
    this.onSubmit,
    this.onChanged,
    this.capitalization = TextCapitalization.none,
    this.onTap,
    this.fillColor,
    this.isPassword = false,
    this.titleName,
    this.title = true,
    this.isRequired = false,
  });

  @override
  TextFieldWidgetState createState() => TextFieldWidgetState();
}

class TextFieldWidgetState extends State<TextFieldWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(children: [

      widget.title ? Row(children: [
        Text(
          widget.titleName ?? widget.hintText!,
          style: textMedium().copyWith(fontSize: Dimensions.fs16),
        ),
        SizedBox(width: Dimensions.w4),
        widget.isEnabled ? const SizedBox() : Text('(${'non_changeable'.tr})', style: textRegular().copyWith(
          fontSize: Dimensions.fs10, color: Theme.of(context).colorScheme.error,
        )),

        widget.isRequired ? Text('*', style: textBold().copyWith(color: Theme.of(context).primaryColor)) : const SizedBox(),

      ]) : const SizedBox(),
      SizedBox(height: widget.title ? Dimensions.h10 : 0),

      Container(
        decoration: BoxDecoration(
          boxShadow: Get.isDarkMode ? null : [BoxShadow(color: Colors.grey[200]!, spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 5))],
        ),
        child: TextField(
          maxLines: widget.maxLines,
          controller: widget.controller,
          focusNode: widget.focusNode,
          style: textRegular(),
          textInputAction: widget.inputAction,
          keyboardType: widget.inputType,
          cursorColor: Theme.of(context).primaryColor,
          textCapitalization: widget.capitalization,
          enabled: widget.isEnabled,
          autofocus: false,
          obscureText: widget.isPassword ? _obscureText : false,
          inputFormatters: widget.inputType == TextInputType.phone ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp('[0-9+]'))] : null,
          decoration: InputDecoration(
            hintText: widget.hintText,
            isDense: true,
            filled: true,
            fillColor: widget.fillColor ?? Theme.of(context).cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.r4), borderSide: BorderSide.none),
            hintStyle: textRegular().copyWith(color: Theme.of(context).hintColor),
            suffixIcon: widget.isPassword ? IconButton(
              icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Theme.of(context).hintColor.withValues(alpha: 0.3)),
              onPressed: _toggle,
            ) : null,
          ),
          onTap: widget.onTap as void Function()?,
          onSubmitted: (text) => widget.nextFocus != null ? FocusScope.of(context).requestFocus(widget.nextFocus)
              : widget.onSubmit != null ? widget.onSubmit!(text) : null,
          onChanged: widget.onChanged as void Function(String)?,
        ),
      ),

    ]);
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
