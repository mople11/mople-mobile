import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

class AppSelect extends StatelessWidget {
  const AppSelect({
    super.key,
    this.label,
    this.placeholder,
    required this.options,
    this.value,
    this.onChanged,
  });

  final String? label;
  final String? placeholder;
  final List<String> options;
  final String? value;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyle.label),
          const SizedBox(height: AppSpacing.space2),
        ],
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textTertiary,
          ),
          style: AppTextStyle.body,
          dropdownColor: AppColors.surfaceCard,
          borderRadius: AppRadius.radiusMd,
          hint: placeholder != null
              ? Text(
                  placeholder!,
                  style: AppTextStyle.body.copyWith(
                    color: AppColors.textTertiary,
                  ),
                )
              : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceCard,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space3,
            ),
            border: const OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: AppColors.borderDefault),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: AppColors.borderDefault),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: AppColors.borderBrand, width: 2),
            ),
          ),
          items: options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
