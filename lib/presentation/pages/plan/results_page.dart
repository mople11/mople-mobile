import 'package:flutter/material.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/plan/route_page.dart';

class ResultsPage extends StatefulWidget {
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
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  String _active = '바다뷰';
  static const _filters = ['바다뷰', '자연', '맛집', '포토존'];

  @override
  Widget build(BuildContext context) {
    final results = EodiganamData.destinations
        .where((d) => d.tags.contains(_active))
        .toList();

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
              const FilterPill(label: '지역', hasDropdown: true),
              const SizedBox(width: AppSpacing.space2),
              for (final f in _filters) ...[
                FilterPill(
                  label: f,
                  active: _active == f,
                  onTap: () => setState(() => _active = f),
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
                const Text('☀️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: AppSpacing.space2),
                Expanded(
                  child: Text(
                    '${widget.companionLabel} · ${widget.transportLabel} · '
                    '${widget.hours.round()}시간 기준, 맑은 날씨예요 — 야외 코스를 우선 추천했어요.',
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.infoText,
                      fontWeight: AppFont.semibold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
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
                  condition: weatherConditionFromKorean(d.weatherLabel),
                  temp: d.weatherTemp,
                ),
                onTap: () => context.push(
                  RoutePage(
                    companionLabel: widget.companionLabel,
                    transportLabel: widget.transportLabel,
                    hours: widget.hours,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
            ],
        ],
      ),
    );
  }
}
