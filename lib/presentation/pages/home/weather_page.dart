import 'package:flutter/material.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/destination/detail_page.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  static const _hours = [
    ('지금', Icons.wb_sunny_rounded, 24),
    ('15시', Icons.wb_sunny_rounded, 26),
    ('18시', Icons.wb_cloudy_rounded, 23),
    ('21시', Icons.nightlight_round, 19),
    ('내일', Icons.water_drop_rounded, 18),
  ];

  @override
  Widget build(BuildContext context) {
    final sunny = EodiganamData.destinations
        .where((d) => d.weatherLabel == '맑음')
        .take(3)
        .toList();

    return AppDetailScaffold(
      title: '날씨 추천',
      onBack: () => context.pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WeatherCard(
            region: '순천시',
            condition: WeatherCondition.sunny,
            temp: 24,
            high: 26,
            low: 17,
            hint: '오늘은 야외 코스를 추천해요',
          ),
          const SizedBox(height: AppSpacing.space4),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _hours.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppSpacing.space2),
              itemBuilder: (context, i) {
                final (label, icon, temp) = _hours[i];
                return Container(
                  width: 62,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.space3,
                    horizontal: AppSpacing.space2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    border: Border.all(color: AppColors.borderSubtle),
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Column(
                    children: [
                      Text(
                        label,
                        style: AppTextStyle.small.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: AppFont.semibold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(icon, size: 22, color: AppColors.brandPrimary),
                      const SizedBox(height: 6),
                      Text(
                        '$temp°',
                        style: AppTextStyle.caption.copyWith(
                          fontWeight: AppFont.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space3,
              vertical: AppSpacing.space3,
            ),
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              borderRadius: AppRadius.radiusMd,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_rounded,
                  size: 18,
                  color: AppColors.infoText,
                ),
                const SizedBox(width: AppSpacing.space2),
                Expanded(
                  child: Text(
                    '내일 오후 비 예보 — 실내 코스도 미리 담아두세요.',
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.infoText,
                      fontWeight: AppFont.semibold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          Row(
            children: [
              const Icon(
                Icons.wb_sunny_rounded,
                size: 18,
                color: AppColors.brandAccent,
              ),
              const SizedBox(width: 6),
              Text(
                '맑은 날 추천',
                style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          for (final d in sunny) ...[
            DestinationCard(
              image: d.image,
              title: d.title,
              region: d.region,
              rating: d.rating,
              reviewCount: d.reviewCount,
              duration: d.duration,
              badge: d.badge,
              weather: (
                condition: weatherConditionFromKorean(d.weatherLabel),
                temp: d.weatherTemp,
              ),
              onTap: () => context.push(DetailPage(destinationId: d.id)),
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
        ],
      ),
    );
  }
}
