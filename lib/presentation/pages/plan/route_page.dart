import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';
import 'package:mople_mobile/presentation/controllers/course_controller.dart';

/// 동선 최적화 결과 — `POST /courses/optimize`.
///
/// [placeIds] 로 받은 장소들을 이동수단과 함께 서버에 보내 순서·구간 시간을 받는다.
class RoutePage extends ConsumerStatefulWidget {
  const RoutePage({
    super.key,
    this.companionLabel,
    this.transportLabel,
    this.hours,
    this.placeIds = const <String>[],
  });

  final String? companionLabel;
  final String? transportLabel;
  final double? hours;
  final List<String> placeIds;

  @override
  ConsumerState<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends ConsumerState<RoutePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_optimize);
  }

  /// 화면에 넘어온 장소들로 선택 목록을 **교체**한 뒤 최적화를 요청한다.
  ///
  /// 추가만 하면 이전에 열었던 동선의 장소가 그대로 남아 함께 계산된다.
  Future<void> _optimize() async {
    final notifier = ref.read(courseProvider.notifier);
    notifier.setSelectedPlaces(widget.placeIds);
    notifier.setRouteTransport(_transport);
    await notifier.optimize();
  }

  RouteTransport get _transport => switch (widget.transportLabel) {
    '도보' => RouteTransport.walk,
    '대중교통' => RouteTransport.transit,
    _ => RouteTransport.car,
  };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courseProvider);

    return AppDetailScaffold(
      title: '추천 동선',
      onBack: () => context.pop(),
      body: AsyncView<CourseOptimizeResult>(
        value: state.optimized,
        loadingHeight: 320,
        onRetry: _optimize,
        builder: (result) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.space5),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                border: Border.all(color: AppColors.borderSubtle),
                borderRadius: AppRadius.radiusLg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(
                    icon: Icons.access_time_rounded,
                    label: '총 소요',
                    value: '${result.totalTime}분',
                  ),
                  _Stat(
                    icon: Icons.explore_rounded,
                    label: '장소',
                    value: '${result.orderedPlaces.length}곳',
                  ),
                  _Stat(
                    icon: Icons.directions_rounded,
                    label: '이동수단',
                    value: _transport.value,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space5),
            const MapPreviewCard(
              height: 160,
              pins: 4,
              label: '전체 동선 지도',
            ),
            const SizedBox(height: AppSpacing.space5),
            Text(
              '방문 순서',
              style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
            ),
            const SizedBox(height: AppSpacing.space4),
            for (var i = 0; i < result.orderedPlaces.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.brandPrimary,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: AppTextStyle.small.copyWith(
                        color: AppColors.textOnBrand,
                        fontWeight: AppFont.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '장소 ${result.orderedPlaces[i]}',
                          style: AppTextStyle.body.copyWith(
                            fontWeight: AppFont.semibold,
                          ),
                        ),
                        if (i < result.segmentTimes.length)
                          Text(
                            '다음 장소까지 ${result.segmentTimes[i]}분',
                            style: AppTextStyle.small.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space4),
            ],
            AppButton(
              label: '코스 저장',
              width: double.infinity,
              size: AppButtonSize.lg,
              onPressed: state.courseId == null ? null : _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    await ref.read(courseProvider.notifier).save();
    if (!mounted) return;
    final action = ref.read(courseProvider).saveAction;
    AppToast.show(
      context,
      title: action?.hasError ?? false ? '저장 실패' : '저장 완료',
      message: action?.hasError ?? false
          ? (action!.apiError?.displayMessage ?? '코스를 저장하지 못했어요.')
          : '내 여행에 담았어요.',
      tone: action?.hasError ?? false
          ? AppToastTone.danger
          : AppToastTone.success,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

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
