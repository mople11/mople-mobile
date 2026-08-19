import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/home_controller.dart';
import 'package:mople_mobile/presentation/controllers/unlock_controller.dart';
import 'package:mople_mobile/presentation/pages/destination/view/course_page.dart';

/// 숨겨진 여행지 — `GET /courses/unlocked`.
class UnlockPage extends ConsumerStatefulWidget {
  const UnlockPage({super.key});

  @override
  ConsumerState<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends ConsumerState<UnlockPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(unlockProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unlockProvider);
    final weather = ref.watch(homeProvider).currentWeather;

    return AppDetailScaffold(
      title: '숨겨진 여행지',
      onBack: () => context.pop(),
      body: AsyncView<UnlockStatus>(
        value: state.status,
        loadingHeight: 320,
        onRetry: () => ref.read(unlockProvider.notifier).load(),
        isEmpty: (status) =>
            status.unlockedCourses.isEmpty && status.lockedCourses.isEmpty,
        emptyMessage: '아직 해금할 코스가 없어요.',
        builder: (status) => Column(
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
                        weather == null
                            ? '오늘의 날씨 코스'
                            : '오늘 날씨: ${weather.weatherType} ${weather.temp}°',
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
                      '${state.unlockedCount} / ${state.totalCount} 해금',
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
                for (final course in status.unlockedCourses)
                  UnlockCard(
                    title: '코스 ${course.courseId}',
                    rarity: course.rarity?.value ?? 'COMMON',
                    condition: '해금 완료',
                    unlocked: true,
                    image: '',
                    onTap: () =>
                        context.push(CoursePage(courseId: course.courseId)),
                  ),
                for (final course in status.lockedCourses)
                  UnlockCard(
                    title: '코스 ${course.courseId}',
                    rarity: 'COMMON',
                    condition: course.unlockCondition,
                    unlocked: false,
                    image: '',
                    onTap: () => AppToast.show(
                      context,
                      title: '아직 잠긴 코스예요',
                      message: course.unlockCondition,
                      tone: AppToastTone.warning,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
