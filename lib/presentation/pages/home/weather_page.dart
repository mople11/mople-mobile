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
              region: '현재위치',
              condition: weatherConditionFromKorean(weather.weatherType),
              temp: weather.temp,
              high: weather.temp,
              low: weather.temp,
              hint: '오늘은 ${weather.weatherType} 날씨예요',
            ),
          ),
          const SizedBox(height: AppSpacing.space10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
