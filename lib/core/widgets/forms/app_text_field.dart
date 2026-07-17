import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

class AppTextFormField extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final String? errorText;
  final Widget? suffix;
  final bool obscureText;

  const AppTextFormField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.errorText,
    this.suffix,
    this.obscureText = false,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late bool _obscureText = widget.obscureText;

  @override
  void didUpdateWidget(covariant AppTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.obscureText != oldWidget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  void _toggleObscureText() => setState(() => _obscureText = !_obscureText);

  static OutlineInputBorder _outline(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: AppRadius.radiusMd,
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final enabledBorder = _outline(
      hasError ? AppColors.danger : AppColors.borderDefault,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTextStyle.label),
          const SizedBox(height: AppSpacing.space2),
        ],
        TextFormField(
          onTapOutside: (event) => FocusScope.of(context).unfocus(),
          obscureText: _obscureText,
          controller: widget.controller,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          style: AppTextStyle.body,
          cursorColor: AppColors.brandPrimary,
          decoration: InputDecoration(
            suffixIcon: widget.obscureText
                ? GestureDetector(
                    onTap: _toggleObscureText,
                    child: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                  )
                : widget.suffix,
            hintText: widget.placeholder,
            hintStyle: AppTextStyle.body.copyWith(
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: widget.enabled
                ? AppColors.surfaceCard
                : AppColors.surfaceSunken,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space3,
            ),
            border: enabledBorder,
            enabledBorder: enabledBorder,
            focusedBorder: _outline(
              hasError ? AppColors.danger : AppColors.borderBrand,
              width: 2,
            ),
            disabledBorder: _outline(AppColors.borderSubtle),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.space1),
          Text(
            widget.errorText!,
            style: AppTextStyle.caption.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}
