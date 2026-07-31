import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    this.active = false,
    this.hasDropdown = false,
    this.count,
    this.icon,
    this.onTap,
  });

  final String label;
  final bool active;
  final bool hasDropdown;
  final int? count;
  final String? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = active ? AppColors.brandPrimary : AppColors.surfaceCard;
    final border = active ? AppColors.brandPrimary : AppColors.borderDefault;
    final foreground = active ? AppColors.textOnBrand : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusPill,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space2,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppRadius.radiusPill,
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Text(icon!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTextStyle.label.copyWith(
                  color: foreground,
                  fontWeight: AppFont.semibold,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: AppTextStyle.caption.copyWith(
                    color: foreground,
                    fontWeight: AppFont.bold,
                  ),
                ),
              ],
              if (hasDropdown) ...[
                const SizedBox(width: 2),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: foreground,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
