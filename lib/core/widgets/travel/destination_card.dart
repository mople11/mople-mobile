import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/shadow.dart';
import '../../constants/spacing.dart';
import '../display/app_badge.dart';
import '../display/app_rating.dart';
import 'weather_chip.dart';

class DestinationCard extends StatelessWidget {
  const DestinationCard({
    super.key,
    required this.image,
    required this.title,
    required this.region,
    required this.rating,
    required this.reviewCount,
    required this.duration,
    this.badge,
    this.weather,
    this.tags = const [],
    this.onTap,
  });

  final String image;
  final String title;
  final String region;
  final double rating;
  final int reviewCount;
  final String duration;
  final String? badge;
  final ({WeatherCondition condition, int temp})? weather;
  final List<String> tags;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard,
      borderRadius: AppRadius.radiusLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusLg,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadow.card,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(image, fit: BoxFit.cover),
                  ),
                  if (badge != null)
                    Positioned(
                      top: AppSpacing.space3,
                      left: AppSpacing.space3,
                      child: AppBadge(
                        label: badge!,
                        tone: AppTone.orange,
                        variant: AppBadgeVariant.solid,
                      ),
                    ),
                  if (weather != null)
                    Positioned(
                      top: AppSpacing.space3,
                      right: AppSpacing.space3,
                      child: WeatherChip(
                        condition: weather!.condition,
                        temp: weather!.temp,
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$region · $duration',
                      style: AppTextStyle.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    AppRating(
                      value: rating,
                      showValue: true,
                      count: reviewCount,
                      starSize: 14,
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.space3),
                      Wrap(
                        spacing: AppSpacing.space1,
                        runSpacing: AppSpacing.space1,
                        children: [
                          for (final tag in tags)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.space2,
                                vertical: 3,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceSunken,
                                borderRadius: AppRadius.radiusPill,
                              ),
                              child: Text(tag, style: AppTextStyle.small),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
