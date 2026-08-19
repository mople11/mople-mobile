import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/auth_controller.dart';
import 'package:mople_mobile/presentation/controllers/home_controller.dart';
import 'package:mople_mobile/presentation/controllers/main_tab_controller.dart';
import 'package:mople_mobile/presentation/pages/destination/ai_trip_page.dart';
import 'package:mople_mobile/presentation/pages/destination/course_page.dart';
import 'package:mople_mobile/presentation/pages/home/home_discover_page.dart';
import 'package:mople_mobile/presentation/pages/home/weather_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _mood = 'heal';

  @override
  void initState() {
    super.initState();
    // build 중 provider 를 건드리지 않도록 프레임 이후로 미룬다.
    Future.microtask(() => ref.read(homeProvider.notifier).refreshAll());
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeProvider);
    final nickname = ref.watch(authProvider).currentUser?.nickname;

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space5,
          AppSpacing.space2,
          AppSpacing.space5,
          AppSpacing.space6,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wb_sunny_rounded,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _todayLabel(),
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      nickname == null
                          ? '안녕하세요'
                          : '안녕하세요, $nickname님',
                      style: AppTextStyle.h3,
                    ),
                  ],
                ),
                AppIconButton(
                  icon: const Icon(Icons.cloud_rounded),
                  semanticLabel: '날씨',
                  onPressed: () => context.push(const WeatherPage()),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space3),
            GestureDetector(
              onTap: () =>
                  ref.read(mainTabProvider.notifier).switchTab('search'),
              child: const AbsorbPointer(
                child: AppSearchBar(placeholder: '전남 지역을 검색해보세요!'),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            AsyncView<CurrentWeather>(
              value: home.weather,
              loadingHeight: 132,
              onRetry: () => ref.read(homeProvider.notifier).loadWeather(),
              builder: (weather) => WeatherCard(
                region: '현재 날씨',
                condition: weatherConditionFromKorean(weather.weatherType),
                temp: weather.temp,
                // 서버가 최고/최저를 내려주지 않아 현재 기온을 그대로 쓴다.
                high: weather.temp,
                low: weather.temp,
              ),
            ),
            const SizedBox(height: AppSpacing.space5),
            Text(
              '오늘 기분은 어떠세요?',
              style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
            ),
            const SizedBox(height: AppSpacing.space3),
            MoodSelector(
              columns: 3,
              value: _mood,
              options: EodiganamData.moods.take(6).toList(),
              onChanged: (v) => setState(() => _mood = v),
            ),
            const SizedBox(height: AppSpacing.space4),
            AppButton(
              label: 'AI 맞춤 코스 만들기',
              width: double.infinity,
              size: AppButtonSize.lg,
              leading: const Icon(
                Icons.route_rounded,
                size: 18,
                color: AppColors.neutral0,
              ),
              onPressed: () => context.push(AiTripPage(initialMood: _mood)),
            ),
            const SizedBox(height: AppSpacing.space5),
            Text(
              '추천 코스',
              style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
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
                      // 서버 요약에 경유지 수가 없어 0으로 둔다.
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
            const SizedBox(height: AppSpacing.space2),
            Material(
              color: AppColors.fillBrandSoft,
              borderRadius: AppRadius.radiusLg,
              child: InkWell(
                borderRadius: AppRadius.radiusLg,
                onTap: () => context.push(const HomeDiscoverPage()),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '지금 인기 있는 곳 · AI 추천 코스',
                              style: AppTextStyle.body.copyWith(
                                color: AppColors.textBrand,
                                fontWeight: AppFont.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '더 둘러보기',
                              style: AppTextStyle.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textBrand,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 홈 상단에 표시할 오늘 날짜. 예: `오늘 · 8월 18일`
String _todayLabel() {
  final now = DateTime.now();
  return '오늘 · ${now.month}월 ${now.day}일';
}
