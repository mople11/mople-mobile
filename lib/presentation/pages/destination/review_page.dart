import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/controllers/review_controller.dart';

class ReviewPage extends ConsumerWidget {
  ReviewPage({super.key, String? destinationTitle})
    : destinationTitle =
          destinationTitle ?? EodiganamData.destinations.first.title;

  final String destinationTitle;

  static const _distribution = [(5, 82), (4, 12), (3, 4), (2, 1), (1, 1)];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(reviewProvider);
    final notifier = ref.read(reviewProvider.notifier);

    return AppDetailScaffold(
      title: '리뷰',
      onBack: () => context.pop(),
      trailing: GestureDetector(
        onTap: notifier.toggleWriting,
        child: Text(
          c.writing ? '취소' : '작성',
          style: AppTextStyle.caption.copyWith(
            color: AppColors.textBrand,
            fontWeight: AppFont.bold,
          ),
        ),
      ),
      body: c.writing ? _buildWriteForm(c, notifier) : _buildList(c),
    );
  }

  Widget _buildWriteForm(ReviewState c, ReviewNotifier notifier) {
    final bodyController = TextEditingController();

    return Column(
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
                '$destinationTitle, 어떠셨나요?',
                style: AppTextStyle.body.copyWith(fontWeight: AppFont.bold),
              ),
              const SizedBox(height: AppSpacing.space3),
              AppRating(
                value: c.rating.toDouble(),
                starSize: 34,
                onChanged: notifier.setRating,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        Text('여행 후기', style: AppTextStyle.label),
        const SizedBox(height: AppSpacing.space2),
        TextField(
          controller: bodyController,
          maxLines: 5,
          style: AppTextStyle.body,
          decoration: InputDecoration(
            hintText: '이번 여행은 어땠나요? 다른 여행자에게 도움이 될 이야기를 들려주세요.',
            hintStyle: AppTextStyle.body.copyWith(
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.surfaceCard,
            contentPadding: const EdgeInsets.all(AppSpacing.space4),
            border: const OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: AppColors.borderDefault),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: AppColors.borderDefault),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: AppColors.borderBrand, width: 2),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusMd,
            border: Border.all(color: AppColors.borderDefault, width: 2),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_rounded,
                size: 22,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: 3),
              Text(
                '사진',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        AppButton(
          label: '리뷰 등록',
          width: double.infinity,
          size: AppButtonSize.lg,
          onPressed: () =>
              notifier.submit(bodyController.text, place: destinationTitle),
        ),
      ],
    );
  }

  Widget _buildList(ReviewState c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.space5),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            border: Border.all(color: AppColors.borderSubtle),
            borderRadius: AppRadius.radiusLg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text('4.8', style: AppTextStyle.h2),
                  const AppRating(value: 4.8, starSize: 13),
                ],
              ),
              const SizedBox(width: AppSpacing.space5),
              Expanded(
                child: Column(
                  children: [
                    for (final (star, percent) in _distribution)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10,
                              child: Text(
                                '$star',
                                style: AppTextStyle.small.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.space2),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: percent / 100,
                                  minHeight: 6,
                                  backgroundColor: AppColors.neutral200,
                                  valueColor: const AlwaysStoppedAnimation(
                                    AppColors.brandAccent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        for (final review in c.reviews) ...[
          ReviewCard(review: review),
          const SizedBox(height: AppSpacing.space3),
        ],
      ],
    );
  }
}
