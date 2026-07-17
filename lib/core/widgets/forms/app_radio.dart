import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

class AppRadio<T> extends StatelessWidget {
  final String label;
  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;

  const AppRadio({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(value),
      borderRadius: AppRadius.radiusPill,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<T>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged == null ? null : (v) => onChanged!(v as T),
            activeColor: AppColors.brandPrimary,
          ),
          const SizedBox(width: AppSpacing.space1),
          Text(label, style: AppTextStyle.body),
        ],
      ),
    );
  }
}
