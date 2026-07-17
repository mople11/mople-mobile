import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

enum AppTabsVariant { underline, pill }

class AppTabs extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final AppTabsVariant variant;

  const AppTabs({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onChanged,
    this.variant = AppTabsVariant.underline,
  });

  @override
  Widget build(BuildContext context) {
    return variant == AppTabsVariant.pill ? _buildPill() : _buildUnderline();
  }

  Widget _buildUnderline() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space6),
            child: InkWell(
              onTap: onChanged == null ? null : () => onChanged!(i),
              child: Container(
                padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: i == selectedIndex ? AppColors.brandPrimary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  items[i],
                  style: AppTextStyle.label.copyWith(
                    color: i == selectedIndex ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: i == selectedIndex ? AppFont.bold : AppFont.medium,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPill() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space2),
            child: Material(
              color: i == selectedIndex ? AppColors.brandPrimary : AppColors.surfaceSunken,
              borderRadius: AppRadius.radiusPill,
              child: InkWell(
                onTap: onChanged == null ? null : () => onChanged!(i),
                borderRadius: AppRadius.radiusPill,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
                  child: Text(
                    items[i],
                    style: AppTextStyle.label.copyWith(
                      color: i == selectedIndex ? AppColors.textOnBrand : AppColors.textSecondary,
                      fontWeight: AppFont.semibold,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
