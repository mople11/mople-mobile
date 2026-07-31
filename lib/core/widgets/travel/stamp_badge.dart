import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/spacing.dart';

/// 지역별 여행 도장 — 획득 여부에 따라 이모지 또는 잠금 아이콘을 보여줍니다.
class StampBadge extends StatelessWidget {
  const StampBadge({
    super.key,
    required this.region,
    required this.earned,
    required this.emoji,
  });

  final String region;
  final bool earned;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 68,
          height: 68,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: earned ? AppColors.fillBrandSoft : AppColors.surfaceSunken,
            border: Border.all(
              color: earned ? AppColors.brandPrimary : AppColors.borderDefault,
              width: 2.5,
              style: earned ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          child: earned
              ? Text(emoji, style: const TextStyle(fontSize: 28))
              : const Icon(
                  Icons.lock_rounded,
                  size: 22,
                  color: AppColors.textTertiary,
                ),
        ),
        const SizedBox(height: AppSpacing.space1),
        Text(
          region,
          style: AppTextStyle.small.copyWith(
            fontWeight: earned ? AppFont.bold : AppFont.medium,
            color: earned ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
