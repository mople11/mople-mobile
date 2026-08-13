import 'package:flutter/material.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';

class StampPage extends StatelessWidget {
  const StampPage({super.key});

  @override
  Widget build(BuildContext context) {
    final earned = EodiganamData.stamps.where((s) => s.earned).length;

    return AppDetailScaffold(
      title: '전남 여행 도장',
      onBack: () => context.pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.space5),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              border: Border.all(color: AppColors.borderSubtle),
              borderRadius: AppRadius.radiusLg,
            ),
            child: Column(
              children: [
                Text(
                  '수집한 도장',
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: AppFont.semibold,
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '$earned ', style: AppTextStyle.h1),
                      TextSpan(
                        text: '/ ${EodiganamData.stamps.length}',
                        style: AppTextStyle.title.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                AppProgress(
                  value: earned,
                  max: EodiganamData.stamps.length,
                  tone: AppTone.green,
                ),
                const SizedBox(height: AppSpacing.space3),
                Text(
                  '3곳 더 방문하면 \'전남 마스터\' 배지를 받아요!',
                  style: AppTextStyle.small.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
          Text(
            '시·군별 도장',
            style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
          ),
          const SizedBox(height: AppSpacing.space4),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.space4,
            crossAxisSpacing: AppSpacing.space4,
            childAspectRatio: 0.62,
            children: [
              for (final s in EodiganamData.stamps)
                StampBadge(region: s.region, earned: s.earned, emoji: s.emoji),
            ],
          ),
        ],
      ),
    );
  }
}
