import 'package:flutter/material.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
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
                          height: 220,
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
                                        alpha: 0.72,
                                      ),
                                      AppColors.neutral900.withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: AppSpacing.space3,
                          left: AppSpacing.space3,
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
                                  WeatherChip(
                                    condition: weatherConditionFromKorean(
                                      d.weatherLabel,
                                    ),
                                    temp: d.weatherTemp,
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
                              Text(
                                route.summary,
                                style: AppTextStyle.caption.copyWith(
                                  color: AppColors.neutral0.withValues(
                                    alpha: 0.92,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.space5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppRating(
                                value: d.rating,
                                showValue: true,
                                count: d.reviewCount,
                              ),
                              Row(
                                children: [
                                  const AppTag(label: '순천시'),
                                  const SizedBox(width: AppSpacing.space2),
                                  const AppTag(label: '힐링'),
                                ],
                              ),
                            ],
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
              padding: const EdgeInsets.all(AppSpacing.space5),
              child: Row(
                children: [
                  AppButton(
                    label: _saved ? '♥ 저장됨' : '♡ 저장',
                    variant: _saved
                        ? AppButtonVariant.secondary
                        : AppButtonVariant.outline,
                    onPressed: () => setState(() => _saved = !_saved),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: AppButton(
                      label: '이 코스로 떠나기',
                      width: double.infinity,
                      onPressed: () => Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst),
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
