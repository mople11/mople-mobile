import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      borderRadius: AppRadius.radiusPill,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyle.body),
          const SizedBox(width: AppSpacing.space2),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.brandPrimary,
            activeThumbColor: AppColors.neutral0,
            inactiveTrackColor: AppColors.neutral300,
            inactiveThumbColor: AppColors.neutral0,
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
