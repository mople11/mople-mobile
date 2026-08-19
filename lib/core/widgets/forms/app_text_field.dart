import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.keyboardType,
    this.inputFormatters,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  /// 아이디처럼 영문·숫자만 받아야 하는 칸에 쓴다.
  ///
  /// 한글 입력기가 켜져 있으면 `choi` 가 `쵀ㅑ` 로 조합되어 들어오므로,
  /// 자모를 걸러내는 [inputFormatters] 와 IME 를 띄우지 않는 키보드 타입을 함께 건다.
  factory AppTextField.asciiOnly({
    Key? key,
    String? label,
    String? placeholder,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    bool enabled = true,
    String? errorText,
    Widget? suffixIcon,
    String pattern = r'[a-zA-Z0-9_-]',
  }) => AppTextField(
    key: key,
    label: label,
    placeholder: placeholder,
    controller: controller,
    onChanged: onChanged,
    enabled: enabled,
    errorText: errorText,
    suffixIcon: suffixIcon,
    // visiblePassword 는 iOS/Android 모두에서 IME(한글 조합)를 띄우지 않는다.
    keyboardType: TextInputType.visiblePassword,
    autocorrect: false,
    enableSuggestions: false,
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(pattern))],
  );

  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final String? errorText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool autocorrect;
  final bool enableSuggestions;

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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
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
