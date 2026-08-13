import 'package:flutter/material.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/destination/detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _active = '전체';
  String _query = '';
  static const _filters = ['전체', '바다뷰', '자연', '맛집', '포토존', '역사'];

  List<Destination> get _results => EodiganamData.destinations.where((d) {
    final matchesFilter = _active == '전체' || d.tags.contains(_active);
    final matchesQuery =
        _query.isEmpty ||
        d.title.contains(_query) ||
        d.region.contains(_query) ||
        d.tags.any((t) => t.contains(_query));
    return matchesFilter && matchesQuery;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final results = _results;

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
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.space2),
                      itemBuilder: (context, i) {
                        final f = _filters[i];
                        return FilterPill(
                          label: f,
                          active: _active == f,
                          onTap: () => setState(() => _active = f),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '총 ${results.length}곳',
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: AppFont.semibold,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '추천순',
                              style: AppTextStyle.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: AppFont.semibold,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    if (results.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.space8,
                        ),
                        child: Center(
                          child: Text(
                            '조건에 맞는 여행지가 없어요.',
                            style: AppTextStyle.body.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      )
                    else
                      for (final d in results) ...[
                        DestinationCard(
                          image: d.image,
                          title: d.title,
                          region: d.region,
                          rating: d.rating,
                          reviewCount: d.reviewCount,
                          duration: d.duration,
                          badge: d.badge,
                          tags: d.tags,
                          weather: (
                            condition: weatherConditionFromKorean(
                              d.weatherLabel,
                            ),
                            temp: d.weatherTemp,
                          ),
                          onTap: () =>
                              context.push(DetailPage(destinationId: d.id)),
                        ),
                        const SizedBox(height: AppSpacing.space4),
                      ],
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
