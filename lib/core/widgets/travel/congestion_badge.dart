import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

/// 관광지 혼잡도 뱃지 — 여유 · 보통 · 혼잡.
class CongestionBadge extends StatelessWidget {
  const CongestionBadge({super.key, required this.level, this.small = false});

  final String level;
  final bool small;

  ({Color bg, Color fg}) get _colors => switch (level) {
    '여유' => (bg: AppColors.successBg, fg: AppColors.successText),
    '혼잡' => (bg: AppColors.dangerBg, fg: AppColors.dangerText),
    _ => (bg: AppColors.warningBg, fg: AppColors.warningText),
  };

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? AppSpacing.space2 : 13,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: AppRadius.radiusPill,
      ),
      child: Text(
        level,
        style: (small ? AppTextStyle.small : AppTextStyle.caption).copyWith(
          color: colors.fg,
          fontWeight: AppFont.bold,
        ),
      ),
    );
  }
}
