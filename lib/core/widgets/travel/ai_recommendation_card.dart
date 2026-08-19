import 'package:flutter/material.dart';

import '../display/app_network_image.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/shadow.dart';
import '../../constants/spacing.dart';

/// 홈 화면 "AI 추천 코스" 섹션에 쓰이는 풀블리드 사진 카드.
class AiRecommendationCard extends StatelessWidget {
  const AiRecommendationCard({
    super.key,
    required this.title,
    required this.reason,
    required this.image,
    this.tags = const [],
    this.match,
    this.onTap,
  });

  final String title;
  final String reason;
  final String image;
  final List<String> tags;
  final int? match;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.radiusXl,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusXl,
        child: Container(
          constraints: const BoxConstraints(minHeight: 150),
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusXl,
            boxShadow: AppShadow.md,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(url: image),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.neutral900.withValues(alpha: 0.82),
                      AppColors.neutral900.withValues(alpha: 0.15),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.space3,
                left: AppSpacing.space3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutral0.withValues(alpha: 0.22),
                    borderRadius: AppRadius.radiusPill,
                  ),
                  child: Text(
                    'AI 추천',
                    style: AppTextStyle.small.copyWith(
                      color: AppColors.neutral0,
                      fontWeight: AppFont.extrabold,
                    ),
                  ),
                ),
              ),
              if (match != null)
                Positioned(
                  top: AppSpacing.space3,
                  right: AppSpacing.space3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space2,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandAccent,
                      borderRadius: AppRadius.radiusPill,
                    ),
                    child: Text(
                      '$match% 일치',
                      style: AppTextStyle.small.copyWith(
                        color: AppColors.neutral900,
                        fontWeight: AppFont.extrabold,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: AppSpacing.space4,
                right: AppSpacing.space4,
                bottom: AppSpacing.space4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.title.copyWith(
                        color: AppColors.neutral0,
                        fontWeight: AppFont.extrabold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      reason,
                      style: AppTextStyle.caption.copyWith(
                        color: AppColors.neutral0.withValues(alpha: 0.92),
                      ),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.space2),
                      Wrap(
                        spacing: 6,
                        children: [
                          for (final tag in tags)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.space2,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.neutral0.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: AppRadius.radiusPill,
                              ),
                              child: Text(
                                tag,
                                style: AppTextStyle.small.copyWith(
                                  color: AppColors.neutral0,
                                  fontWeight: AppFont.semibold,
                                ),
                              ),
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
