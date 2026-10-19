import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';

class CustomTextFieldWidget extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final bool isPassword;
  final Function? onChanged;
  final Function? onSubmit;
  final Function? onEditingComplete;
  final bool isEnabled;
  final int maxLines;
  final int? maxLength;
  final TextCapitalization capitalization;
  final bool hideEnableText;
  final Color? fillColor;

  final IconData? prefixIcon;
  final String? prefixImage;
  final double? prefixSize;
  final double iconSize;
  final double? borderRadius;

  final bool divider;
  final bool showTitle;
  final bool border;
  final bool isRequired;

  final bool isAmount;
  final bool isNumber;
  final bool isPhone;

  final String? countryDialCode;
  final Function(CountryCode countryCode)? onCountryChanged;

  final bool showLabelText;
  final String? labelText;
  final double? labelTextSize;

  final bool required;
  final Widget? suffixChild;
  final String? Function(String?)? validator;

  // NEW PARAMETERS
  final bool readOnly;
  final VoidCallback? onTap;

    final String? errorText;


  const CustomTextFieldWidget({
    super.key,
    this.hintText,
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.isEnabled = true,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.maxLines = 1,
    this.maxLength,
    this.onSubmit,
    this.onChanged,
    this.onEditingComplete,
    this.capitalization = TextCapitalization.none,
    this.isPassword = false,
    this.isAmount = false,
    this.isNumber = false,
    this.isPhone = false,
    this.countryDialCode,
    this.onCountryChanged,
    this.prefixIcon,
    this.prefixImage,
    this.prefixSize,
    this.iconSize = 18,
    this.borderRadius,
    this.divider = false,
    this.showTitle = false,
    this.border = true,
    this.isRequired = false,
    this.showLabelText = true,
    this.labelText,
    this.labelTextSize,
    this.required = false,
    this.suffixChild,
    this.validator,
    this.hideEnableText = false,
    this.fillColor,
    this.readOnly = false,
    this.onTap,

    this.errorText,

  });

  @override
  CustomTextFieldWidgetState createState() => CustomTextFieldWidgetState();
}

class CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(() {
      if (mounted) setState(() {});
    });
    widget.controller?.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    bool showLabelInside = widget.showLabelText &&
        !(widget.focusNode?.hasFocus == true ||
            (widget.controller?.text.isNotEmpty ?? false));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle)
          Padding(
            padding: EdgeInsets.only(bottom: Dimensions.h4),
            child: Text(widget.hintText ?? 'write_something'.tr,
                style: textRegular().copyWith(fontSize: Dimensions.fs12)),
          ),
        Directionality(
          textDirection:
              widget.isPhone ? TextDirection.ltr : Directionality.of(context),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            validator: widget.validator,
            style: textRegular().copyWith(fontSize: Dimensions.fs16),
            textInputAction: widget.inputAction,
            keyboardType: widget.isAmount
                ? TextInputType.numberWithOptions(decimal: true)
                : widget.isNumber
                    ? TextInputType.number
                    : widget.inputType,
            cursorColor: Theme.of(context).primaryColor,
            textCapitalization: widget.capitalization,
            enabled: widget.isEnabled,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            autofocus: false,
            textDirection: widget.isPhone ? TextDirection.ltr : null,
            obscureText: widget.isPassword ? _obscureText : false,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputType == TextInputType.phone
                ? [FilteringTextInputFormatter.allow(RegExp('[0-9+]'))]
                : widget.isAmount
                    ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                    : widget.isNumber
                        ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
                        : null,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    widget.borderRadius ?? Dimensions.r16),
                borderSide: BorderSide(
                  style: widget.border ? BorderStyle.solid : BorderStyle.none,
                  color: Theme.of(context).dividerTheme.color!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    widget.borderRadius ?? Dimensions.r16),
                borderSide: BorderSide(
                  style: widget.border ? BorderStyle.solid : BorderStyle.none,
                  color: Theme.of(context).dividerTheme.color!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    widget.borderRadius ?? Dimensions.r16),
                borderSide: BorderSide(
                  style: widget.border ? BorderStyle.solid : BorderStyle.none,
                  width: 1.5,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    widget.borderRadius ?? Dimensions.r16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              isDense: true,
              hintText: widget.hintText,


                         error: widget.errorText == null
                  ? null
                  : Directionality(
                      textDirection: Directionality.of(context),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          widget.errorText!,
                          textAlign: TextAlign.start,
                          style: textRegular().copyWith(
                            fontSize: Dimensions.fs12,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    widget.borderRadius ?? Dimensions.r16),
                borderSide: BorderSide(
                  width: 1.5,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              fillColor: widget.fillColor ?? Theme.of(context).cardColor,
              filled: true,
              hintStyle: textRegular().copyWith(
                fontSize: Dimensions.fs16,
                color: Theme.of(context).hintColor,
              ),
              label: showLabelInside
                  ? Text.rich(TextSpan(children: [
                      TextSpan(
                        text: widget.labelText ?? '',
                        style: textRegular().copyWith(
                          fontSize: widget.labelTextSize ?? Dimensions.fs14,
                          color: Theme.of(context).hintColor.withAlpha(180),
                        ),
                      ),
                      if (widget.isRequired && widget.labelText != null)
                        TextSpan(
                          text: ' *',
                          style: textRegular().copyWith(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: Dimensions.fs14,
                          ),
                        ),
                    ]))
                  : null,
              alignLabelWithHint: widget.maxLines > 1,
              prefixIcon: _buildPrefix(context),
              suffixIcon: _buildSuffix(context),
            ),
            onFieldSubmitted: (text) => widget.nextFocus != null
                ? FocusScope.of(context).requestFocus(widget.nextFocus)
                : widget.onSubmit != null
                    ? widget.onSubmit!(text)
                    : null,
            onChanged: widget.onChanged as void Function(String)?,
            onEditingComplete: widget.onEditingComplete as void Function()?,
          ),
        ),
        if (widget.divider)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.w20),
            child: Divider(),
          ),
      ],
    );
  }

  Widget? _buildPrefix(BuildContext context) {
    if (widget.isPhone) {
      return SizedBox(
        width: 95,
        child: Row(
          children: [
            Container(
              width: 85,
              height: 50,
              margin: EdgeInsets.zero,
              padding: EdgeInsetsDirectional.only(start: Dimensions.w5),
              child: Center(
                child: Row(
                  children: [
                    SizedBox(width: Dimensions.w5),
                    Image.asset(
                      ManagerAssets.psFlag,
                      width: 25,
                      height: 25,
                    ),
                    SizedBox(width: Dimensions.w5),
                    Text(
                      '+970',
                      style: textRegular().copyWith(
                        fontSize: Dimensions.fs14,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 20,
              width: 2,
              color: Theme.of(context).disabledColor,
            ),
          ],
        ),
      );
    } else if (widget.prefixImage != null) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.prefixSize ?? Dimensions.r10,
        ),
        child: SvgPicture.asset(
          widget.prefixImage!,
          height: 20,
          width: 20,
          // ignore: deprecated_member_use
          color: Theme.of(context).hintColor,
        ),
      );
    } else if (widget.prefixIcon != null) {
      return Icon(widget.prefixIcon,
          size: widget.iconSize, color: Theme.of(context).hintColor);
    }
    return null;
  }

  Widget? _buildSuffix(BuildContext context) {
    if (widget.isPassword) {
      return IconButton(
        icon: _obscureText
            ? SvgPicture.asset(
                ManagerAssets.visibilityOffIcon,
                width: 24,
                height: 24,
                // ignore: deprecated_member_use
                color: Theme.of(context).hintColor,
              )
            : SvgPicture.asset(
                ManagerAssets.visibilityIcon,
                width: 24,
                height: 24,
                // ignore: deprecated_member_use
                color: Theme.of(context).hintColor,
              ),
        onPressed: _toggle,
      );
    } else if (widget.suffixChild != null) {
      return widget.suffixChild!;
    }
    return null;
  }

  void _toggle() => setState(() => _obscureText = !_obscureText);
}
