import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';
import 'package:mople_mobile/presentation/controllers/course_controller.dart';
import 'package:mople_mobile/presentation/controllers/favorites_controller.dart';
import 'package:mople_mobile/presentation/pages/destination/view/map_page.dart';

/// 목록 화면이 이미 알고 있는 코스 정보. 상세 조회 API 대신 쓴다.
///
/// 명세에 단일 코스 조회 엔드포인트(`GET /courses/{id}`)가 없다. 그렇다고 목업을
/// 그대로 보여주면 어떤 코스를 눌러도 같은 화면이 뜨므로, 목록에서 받은 서버
/// 값을 그대로 넘겨 최소한 코스의 정체(이름·사진·소요시간·거리)는 맞춘다.
class CoursePreview {
  const CoursePreview({
    required this.name,
    this.thumbnail = '',
    this.duration = '',
    this.distance = '',
    this.placeCount,
  });

  factory CoursePreview.fromSummary(CourseSummary course) => CoursePreview(
    name: course.name,
    thumbnail: course.thumbnail,
    duration: course.duration,
    distance: course.distance,
  );

  final String name;
  final String thumbnail;
  final String duration;
  final String distance;

  /// 경유지 수. 아는 경우에만 통계에 노출한다.
  final int? placeCount;
}

/// 코스 상세.
///
/// 상세 조회 엔드포인트가 없어 [preview] 로 받은 값을 화면에 쓰고, 서버가 주지
/// 않는 항목(예상비용·추천 동선)은 **지어내지 않고 감춘다.** [courseId] 가 없는
/// 목업 진입(지도 화면 등)에서는 기존 목업 구성을 그대로 보여준다.
class CoursePage extends ConsumerStatefulWidget {
  const CoursePage({super.key, this.courseId, this.preview});

  final String? courseId;

  /// 목록에서 넘겨준 서버 코스 정보. [courseId] 가 있으면 함께 주는 게 원칙이다.
  final CoursePreview? preview;

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
    final preview = widget.preview;
    // 서버 코스인데 넘겨받은 정보가 없으면, 목업을 그 코스인 척 보여주지 않는다.
    final isServerCourse = widget.courseId != null;
    final title = preview?.name ?? (isServerCourse ? '코스' : route.title);
    final imageUrl = isServerCourse ? (preview?.thumbnail ?? '') : d.image;
    final distance = preview?.distance.isNotEmpty == true
        ? preview!.distance
        : (isServerCourse ? null : route.distance);
    final placeCount = preview?.placeCount ??
        (isServerCourse ? null : route.steps.length);
    final duration = preview?.duration.isNotEmpty == true
        ? preview!.duration
        : (isServerCourse ? null : '6시간');

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
                              AppNetworkImage(url: imageUrl),
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
                                  if (placeCount != null || duration != null)
                                    const SizedBox(width: AppSpacing.space2),
                                  if (placeCount != null || duration != null)
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
                                      [
                                        if (placeCount != null) '$placeCount곳',
                                        if (duration != null) duration,
                                      ].join(' · '),
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
                                title,
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
                          if (distance != null)
                            _StatColumn(
                              icon: Icons.navigation_rounded,
                              label: '거리',
                              value: distance,
                            ),
                          // 예상비용은 서버가 주지 않는다. 목업 진입에서만 쓴다.
                          if (!isServerCourse)
                            _StatColumn(
                              icon: Icons.account_balance_wallet_rounded,
                              label: '예상비용',
                              value: route.cost,
                            ),
                          if (placeCount != null)
                            _StatColumn(
                              icon: Icons.explore_rounded,
                              label: '코스',
                              value: '$placeCount곳',
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.space5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isServerCourse) ...[
                            GestureDetector(
                              onTap: () => context.push(const MapPage()),
                              child: MapPreviewCard(
                                height: 160,
                                pins: route.steps.length,
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
                          ] else
                            // 상세 동선 조회 엔드포인트가 아직 없다. 목업 동선을
                            // 이 코스의 것인 양 보여주면 틀린 정보를 주는 셈이다.
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.space6,
                                horizontal: AppSpacing.space5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.borderSubtle,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.route_rounded,
                                    color: AppColors.textTertiary,
                                  ),
                                  const SizedBox(height: AppSpacing.space2),
                                  Text(
                                    '이 코스의 동선 정보는 아직 제공되지 않습니다.',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyle.caption.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
