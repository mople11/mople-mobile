import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/shadow.dart';
import '../../constants/spacing.dart';

/// 상단 내비게이션 바 — 뒤로가기 + 제목 + 트레일링 액션.
/// `transparent` 인 경우 이미지 위에 얹는 용도로 배경 없이 원형 버튼만 그립니다.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    this.title,
    this.onBack,
    this.trailing,
    this.transparent = false,
    this.dark = false,
  });

  final String? title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool transparent;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final titleColor = dark ? AppColors.neutral0 : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space2,
        AppSpacing.space1,
        AppSpacing.space4,
        AppSpacing.space3,
      ),
      decoration: transparent
          ? null
          : const BoxDecoration(
              color: AppColors.surfaceCard,
              border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
            ),
      child: Row(
        children: [
          if (onBack != null)
            _NavCircleButton(
              onTap: onBack!,
              transparent: transparent,
              child: const Icon(Icons.chevron_left_rounded, size: 24),
            )
          else
            const SizedBox(width: AppSpacing.space10),
          Expanded(
            child: Text(
              title ?? '',
              textAlign: onBack != null ? TextAlign.center : TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.title.copyWith(color: titleColor),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: onBack != null ? AppSpacing.space10 : 0,
            ),
            child: trailing ?? const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _NavCircleButton extends StatelessWidget {
  const _NavCircleButton({
    required this.onTap,
    required this.transparent,
    required this.child,
  });

  final VoidCallback onTap;
  final bool transparent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: transparent
          ? AppColors.neutral0.withValues(alpha: 0.92)
          : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: AppSpacing.space10,
          height: AppSpacing.space10,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: transparent ? AppShadow.sm : null,
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: AppColors.neutral900),
            child: child,
          ),
        ),
      ),
    );
  }
}
