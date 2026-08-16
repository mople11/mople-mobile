import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/place_search_controller.dart';
import 'package:mople_mobile/presentation/pages/plan/route_page.dart';

/// 추천 결과 — 검색 API(`GET /search`)로 조건에 맞는 장소를 보여준다.
///
/// 선택한 장소는 동선 최적화(`POST /courses/optimize`)에 넘길 수 있도록
/// [placeSearchProvider] 결과에서 골라 [RoutePage] 로 전달한다.
class ResultsPage extends ConsumerStatefulWidget {
  const ResultsPage({
    super.key,
    required this.companionLabel,
    required this.transportLabel,
    required this.hours,
  });

  final String companionLabel;
  final String transportLabel;
  final double hours;

  @override
  ConsumerState<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends ConsumerState<ResultsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(placeSearchProvider.notifier).search());
  }

  void _onCategoryTap(PlaceCategory? category) {
    final notifier = ref.read(placeSearchProvider.notifier);
    if (category == null) {
      notifier.clearFilters();
    } else {
      notifier.toggleCategory(category);
    }
    notifier.search();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(placeSearchProvider);

    return AppDetailScaffold(
      title: '추천 결과',
      onBack: () => context.pop(),
      subHeader: Container(
        color: AppColors.surfaceCard,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space5,
          vertical: AppSpacing.space3,
        ),
        child: SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              FilterPill(
                label: '전체',
                active: state.category == null,
                onTap: () => _onCategoryTap(null),
              ),
              const SizedBox(width: AppSpacing.space2),
              for (final category in PlaceCategory.values) ...[
                FilterPill(
                  label: category.value,
                  active: state.category == category,
                  onTap: () => _onCategoryTap(category),
                ),
                const SizedBox(width: AppSpacing.space2),
              ],
            ],
          ),
        ),
      ),
      bodyPadding: const EdgeInsets.fromLTRB(
        AppSpacing.space5,
        AppSpacing.space4,
        AppSpacing.space5,
        AppSpacing.space6,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space3,
              vertical: AppSpacing.space3,
            ),
            margin: const EdgeInsets.only(bottom: AppSpacing.space4),
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              borderRadius: AppRadius.radiusMd,
            ),
            child: Row(
              children: [
                const Text('🧭', style: TextStyle(fontSize: 18)),
                const SizedBox(width: AppSpacing.space2),
                Expanded(
                  child: Text(
                    '${widget.companionLabel} · ${widget.transportLabel} · '
                    '${widget.hours.round()}시간 기준으로 골랐어요.',
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.infoText,
                      fontWeight: AppFont.semibold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AsyncView<Paged<SearchResultItem>>(
            value: state.results,
            loadingHeight: 260,
            onRetry: () => ref.read(placeSearchProvider.notifier).search(),
            isEmpty: (paged) => paged.isEmpty,
            emptyMessage: '조건에 맞는 여행지가 없어요.',
            builder: (paged) => Column(
              children: [
                for (final item in paged.items) ...[
                  DestinationCard(
                    image: item.thumbnail,
                    title: item.name,
                    region: item.location,
                    rating: item.rating,
                    reviewCount: 0,
                    duration: '',
                    tags: [item.category],
                    onTap: () => context.push(
                      RoutePage(
                        companionLabel: widget.companionLabel,
                        transportLabel: widget.transportLabel,
                        hours: widget.hours,
                        placeIds: paged.items.map((e) => e.id).toList(),
                        // 최적화 응답은 ID 만 돌려주므로 이름을 함께 넘긴다.
                        placeNames: {
                          for (final e in paged.items) e.id: e.name,
                        },
                      ),
                    ),
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
