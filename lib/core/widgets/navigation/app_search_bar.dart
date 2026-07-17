import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

class AppSearchBar extends StatelessWidget {
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AppSearchBar({
    super.key,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: AppTextStyle.body,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: AppTextStyle.body.copyWith(color: AppColors.textTertiary),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.surfaceSunken,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
        border: const OutlineInputBorder(borderRadius: AppRadius.radiusPill, borderSide: BorderSide.none),
        enabledBorder: const OutlineInputBorder(borderRadius: AppRadius.radiusPill, borderSide: BorderSide.none),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.radiusPill,
          borderSide: BorderSide(color: AppColors.borderBrand, width: 2),
        ),
      ),
    );
  }
}
