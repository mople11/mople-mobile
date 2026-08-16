import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/home_controller.dart';
import 'package:mople_mobile/presentation/pages/destination/course_page.dart';

class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  /// 서버가 시간대별 예보를 내려주지 않아 라벨/아이콘만 고정해 두고
  /// 기온은 현재 기온을 기준으로 보여준다.
  static const _hourLabels = [
    ('지금', Icons.wb_sunny_rounded),
    ('15시', Icons.wb_sunny_rounded),
    ('18시', Icons.wb_cloudy_rounded),
    ('21시', Icons.nightlight_round),
    ('내일', Icons.water_drop_rounded),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeProvider.notifier).refreshAll());
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeProvider);

    return AppDetailScaffold(
      title: '날씨 추천',
      onBack: () => context.pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AsyncView<CurrentWeather>(
            value: home.weather,
            loadingHeight: 132,
            onRetry: () => ref.read(homeProvider.notifier).loadWeather(),
            builder: (weather) => WeatherCard(
              region: '전남',
              condition: weatherConditionFromKorean(weather.weatherType),
              temp: weather.temp,
              high: weather.temp,
              low: weather.temp,
              hint: '오늘은 ${weather.weatherType} 날씨예요',
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _hourLabels.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppSpacing.space2),
              itemBuilder: (context, i) {
                final (label, icon) = _hourLabels[i];
                final temp = home.currentWeather?.temp ?? 0;
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
                '오늘 날씨에 맞는 코스',
                style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          AsyncView<HomeData>(
            value: home.home,
            onRetry: () => ref.read(homeProvider.notifier).loadHome(),
            isEmpty: (data) => data.recommendedCourses.isEmpty,
            emptyMessage: '추천할 코스가 아직 없어요.',
            builder: (data) => Column(
              children: [
                for (final course in data.recommendedCourses) ...[
                  CourseCard(
                    title: course.name,
                    summary: '${course.duration} · ${course.distance}',
                    stops: 0,
                    duration: course.duration,
                    image: course.thumbnail,
                    onTap: () =>
                        context.push(CoursePage(courseId: course.courseId)),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
