import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

enum WeatherCondition { sunny, rain, cloud, wind }

/// 조건별 아이콘/라벨 — WeatherChip과 WeatherCard가 함께 사용하는 단일 소스.
extension WeatherConditionX on WeatherCondition {
  IconData get icon => switch (this) {
    WeatherCondition.sunny => Icons.wb_sunny_rounded,
    WeatherCondition.rain => Icons.water_drop_rounded,
    WeatherCondition.cloud => Icons.cloud_rounded,
    WeatherCondition.wind => Icons.air_rounded,
  };

  String get label => switch (this) {
    WeatherCondition.sunny => '맑음',
    WeatherCondition.rain => '비',
    WeatherCondition.cloud => '구름',
    WeatherCondition.wind => '바람',
  };
}

class WeatherChip extends StatelessWidget {
  const WeatherChip({super.key, required this.condition, required this.temp});

  final WeatherCondition condition;
  final int temp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: AppRadius.radiusPill,
        border: Border.all(color: AppColors.blue100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(condition.icon, size: 14, color: AppColors.blue600),
          const SizedBox(width: 4),
          Text(
            '${condition.label} $temp°',
            style: AppTextStyle.caption.copyWith(
              color: AppColors.blue700,
              fontWeight: AppFont.semibold,
            ),
          ),
        ],
      ),
    );
  }
}
