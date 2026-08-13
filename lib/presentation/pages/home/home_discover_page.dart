import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/controllers/main_tab_controller.dart';
import 'package:mople_mobile/presentation/pages/destination/ai_trip_page.dart';
import 'package:mople_mobile/presentation/pages/destination/course_page.dart';
import 'package:mople_mobile/presentation/pages/destination/detail_page.dart';
import 'package:mople_mobile/presentation/pages/plan/plan_page.dart';

class HomeDiscoverPage extends ConsumerWidget {
  const HomeDiscoverPage({super.key});

  void _seeAll(BuildContext context, WidgetRef ref) {
    ref.read(mainTabProvider.notifier).switchTab('search');
    context.popToFirst();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppDetailScaffold(
      title: '코스 둘러보기',
      onBack: () => context.pop(),
      bodyPadding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space5),
            child: SectionHead(
              title: '지금 인기 있는 곳',
              action: '전체보기',
              onAction: () => _seeAll(context, ref),
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
              separatorBuilder: (_, _) =>
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
                    onTap: () => context.push(DetailPage(destinationId: d.id)),
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
                  onAction: () => context.push(const AiTripPage()),
                ),
                for (final rec in EodiganamData.aiRecs) ...[
                  SizedBox(
                    height: 200,
                    child: AiRecommendationCard(
                      title: rec.title,
                      reason: rec.reason,
                      tags: rec.tags,
                      match: rec.match,
                      image: rec.image,
                      onTap: () => context.push(const CoursePage()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                ],
                AppButton(
                  label: '직접 코스 만들기',
                  variant: AppButtonVariant.outline,
                  width: double.infinity,
                  leading: const Icon(Icons.tune_rounded, size: 18),
                  onPressed: () => context.push(const PlanPage()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
