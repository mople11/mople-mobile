import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.onRemove,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final background = selected ? AppColors.fillBrandSoft : AppColors.surfaceSunken;
    final border = selected ? AppColors.borderBrand : AppColors.borderSubtle;
    final foreground = selected ? AppColors.textBrand : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusPill,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space3, vertical: AppSpacing.space1),
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppRadius.radiusPill,
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTextStyle.caption.copyWith(color: foreground, fontWeight: AppFont.semibold)),
              if (onRemove != null) ...[
                const SizedBox(width: AppSpacing.space1),
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(Icons.close_rounded, size: 14, color: foreground),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
