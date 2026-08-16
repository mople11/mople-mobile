import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/place_search_controller.dart';
import 'package:mople_mobile/presentation/pages/destination/detail_page.dart';

/// 통합 검색 — `GET /search`.
///
/// 카테고리 필터는 서버가 받는 [PlaceCategory] 값 집합을 그대로 쓴다.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(placeSearchProvider.notifier).search());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// 타이핑마다 요청하지 않도록 400ms 묶어서 보낸다.
  void _onQueryChanged(String value) {
    ref.read(placeSearchProvider.notifier).setKeyword(value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) ref.read(placeSearchProvider.notifier).search();
    });
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

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space5,
                AppSpacing.space2,
                AppSpacing.space5,
                AppSpacing.space3,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surfaceCard,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderSubtle),
                ),
              ),
              child: Column(
                children: [
                  AppSearchBar(
                    placeholder: '어디로 떠나시나요?',
                    onChanged: _onQueryChanged,
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: PlaceCategory.values.length + 1,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.space2),
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return FilterPill(
                            label: '전체',
                            active: state.category == null,
                            onTap: () => _onCategoryTap(null),
                          );
                        }
                        final category = PlaceCategory.values[i - 1];
                        return FilterPill(
                          label: category.value,
                          active: state.category == category,
                          onTap: () => _onCategoryTap(category),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space5,
                  AppSpacing.space4,
                  AppSpacing.space5,
                  AppSpacing.space6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // 서버가 전체 건수를 pagination 으로 주므로 그 값을 쓴다.
                      '총 ${state.results?.value?.pagination.totalCount ?? 0}곳',
                      style: AppTextStyle.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: AppFont.semibold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    AsyncView<Paged<SearchResultItem>>(
                      value: state.results,
                      loadingHeight: 220,
                      onRetry: () =>
                          ref.read(placeSearchProvider.notifier).search(),
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
                              // 서버 검색 결과에 후기 수·소요시간이 없어 비워 둔다.
                              reviewCount: 0,
                              duration: '',
                              tags: [item.category],
                              onTap: () =>
                                  context.push(DetailPage(destinationId: item.id)),
                            ),
                            const SizedBox(height: AppSpacing.space4),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
