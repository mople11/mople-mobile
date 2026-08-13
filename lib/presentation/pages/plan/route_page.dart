import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/controllers/favorites_controller.dart';

class RoutePage extends ConsumerWidget {
  const RoutePage({
    super.key,
    this.companionLabel,
    this.transportLabel,
    this.hours,
  });

  final String? companionLabel;
  final String? transportLabel;
  final double? hours;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final toggleFavorite = ref.read(favoritesProvider.notifier).toggle;
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
                              onPressed: () => context.pop(),
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
                          if (companionLabel != null) ...[
                            const SizedBox(height: AppSpacing.space3),
                            Text(
                              '$companionLabel · $transportLabel · '
                              '${hours!.round()}시간 기준으로 짠 동선이에요',
                              style: AppTextStyle.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
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
              child: Builder(
                builder: (context) {
                  final saved = favorites.isFav(FavoritesNotifier.routeKey);
                  return Row(
                    children: [
                      AppButton(
                        label: saved ? '♥ 저장됨' : '♡ 저장',
                        variant: saved
                            ? AppButtonVariant.secondary
                            : AppButtonVariant.outline,
                        onPressed: () =>
                            toggleFavorite(FavoritesNotifier.routeKey),
                      ),
                      const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: AppButton(
                          label: '이 코스로 떠나기',
                          width: double.infinity,
                          onPressed: () => context.popToFirst(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
