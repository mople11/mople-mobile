import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

class AppTooltip extends StatelessWidget {
  final String label;
  final Widget child;

  const AppTooltip({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      textStyle: AppTextStyle.caption.copyWith(color: AppColors.textOnBrand),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space3, vertical: AppSpacing.space2),
      decoration: BoxDecoration(color: AppColors.surfaceInverse, borderRadius: AppRadius.radiusMd),
      waitDuration: const Duration(milliseconds: 400),
      child: child,
    );
  }
}
