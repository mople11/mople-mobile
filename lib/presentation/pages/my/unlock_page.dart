import 'package:flutter/material.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/destination/course_page.dart';

class UnlockPage extends StatelessWidget {
  const UnlockPage({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = EodiganamData.unlockCourses;
    final unlockedCount = courses
        .where(
          (c) => c.requiredWeather == EodiganamData.currentWeatherCondition,
        )
        .length;

    return AppDetailScaffold(
      title: '숨겨진 여행지',
      onBack: () => context.pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.space5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.blue500, AppColors.orange500],
              ),
              borderRadius: AppRadius.radiusXl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.wb_sunny_rounded,
                      size: 22,
                      color: AppColors.neutral0,
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Text(
                      '오늘 날씨: ${EodiganamData.currentWeatherCondition} ${EodiganamData.currentWeatherTemp}°',
                      style: AppTextStyle.body.copyWith(
                        color: AppColors.neutral0,
                        fontWeight: AppFont.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  '특정 날씨와 계절에만 만날 수 있는 희귀 코스가 있어요. 날씨 조건이 맞으면 자동으로 해금돼요.',
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.neutral0.withValues(alpha: 0.92),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space3,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutral0.withValues(alpha: 0.22),
                    borderRadius: AppRadius.radiusPill,
                  ),
                  child: Text(
                    '$unlockedCount / ${courses.length} 해금',
                    style: AppTextStyle.small.copyWith(
                      color: AppColors.neutral0,
                      fontWeight: AppFont.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.space4,
            crossAxisSpacing: AppSpacing.space4,
            childAspectRatio: 0.65,
            children: [
              for (final c in courses)
                UnlockCard(
                  title: c.title,
                  rarity: c.rarity,
                  condition: c.condition,
                  unlocked:
                      c.requiredWeather ==
                      EodiganamData.currentWeatherCondition,
                  image: c.image,
                  onTap: () {
                    final unlocked =
                        c.requiredWeather ==
                        EodiganamData.currentWeatherCondition;
                    if (unlocked) {
                      context.push(const CoursePage());
                    } else {
                      AppToast.show(
                        context,
                        title: '아직 잠긴 코스예요',
                        message: c.condition,
                        tone: AppToastTone.warning,
                      );
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
