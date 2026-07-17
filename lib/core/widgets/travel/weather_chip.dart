import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

enum WeatherCondition { sunny, rain, cloud, wind }

class WeatherChip extends StatelessWidget {
  final WeatherCondition condition;
  final int temp;

  const WeatherChip({super.key, required this.condition, required this.temp});

  IconData get _icon => switch (condition) {
        WeatherCondition.sunny => Icons.wb_sunny_rounded,
        WeatherCondition.rain => Icons.water_drop_rounded,
        WeatherCondition.cloud => Icons.cloud_rounded,
        WeatherCondition.wind => Icons.air_rounded,
      };

  String get _label => switch (condition) {
        WeatherCondition.sunny => '맑음',
        WeatherCondition.rain => '비',
        WeatherCondition.cloud => '구름',
        WeatherCondition.wind => '바람',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space3, vertical: AppSpacing.space1),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: AppRadius.radiusPill,
        border: Border.all(color: AppColors.blue100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: AppColors.blue600),
          const SizedBox(width: 4),
          Text(
            '$_label $temp°',
            style: AppTextStyle.caption.copyWith(color: AppColors.blue700, fontWeight: AppFont.semibold),
          ),
        ],
      ),
    );
  }
}
