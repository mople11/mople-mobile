import 'package:flutter/material.dart';

import '../display/app_network_image.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/shadow.dart';
import '../../constants/spacing.dart';

/// 저장한 코스 · 대안 장소 추천에 쓰이는 가로형 카드.
class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.title,
    required this.summary,
    required this.stops,
    required this.duration,
    required this.image,
    this.tags = const [],
    this.onTap,
  });

  final String title;
  final String summary;
  final int stops;
  final String duration;
  final String image;
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: AppNetworkImage(url: image),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space3,
                    AppSpacing.space3,
                    AppSpacing.space3,
                    AppSpacing.space3,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyle.bodyLg.copyWith(
                          fontWeight: AppFont.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        summary,
                        style: AppTextStyle.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.space2),
                      if (tags.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          children: [
                            for (final tag in tags.take(2))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.space2,
                                  vertical: 2,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppColors.fillBrandSoft,
                                  borderRadius: AppRadius.radiusPill,
                                ),
                                child: Text(
                                  tag,
                                  style: AppTextStyle.small.copyWith(
                                    color: AppColors.textBrand,
                                    fontWeight: AppFont.semibold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: AppSpacing.space2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.explore_rounded,
                            size: 13,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$stops곳',
                            style: AppTextStyle.small.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space3),
                          const Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            duration,
                            style: AppTextStyle.small.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
