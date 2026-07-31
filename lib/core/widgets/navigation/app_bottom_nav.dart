import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/spacing.dart';

class AppBottomNavItem {
  const AppBottomNavItem({
    required this.value,
    required this.label,
    required this.icon,
  });

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
    // SafeArea(top:false)로 홈 인디케이터 여백을 자동 반영 — 콘텐츠가 제스처 영역에 눌리지 않도록 함.
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              for (final item in items)
                Expanded(
                  child: InkWell(
                    onTap: onChanged == null
                        ? null
                        : () => onChanged!(item.value),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: item.value == value
                              ? AppColors.brandPrimary
                              : AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.space1),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.small.copyWith(
                            color: item.value == value
                                ? AppColors.brandPrimary
                                : AppColors.textTertiary,
                            fontWeight: item.value == value
                                ? AppFont.bold
                                : AppFont.medium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
