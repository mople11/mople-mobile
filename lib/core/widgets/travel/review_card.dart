import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/shadow.dart';
import '../../constants/spacing.dart';
import '../display/app_avatar.dart';
import '../display/app_rating.dart';
import '../../mock/eodiganam_data.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});

  final ReviewItem review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: AppRadius.radiusLg,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AppAvatar(name: review.avatar, size: AppAvatarSize.sm),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      review.name,
                      style: AppTextStyle.caption.copyWith(
                        fontWeight: AppFont.bold,
                      ),
                    ),
                    Text(
                      '${review.place} · ${review.date}',
                      style: AppTextStyle.small.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              AppRating(value: review.rating, starSize: 14),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            review.body,
            style: AppTextStyle.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.65,
            ),
          ),
          if (review.images > 0) ...[
            const SizedBox(height: AppSpacing.space3),
            Row(
              children: [
                for (var i = 0; i < review.images; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      right: i == review.images - 1 ? 0 : AppSpacing.space2,
                    ),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSunken,
                        borderRadius: AppRadius.radiusSm,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_rounded,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.space3),
          Row(
            children: [
              const Icon(
                Icons.favorite_rounded,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 5),
              Text(
                '도움돼요 ${review.likes}',
                style: AppTextStyle.small.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: AppFont.semibold,
                ),
              ),
              const SizedBox(width: AppSpacing.space4),
              const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 5),
              Text(
                '댓글',
                style: AppTextStyle.small.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: AppFont.semibold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
