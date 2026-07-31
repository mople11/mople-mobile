import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/shadow.dart';
import '../../constants/spacing.dart';

class RarityBadge extends StatelessWidget {
  const RarityBadge({super.key, required this.rarity});

  final String rarity;

  ({Gradient? gradient, Color solid}) get _colors => switch (rarity) {
    'LEGENDARY' => (
      gradient: const LinearGradient(
        colors: [AppColors.orange500, Color(0xFFFF8F00)],
      ),
      solid: AppColors.orange500,
    ),
    'RARE' => (gradient: null, solid: AppColors.brandPrimary),
    'UNCOMMON' => (gradient: null, solid: AppColors.brandSecondary),
    _ => (gradient: null, solid: AppColors.neutral500),
  };

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: colors.gradient == null ? colors.solid : null,
        gradient: colors.gradient,
        borderRadius: AppRadius.radiusPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 11, color: AppColors.neutral0),
          const SizedBox(width: 4),
          Text(
            rarity,
            style: AppTextStyle.small.copyWith(
              color: AppColors.neutral0,
              fontWeight: AppFont.extrabold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 숨겨진 여행지 게이미피케이션 카드 — 날씨 조건 충족 시 해금.
class UnlockCard extends StatelessWidget {
  const UnlockCard({
    super.key,
    required this.title,
    required this.rarity,
    required this.condition,
    required this.unlocked,
    required this.image,
    this.onTap,
  });

  final String title;
  final String rarity;
  final String condition;
  final bool unlocked;
  final String image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard,
      borderRadius: AppRadius.radiusLg,
      child: InkWell(
        onTap: unlocked ? onTap : null,
        borderRadius: AppRadius.radiusLg,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: unlocked ? AppShadow.card : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 110,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColorFiltered(
                      colorFilter: unlocked
                          ? const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            )
                          : const ColorFilter.matrix(<double>[
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0,
                              0,
                              0,
                              0.55,
                              0,
                            ]),
                      child: Image.network(image, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: RarityBadge(rarity: rarity),
                    ),
                    if (!unlocked)
                      const Center(
                        child: Icon(
                          Icons.lock_rounded,
                          size: 26,
                          color: AppColors.neutral0,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.space3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      unlocked ? title : '???',
                      style: AppTextStyle.caption.copyWith(
                        fontWeight: AppFont.bold,
                        color: unlocked
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      unlocked ? '해금됨' : condition,
                      style: AppTextStyle.small.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
