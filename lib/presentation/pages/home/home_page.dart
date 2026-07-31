import 'package:flutter/material.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/destination/ai_trip_page.dart';
import 'package:mople_mobile/presentation/pages/home/home_discover_page.dart';
import 'package:mople_mobile/presentation/pages/home/weather_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onSwitchTab});

  final ValueChanged<String> onSwitchTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _mood = 'heal';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space5,
          AppSpacing.space2,
          AppSpacing.space5,
          AppSpacing.space6,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wb_sunny_rounded,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '오늘 · 7월 7일',
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '안녕하세요, ${EodiganamData.user.name.replaceAll('김', '')}님',
                      style: AppTextStyle.h3,
                    ),
                  ],
                ),
                AppIconButton(
                  icon: const Icon(Icons.cloud_rounded),
                  semanticLabel: '날씨',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WeatherPage()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space3),
            GestureDetector(
              onTap: () => widget.onSwitchTab('search'),
              child: const AbsorbPointer(
                child: AppSearchBar(placeholder: '여수, 순천, 담양…'),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            const WeatherCard(
              region: '순천시',
              condition: WeatherCondition.sunny,
              temp: 24,
              high: 26,
              low: 17,
            ),
            const SizedBox(height: AppSpacing.space5),
            Text(
              '오늘 기분은 어떠세요?',
              style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
            ),
            const SizedBox(height: AppSpacing.space3),
            MoodSelector(
              columns: 3,
              value: _mood,
              options: EodiganamData.moods.take(6).toList(),
              onChanged: (v) => setState(() => _mood = v),
            ),
            const SizedBox(height: AppSpacing.space4),
            AppButton(
              label: 'AI 맞춤 코스 만들기',
              width: double.infinity,
              size: AppButtonSize.lg,
              leading: const Icon(
                Icons.route_rounded,
                size: 18,
                color: AppColors.neutral0,
              ),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AiTripPage())),
            ),
            const SizedBox(height: AppSpacing.space5),
            Material(
              color: AppColors.fillBrandSoft,
              borderRadius: AppRadius.radiusLg,
              child: InkWell(
                borderRadius: AppRadius.radiusLg,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HomeDiscoverPage()),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '지금 인기 있는 곳 · AI 추천 코스',
                              style: AppTextStyle.body.copyWith(
                                color: AppColors.textBrand,
                                fontWeight: AppFont.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '더 둘러보기',
                              style: AppTextStyle.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textBrand,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
