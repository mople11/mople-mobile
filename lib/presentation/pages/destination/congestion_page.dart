import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/place_detail_controller.dart';
import 'package:mople_mobile/presentation/pages/destination/map_page.dart';

/// 관광지 혼잡도 — `GET /places/{placeId}/congestion`.
class CongestionPage extends ConsumerWidget {
  const CongestionPage({super.key, required this.destinationId});

  final String destinationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(placeDetailProvider(destinationId));
    final notifier = ref.read(placeDetailProvider(destinationId).notifier);
    final name = state.detail?.value?.name ?? '';

    return AppDetailScaffold(
      title: '관광지 혼잡도',
      onBack: () => context.pop(),
      body: state.congestionUnavailable
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
              child: Center(
                child: Text(
                  '혼잡도 정보가 아직 없어요.',
                  style: AppTextStyle.body.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          : AsyncView<PlaceCongestion>(
              value: state.congestion,
              loadingHeight: 300,
              onRetry: notifier.loadCongestion,
              builder: (congestion) => Column(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (name.isNotEmpty) ...[
                          Text(
                            name,
                            style: AppTextStyle.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: AppFont.semibold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space2),
                        ],
                        Row(
                          children: [
                            if (congestion.level != null)
                              CongestionBadge(level: congestion.level!.value),
                            const SizedBox(width: AppSpacing.space2),
                            Expanded(
                              child: Text(
                                congestion.recommendedTime.isEmpty
                                    ? '지금 방문하기 좋아요.'
                                    : '추천 방문 시간 ${congestion.recommendedTime}',
                                style: AppTextStyle.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        Row(
                          children: [
                            const Icon(
                              Icons.local_parking_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '주차 ${congestion.parkingAvailable ? '가능' : '불가'}',
                              style: AppTextStyle.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: AppFont.semibold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  if (congestion.hourlyGraph.isNotEmpty) ...[
                    Text(
                      '시간대별 혼잡도',
                      style: AppTextStyle.bodyLg.copyWith(
                        fontWeight: AppFont.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    _HourlyGraph(hours: congestion.hourlyGraph),
                    const SizedBox(height: AppSpacing.space5),
                  ],
                  AppButton(
                    label: '지도에서 보기',
                    variant: AppButtonVariant.outline,
                    width: double.infinity,
                    onPressed: () => context.push(const MapPage()),
                  ),
                ],
              ),
            ),
    );
  }
}

/// `hourlyGraph` 를 막대로 그린다. 단계(여유/보통/혼잡)를 높이와 색으로 표현.
class _HourlyGraph extends StatelessWidget {
  const _HourlyGraph({required this.hours});

  final List<HourlyCongestion> hours;

  static ({double ratio, Color color}) _style(CongestionLevel? level) =>
      switch (level) {
        CongestionLevel.relaxed => (ratio: 0.35, color: AppColors.success),
        CongestionLevel.normal => (ratio: 0.65, color: AppColors.warning),
        CongestionLevel.crowded => (ratio: 1.0, color: AppColors.danger),
        null => (ratio: 0.15, color: AppColors.borderDefault),
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final hour in hours)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 90 * _style(hour.levelEnum).ratio,
                      decoration: BoxDecoration(
                        color: _style(hour.levelEnum).color,
                        borderRadius: AppRadius.radiusSm,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${hour.hour}시',
                      style: AppTextStyle.small.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
