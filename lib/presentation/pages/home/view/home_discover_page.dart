import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/home_controller.dart';
import 'package:mople_mobile/presentation/controllers/main_tab_controller.dart';
import 'package:mople_mobile/presentation/pages/destination/view/ai_trip_page.dart';
import 'package:mople_mobile/presentation/pages/destination/view/course_page.dart';
import 'package:mople_mobile/presentation/pages/plan/view/plan_page.dart';

/// 코스 둘러보기 — 홈 응답(`GET /home`)의 추천 코스를 그대로 보여준다.
class HomeDiscoverPage extends ConsumerStatefulWidget {
  const HomeDiscoverPage({super.key});

  @override
  ConsumerState<HomeDiscoverPage> createState() => _HomeDiscoverPageState();
}

class _HomeDiscoverPageState extends ConsumerState<HomeDiscoverPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeProvider.notifier).loadHome());
  }

  void _seeAll() {
    ref.read(mainTabProvider.notifier).switchTab('search');
    context.popToFirst();
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeProvider);

    return AppDetailScaffold(
      title: '코스 둘러보기',
      onBack: () => context.pop(),
      bodyPadding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space5),
            child: SectionHead(
              title: '지금 인기 있는 코스',
              action: '전체보기',
              onAction: _seeAll,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space5),
            child: AsyncView<HomeData>(
              value: home.home,
              loadingHeight: 258,
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
                          context.push(CoursePage(
                            courseId: course.courseId,
                            preview: CoursePreview.fromSummary(course),
                          )),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHead(
                  title: 'AI 추천 코스',
                  action: '더보기',
                  onAction: () => context.push(const AiTripPage()),
                ),
                AppButton(
                  label: '직접 코스 만들기',
                  variant: AppButtonVariant.outline,
                  width: double.infinity,
                  leading: const Icon(Icons.tune_rounded, size: 18),
                  onPressed: () => context.push(const PlanPage()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
