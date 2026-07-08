import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/spacing.dart';

class AppBottomNavItem {
  const AppBottomNavItem({required this.value, required this.label, required this.icon});

  final String value;
  final String label;
  final IconData icon;
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.value,
    this.onChanged,
  });

  final List<AppBottomNavItem> items;
  final String value;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: InkWell(
                onTap: onChanged == null ? null : () => onChanged!(item.value),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 22,
                      color: item.value == value ? AppColors.brandPrimary : AppColors.textTertiary,
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      item.label,
                      style: AppTextStyle.small.copyWith(
                        color: item.value == value ? AppColors.brandPrimary : AppColors.textTertiary,
                        fontWeight: item.value == value ? AppFont.bold : AppFont.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
