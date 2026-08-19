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
import 'package:mople_mobile/presentation/pages/destination/view/congestion_page.dart';
import 'package:mople_mobile/presentation/pages/destination/view/map_page.dart';
import 'package:mople_mobile/presentation/pages/destination/view/review_page.dart';

/// 장소 상세 — `GET /places/{placeId}` + `GET /places/{placeId}/congestion`.
///
/// 찜(`POST /places/{placeId}/like`)은 낙관적 반영 후 실패 시 되돌린다.
class DetailPage extends ConsumerStatefulWidget {
  const DetailPage({super.key, required this.destinationId});

  final String destinationId;

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(placeDetailProvider(widget.destinationId));

    final notifier = ref.read(
      placeDetailProvider(widget.destinationId).notifier,
    );

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: AsyncView<PlaceDetail>(
                value: state.detail,
                loadingHeight: 420,
                onRetry: notifier.loadDetail,
                builder: (place) => SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(
                        place: place,
                        liked: state.liked,
                        onBack: () => context.pop(),
                        onToggleLike: notifier.toggleLike,
                      ),

                      // ─────────────────────────────────────
                      // 장소 기본 정보
                      // ─────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.space5,
                          AppSpacing.space4,
                          AppSpacing.space5,
                          AppSpacing.space2,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(place.name, style: AppTextStyle.h2),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    place.distanceFromUser.isEmpty
                                        ? place.address
                                        : '${place.address} · ${place.distanceFromUser}',
                                    style: AppTextStyle.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ─────────────────────────────────────
                      // 평점 / 태그 / 설명
                      // ─────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space5,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (place.reviewSummary != null)
                              AppRating(
                                value: place.reviewSummary!.avgRating,
                                showValue: true,
                              ),

                            const SizedBox(height: AppSpacing.space3),

                            Wrap(
                              spacing: AppSpacing.space2,
                              runSpacing: AppSpacing.space2,
                              children: [
                                if (place.category.isNotEmpty)
                                  AppTag(label: place.category),
                                if (place.hours.isNotEmpty)
                                  AppTag(label: place.hours),
                              ],
                            ),

                            // 설명
                            if (place.description.isNotEmpty)
                              _DescriptionSection(
                                description: place.description,
                                isExpanded: _isExpanded,
                                onToggle: () {
                                  setState(() {
                                    _isExpanded = !_isExpanded;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.space5),

                      // ─────────────────────────────────────
                      // 실시간 혼잡도
                      // ─────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space5,
                        ),
                        child: _CongestionSection(
                          state: state,
                          onRetry: () => ref
                              .read(
                                placeDetailProvider(
                                  widget.destinationId,
                                ).notifier,
                              )
                              .loadCongestion(),
                          onTap: () => context.push(
                            CongestionPage(destinationId: widget.destinationId),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.space5),

                      // ─────────────────────────────────────
                      // 위치
                      // ─────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space5,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '위치',
                              style: AppTextStyle.bodyLg.copyWith(
                                fontWeight: AppFont.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space3),
                            Material(
                              color: Colors.transparent,
                              borderRadius: AppRadius.radiusLg,
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => context.push(
                                  MapPage(destination: place.map),
                                ),
                                child: const MapPreviewCard(
                                  height: 150,
                                  pins: 1,
                                  label: '지도에서 보기',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.space5),

                      // ─────────────────────────────────────
                      // 후기
                      // ─────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '후기',
                              style: AppTextStyle.bodyLg.copyWith(
                                fontWeight: AppFont.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push(
                                ReviewPage(
                                  targetId: widget.destinationId,
                                  destinationTitle: place.name,
                                ),
                              ),
                              child: Text(
                                '전체보기',
                                style: AppTextStyle.caption.copyWith(
                                  fontWeight: AppFont.semibold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.space6),
                    ],
                  ),
                ),
              ),
            ),

            // ─────────────────────────────────────────────
            // 하단 고정 액션 바
            // ─────────────────────────────────────────────
            AppBottomActionBar(
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: '길찾기',
                      variant: AppButtonVariant.outline,
                      width: double.infinity,
                      onPressed: () {
                        final detail = state.detail?.value;

                        if (detail == null) {
                          return;
                        }

                        context.push(MapPage(destination: detail.map));
                      },
                    ),
                  ),

                  const SizedBox(width: AppSpacing.space3),

                  Expanded(
                    child: AppButton(
                      label: '후기 보기',
                      width: double.infinity,
                      onPressed: () {
                        final detail = state.detail?.value;

                        if (detail == null) {
                          return;
                        }

                        context.push(
                          ReviewPage(
                            targetId: widget.destinationId,
                            destinationTitle: detail.name,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 설명 영역
// ─────────────────────────────────────────────────────────────

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({
    required this.description,
    required this.isExpanded,
    required this.onToggle,
  });

  final String description;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            maxLines: isExpanded ? null : 4,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: AppTextStyle.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),

          const SizedBox(height: AppSpacing.space2),

          GestureDetector(
            onTap: onToggle,
            child: Text(
              isExpanded ? '접기' : '더보기',
              style: AppTextStyle.caption.copyWith(
                fontWeight: AppFont.semibold,
                color: AppColors.brandAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.place,
    required this.liked,
    required this.onBack,
    required this.onToggleLike,
  });

  final PlaceDetail place;
  final bool liked;
  final VoidCallback onBack;
  final VoidCallback onToggleLike;

  @override
  Widget build(BuildContext context) {
    final image = place.images.isEmpty ? null : place.images.first;

    return Stack(
      children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: image == null || image.isEmpty
              ? const ColoredBox(
                  color: AppColors.surfaceCard,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: AppColors.textTertiary,
                    ),
                  ),
                )
              : AppNetworkImage(url: image),
        ),

        Positioned(
          top: AppSpacing.space2,
          left: AppSpacing.space2,
          right: AppSpacing.space2,
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                AppIconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  semanticLabel: '뒤로',
                  variant: AppIconButtonVariant.solid,
                  onPressed: onBack,
                ),

                const Spacer(),

                AppIconButton(
                  icon: Icon(
                    liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: liked ? AppColors.brandAccent : AppColors.neutral700,
                  ),
                  semanticLabel: liked ? '찜 해제' : '찜',
                  variant: AppIconButtonVariant.solid,
                  onPressed: onToggleLike,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 혼잡도
// ─────────────────────────────────────────────────────────────

class _CongestionSection extends StatelessWidget {
  const _CongestionSection({
    required this.state,
    required this.onTap,
    required this.onRetry,
  });

  final VoidCallback onRetry;

  final PlaceDetailState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '실시간 혼잡도',
          style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
        ),

        const SizedBox(height: AppSpacing.space3),

        if (state.congestionUnavailable)
          Text(
            '혼잡도 정보가 아직 없어요.',
            style: AppTextStyle.caption.copyWith(color: AppColors.textTertiary),
          )
        else
          AsyncView<PlaceCongestion>(
            value: state.congestion,
            loadingHeight: 90,
            onRetry: onRetry,
            builder: (congestion) => Material(
              color: AppColors.surfaceCard,
              borderRadius: AppRadius.radiusLg,
              child: InkWell(
                borderRadius: AppRadius.radiusLg,
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.radiusLg,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (congestion.level != null) ...[
                            CongestionBadge(level: congestion.level!.value),
                            const SizedBox(width: AppSpacing.space2),
                          ],

                          Expanded(
                            child: Text(
                              congestion.recommendedTime.isEmpty
                                  ? '지금 방문하기 좋아요.'
                                  : '추천 시간 ${congestion.recommendedTime}',
                              style: AppTextStyle.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),

                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: AppColors.textTertiary,
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
              ),
            ),
          ),
      ],
    );
  }
}
