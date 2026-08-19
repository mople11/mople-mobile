import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';
import 'package:mople_mobile/presentation/controllers/course_controller.dart';
import 'package:mople_mobile/presentation/controllers/favorites_controller.dart';
import 'package:mople_mobile/presentation/pages/destination/view/map_page.dart';

/// 코스 상세.
///
/// 명세에 단일 코스 조회 엔드포인트(`GET /courses/{id}`)가 없어서 화면 구성 자체는
/// 아직 목업을 쓰고, 하단 액션(저장/시작)만 실제 API([courseProvider])로 연결한다.
class CoursePage extends ConsumerStatefulWidget {
  const CoursePage({super.key, this.courseId});

  final String? courseId;

  @override
  ConsumerState<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends ConsumerState<CoursePage> {
  @override
  void initState() {
    super.initState();
    final id = widget.courseId;
    if (id != null) {
      Future.microtask(() => ref.read(courseProvider.notifier).setCourseId(id));
    }
  }

  @override
  void dispose() {
    // courseProvider 는 전역이라 화면을 떠나도 courseId 가 남는다. 그대로 두면
    // 다른 화면(RoutePage 등)이 이 값을 자기 코스로 착각해 엉뚱한 코스를 저장한다.
    if (widget.courseId != null) {
      final notifier = ref.read(courseProvider.notifier);
      Future.microtask(() => notifier.setCourseId(null));
    }
    super.dispose();
  }

  Future<void> _save(String courseId) async {
    await ref.read(courseProvider.notifier).save(courseId);
    if (!mounted) return;
    final action = ref.read(courseProvider).saveAction;
    if (action?.hasError ?? false) {
      AppToast.show(
        context,
        title: '저장 실패',
        message: action!.apiError?.displayMessage ?? '코스를 저장하지 못했어요.',
        tone: AppToastTone.danger,
      );
    }
  }

  Future<void> _start(String? courseId) async {
    if (courseId == null) {
      context.push(const MapPage());
      return;
    }
    await ref.read(courseProvider.notifier).start(courseId);
    if (!mounted) return;
    final started = ref.read(courseProvider).started;
    if (started?.hasError ?? false) {
      AppToast.show(
        context,
        title: '시작 실패',
        message: started!.apiError?.displayMessage ?? '코스를 시작하지 못했어요.',
        tone: AppToastTone.danger,
      );
      return;
    }
    if (mounted) context.push(const MapPage());
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final toggleFavorite = ref.read(favoritesProvider.notifier).toggle;
    final route = EodiganamData.route;
    final d = EodiganamData.destinations.first;

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AppNetworkImage(url: d.image),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      AppColors.neutral900.withValues(
                                        alpha: 0.8,
                                      ),
                                      AppColors.neutral900.withValues(
                                        alpha: 0.05,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: AppSpacing.space2,
                          left: AppSpacing.space2,
                          child: SafeArea(
                            bottom: false,
                            child: AppIconButton(
                              icon: const Icon(Icons.chevron_left_rounded),
                              semanticLabel: '뒤로',
                              variant: AppIconButtonVariant.solid,
                              onPressed: () => context.pop(),
                            ),
                          ),
                        ),
                        Positioned(
                          left: AppSpacing.space5,
                          right: AppSpacing.space5,
                          bottom: AppSpacing.space4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const WeatherChip(
                                    condition: WeatherCondition.sunny,
                                    temp: 24,
                                  ),
                                  const SizedBox(width: AppSpacing.space2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.space2,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.neutral0.withValues(
                                        alpha: 0.22,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${route.steps.length}곳 · 6시간',
                                      style: AppTextStyle.small.copyWith(
                                        color: AppColors.neutral0,
                                        fontWeight: AppFont.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.space2),
                              Text(
                                route.title,
                                style: AppTextStyle.h2.copyWith(
                                  color: AppColors.neutral0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.space3,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceCard,
                        border: Border(
                          bottom: BorderSide(color: AppColors.borderSubtle),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatColumn(
                            icon: Icons.navigation_rounded,
                            label: '거리',
                            value: route.distance,
                          ),
                          _StatColumn(
                            icon: Icons.account_balance_wallet_rounded,
                            label: '예상비용',
                            value: route.cost,
                          ),
                          _StatColumn(
                            icon: Icons.explore_rounded,
                            label: '코스',
                            value: '${route.steps.length}곳',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.space5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => context.push(const MapPage()),
                            child: const MapPreviewCard(
                              height: 160,
                              pins: 4,
                              label: '전체 동선 지도',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space5),
                          Text(
                            '추천 동선',
                            style: AppTextStyle.bodyLg.copyWith(
                              fontWeight: AppFont.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          RouteStepList(steps: route.steps),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppBottomActionBar(
              child: Builder(
                builder: (context) {
                  final courseState = ref.watch(courseProvider);
                  final hasCourse = widget.courseId != null;
                  // 서버 코스면 서버 저장 상태를, 목업이면 기존 로컬 즐겨찾기를 따른다.
                  final saved = hasCourse
                      ? courseState.saved
                      : favorites.isFav(FavoritesNotifier.routeKey);
                  return Row(
                    children: [
                      AppButton(
                        label: saved ? '저장됨' : '저장',
                        variant: saved
                            ? AppButtonVariant.secondary
                            : AppButtonVariant.outline,
                        leading: Icon(
                          saved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 16,
                          color: saved
                              ? AppColors.textOnBrand
                              : AppColors.textBrand,
                        ),
                        onPressed: () => hasCourse
                            ? _save(widget.courseId!)
                            : toggleFavorite(FavoritesNotifier.routeKey),
                      ),
                      const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: AppButton(
                          label: '내비게이션 시작',
                          width: double.infinity,
                          onPressed: () => _start(widget.courseId),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyle.small.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyle.caption.copyWith(fontWeight: AppFont.bold),
        ),
      ],
    );
  }
}
