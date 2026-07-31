import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/shadow.dart';
import '../../constants/spacing.dart';
import 'weather_chip.dart';

/// 홈/날씨 추천 화면에 쓰이는 대형 날씨 카드 (그라디언트 배경).
class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
    required this.region,
    required this.condition,
    required this.temp,
    required this.high,
    required this.low,
    this.hint,
  });

  final String region;
  final WeatherCondition condition;
  final int temp;
  final int high;
  final int low;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space5,
        vertical: AppSpacing.space5,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.radiusXl,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue500, AppColors.blue400],
        ),
        boxShadow: AppShadow.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: AppColors.neutral0,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        region,
                        style: AppTextStyle.caption.copyWith(
                          color: AppColors.neutral0,
                          fontWeight: AppFont.semibold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$temp°',
                    style: AppTextStyle.display.copyWith(
                      color: AppColors.neutral0,
                      fontSize: 42,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    '${condition.label} · 최고 $high° / 최저 $low°',
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.neutral0.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
              Icon(condition.icon, size: 52, color: AppColors.neutral0),
            ],
          ),
          if (hint != null) ...[
            const SizedBox(height: AppSpacing.space3),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space3,
                vertical: AppSpacing.space2,
              ),
              decoration: BoxDecoration(
                color: AppColors.neutral0.withValues(alpha: 0.18),
                borderRadius: AppRadius.radiusMd,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_rounded,
                    size: 15,
                    color: AppColors.neutral0,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      hint!,
                      style: AppTextStyle.caption.copyWith(
                        color: AppColors.neutral0,
                        fontWeight: AppFont.semibold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
