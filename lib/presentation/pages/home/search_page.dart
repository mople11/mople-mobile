import 'package:flutter/material.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/destination/detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.onSwitchTab});

  final ValueChanged<String> onSwitchTab;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _active = '전체';
  static const _filters = ['전체', '바다뷰', '자연', '맛집', '포토존', '역사'];

  @override
  Widget build(BuildContext context) {
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
                  const AppSearchBar(placeholder: '어디로 떠나시나요?'),
                  const SizedBox(height: AppSpacing.space3),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) =>
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
                          '총 ${EodiganamData.destinations.length}곳',
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
                    for (final d in EodiganamData.destinations) ...[
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
                          condition: weatherConditionFromKorean(d.weatherLabel),
                          temp: d.weatherTemp,
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const DetailPage()),
                        ),
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
