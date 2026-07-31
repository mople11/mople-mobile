import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.errorText,
    this.obscureText = false,
    this.suffixIcon,
  });

  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final String? errorText;
  final bool obscureText;
  final Widget? suffixIcon;

  static OutlineInputBorder _outline(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: AppRadius.radiusMd,
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final enabledBorder = _outline(
      hasError ? AppColors.danger : AppColors.borderDefault,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyle.label),
          const SizedBox(height: AppSpacing.space2),
        ],
        TextField(
          controller: controller,
          onChanged: onChanged,
          enabled: enabled,
          obscureText: obscureText,
          style: AppTextStyle.body,
          cursorColor: AppColors.brandPrimary,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTextStyle.body.copyWith(
              color: AppColors.textTertiary,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled
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
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.space1),
          Text(
            errorText!,
            style: AppTextStyle.caption.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}
