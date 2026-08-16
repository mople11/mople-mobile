import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';
import 'package:mople_mobile/presentation/controllers/course_controller.dart';
import 'package:mople_mobile/presentation/pages/destination/course_page.dart';

/// AI 맞춤 코스 — `POST /recommend/ai`.
///
/// 입력(기분/동행/이동수단/시간)을 모아 요청하고, 결과를 코스 상세로 연결한다.
class AiTripPage extends ConsumerStatefulWidget {
  const AiTripPage({super.key, this.initialMood});

  final String? initialMood;

  @override
  ConsumerState<AiTripPage> createState() => _AiTripPageState();
}

class _AiTripPageState extends ConsumerState<AiTripPage> {
  final _freeTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final notifier = ref.read(courseProvider.notifier);
      // courseProvider 는 전역이라 이전 방문의 추천 결과가 남아 있다. 그대로 두면
      // 화면에 들어오자마자 지난 결과(또는 실패 화면)가 떠서 입력 폼을 볼 수 없다.
      notifier.resetPlan();
      final mood = widget.initialMood;
      if (mood != null) notifier.setMood(mood);
    });
  }

  @override
  void dispose() {
    _freeTextController.dispose();
    super.dispose();
  }

  Future<void> _request() async {
    final notifier = ref.read(courseProvider.notifier);
    notifier.setFreeText(
      _freeTextController.text.trim().isEmpty
          ? null
          : _freeTextController.text.trim(),
    );
    await notifier.requestRecommendation();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courseProvider);
    final recommendation = state.recommendation;
    final hasResult = recommendation?.hasValue ?? false;

    return AppDetailScaffold(
      title: hasResult ? 'AI 추천 코스' : 'AI 맞춤 코스',
      onBack: () => context.pop(),
      body: recommendation == null
          ? _buildForm(state)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AsyncView<AiCourseRecommendation>(
                  value: recommendation,
                  loadingHeight: 320,
                  onRetry: _request,
                  builder: (result) => _buildResult(result),
                ),
                // 실패했을 때도 조건을 바꿔 다시 시도할 수 있어야 한다.
                // 이 통로가 없으면 재시도 외에는 화면을 벗어날 방법이 없다.
                if (recommendation.hasError) ...[
                  const SizedBox(height: AppSpacing.space4),
                  AppButton(
                    label: '조건 다시 고르기',
                    variant: AppButtonVariant.outline,
                    width: double.infinity,
                    onPressed: () =>
                        ref.read(courseProvider.notifier).resetPlan(),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildForm(CourseState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘 기분은 어떠세요?',
          style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
        ),
        const SizedBox(height: AppSpacing.space3),
        MoodSelector(
          columns: 3,
          value: state.mood,
          options: EodiganamData.moods.take(6).toList(),
          onChanged: ref.read(courseProvider.notifier).setMood,
        ),
        const SizedBox(height: AppSpacing.space5),
        Text(
          '누구와 함께 가나요?',
          style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
        ),
        const SizedBox(height: AppSpacing.space3),
        Wrap(
          spacing: AppSpacing.space2,
          runSpacing: AppSpacing.space2,
          children: [
            for (final companion in Companion.values)
              FilterPill(
                label: companion.value,
                active: state.companion == companion,
                onTap: () =>
                    ref.read(courseProvider.notifier).setCompanion(companion),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.space5),
        Text(
          '이동수단',
          style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
        ),
        const SizedBox(height: AppSpacing.space3),
        Wrap(
          spacing: AppSpacing.space2,
          runSpacing: AppSpacing.space2,
          children: [
            for (final transport in Transport.values)
              FilterPill(
                label: transport.value,
                active: state.transport == transport,
                onTap: () =>
                    ref.read(courseProvider.notifier).setTransport(transport),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.space5),
        AppTextField(
          label: '추가 요청 (선택)',
          placeholder: '예) 사진 찍기 좋은 곳 위주로',
          controller: _freeTextController,
        ),
        const SizedBox(height: AppSpacing.space6),
        AppButton(
          label: 'AI 코스 만들기',
          width: double.infinity,
          size: AppButtonSize.lg,
          leading: const Icon(
            Icons.auto_awesome_rounded,
            size: 18,
            color: AppColors.neutral0,
          ),
          onPressed: state.canRecommend ? _request : null,
        ),
        if (!state.canRecommend) ...[
          const SizedBox(height: AppSpacing.space2),
          Text(
            '기분을 먼저 선택해주세요.',
            style: AppTextStyle.caption.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ],
    );
  }

  Widget _buildResult(AiCourseRecommendation result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.space5),
          decoration: BoxDecoration(
            color: AppColors.fillBrandSoft,
            borderRadius: AppRadius.radiusLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.name, style: AppTextStyle.h3),
              if (result.reason.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.space2),
                Text(
                  result.reason,
                  style: AppTextStyle.body.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        Text(
          '방문 순서',
          style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
        ),
        const SizedBox(height: AppSpacing.space3),
        for (final place in result.places) ...[
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandPrimary,
                ),
                child: Text(
                  '${place.order}',
                  style: AppTextStyle.small.copyWith(
                    color: AppColors.textOnBrand,
                    fontWeight: AppFont.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Text('장소 ${place.placeId}', style: AppTextStyle.body),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
        ],
        const SizedBox(height: AppSpacing.space4),
        AppButton(
          label: '코스 상세 보기',
          width: double.infinity,
          size: AppButtonSize.lg,
          onPressed: () =>
              context.push(CoursePage(courseId: result.courseId)),
        ),
        const SizedBox(height: AppSpacing.space3),
        AppButton(
          label: '다시 추천받기',
          variant: AppButtonVariant.outline,
          width: double.infinity,
          onPressed: () => ref.read(courseProvider.notifier).resetPlan(),
        ),
      ],
    );
  }
}
