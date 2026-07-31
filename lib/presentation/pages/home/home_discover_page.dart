import 'package:flutter/material.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/destination/ai_trip_page.dart';
import 'package:mople_mobile/presentation/pages/destination/course_page.dart';
import 'package:mople_mobile/presentation/pages/destination/detail_page.dart';

class HomeDiscoverPage extends StatelessWidget {
  const HomeDiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: '코스 둘러보기',
      onBack: () => Navigator.of(context).pop(),
      bodyPadding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space5),
            child: SectionHead(
              title: '지금 인기 있는 곳',
              action: '전체보기',
              onAction: () {},
            ),
          ),
          SizedBox(
            height: 258,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space5,
              ),
              itemCount: EodiganamData.destinations.length.clamp(0, 4),
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.space4),
              itemBuilder: (context, i) {
                final d = EodiganamData.destinations[i];
                return SizedBox(
                  width: 230,
                  child: DestinationCard(
                    image: d.image,
                    title: d.title,
                    region: d.region,
                    rating: d.rating,
                    reviewCount: d.reviewCount,
                    duration: d.duration,
                    badge: d.badge,
                    weather: (
                      condition: weatherConditionFromKorean(d.weatherLabel),
                      temp: d.weatherTemp,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DetailPage()),
                    ),
                  ),
                );
              },
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
                  onAction: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const AiTripPage())),
                ),
                for (final rec in EodiganamData.aiRecs) ...[
                  AiRecommendationCard(
                    title: rec.title,
                    reason: rec.reason,
                    tags: rec.tags,
                    match: rec.match,
                    image: rec.image,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CoursePage()),
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
