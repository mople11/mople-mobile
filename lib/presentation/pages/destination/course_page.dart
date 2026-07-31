import 'package:flutter/material.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/destination/map_page.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final route = EodiganamData.route;
    final d = EodiganamData.destinations.first;

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(d.image, fit: BoxFit.cover),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      AppColors.neutral900.withValues(
                                        alpha: 0.8,
                                      ),
                                      AppColors.neutral900.withValues(
                                        alpha: 0.05,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: AppSpacing.space2,
                          left: AppSpacing.space2,
                          child: SafeArea(
                            bottom: false,
                            child: AppIconButton(
                              icon: const Icon(Icons.chevron_left_rounded),
                              semanticLabel: '뒤로',
                              variant: AppIconButtonVariant.solid,
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ),
                        Positioned(
                          left: AppSpacing.space5,
                          right: AppSpacing.space5,
                          bottom: AppSpacing.space4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const WeatherChip(
                                    condition: WeatherCondition.sunny,
                                    temp: 24,
                                  ),
                                  const SizedBox(width: AppSpacing.space2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.space2,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.neutral0.withValues(
                                        alpha: 0.22,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${route.steps.length}곳 · 6시간',
                                      style: AppTextStyle.small.copyWith(
                                        color: AppColors.neutral0,
                                        fontWeight: AppFont.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.space2),
                              Text(
                                route.title,
                                style: AppTextStyle.h2.copyWith(
                                  color: AppColors.neutral0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.space3,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceCard,
                        border: Border(
                          bottom: BorderSide(color: AppColors.borderSubtle),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatColumn(
                            icon: Icons.navigation_rounded,
                            label: '거리',
                            value: route.distance,
                          ),
                          _StatColumn(
                            icon: Icons.account_balance_wallet_rounded,
                            label: '예상비용',
                            value: route.cost,
                          ),
                          _StatColumn(
                            icon: Icons.explore_rounded,
                            label: '코스',
                            value: '${route.steps.length}곳',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.space5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MapPage(),
                              ),
                            ),
                            child: const MapPreviewCard(
                              height: 160,
                              pins: 4,
                              label: '전체 동선 지도',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space5),
                          Text(
                            '추천 동선',
                            style: AppTextStyle.bodyLg.copyWith(
                              fontWeight: AppFont.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          RouteStepList(steps: route.steps),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppBottomActionBar(
              child: Row(
                children: [
                  AppButton(
                    label: _saved ? '저장됨' : '저장',
                    variant: _saved
                        ? AppButtonVariant.secondary
                        : AppButtonVariant.outline,
                    leading: Icon(
                      _saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 16,
                      color: _saved
                          ? AppColors.textOnBrand
                          : AppColors.textBrand,
                    ),
                    onPressed: () => setState(() => _saved = !_saved),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: AppButton(
                      label: '내비게이션 시작',
                      width: double.infinity,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MapPage()),
                      ),
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

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyle.small.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyle.caption.copyWith(fontWeight: AppFont.bold),
        ),
      ],
    );
  }
}
