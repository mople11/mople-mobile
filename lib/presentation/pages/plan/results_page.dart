import 'package:flutter/material.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/plan/route_page.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  String _active = '바다뷰';
  static const _filters = ['바다뷰', '자연', '맛집', '포토존'];

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: '추천 결과',
      onBack: () => Navigator.of(context).pop(),
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
                    '맑은 날씨예요 — 야외 코스를 우선 추천했어요.',
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.infoText,
                      fontWeight: AppFont.semibold,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const RoutePage())),
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
        ],
      ),
    );
  }
}
