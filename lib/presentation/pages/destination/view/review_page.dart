import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';
import 'package:mople_mobile/presentation/controllers/review_board_controller.dart';

/// 후기 목록·작성 — `GET /reviews`, `POST /reviews`, `GET /reviews/summary`.
class ReviewPage extends ConsumerStatefulWidget {
  const ReviewPage({
    super.key,
    required this.targetId,
    this.destinationTitle = '',
  });

  final String targetId;
  final String destinationTitle;

  @override
  ConsumerState<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends ConsumerState<ReviewPage> {
  final _textController = TextEditingController();
  bool _writing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  ReviewBoardNotifier get _notifier =>
      ref.read(reviewBoardProvider(widget.targetId).notifier);

  Future<void> _submit() async {
    _notifier.setText(_textController.text);
    final result = await _notifier.submit();
    if (!mounted) return;

    if (result == null) {
      final error = ref.read(reviewBoardProvider(widget.targetId)).submitState;
      AppToast.show(
        context,
        title: '등록 실패',
        message: error?.apiError?.displayMessage ?? '후기를 등록하지 못했어요.',
        tone: AppToastTone.danger,
      );
      return;
    }
    _textController.clear();
    setState(() => _writing = false);
    AppToast.show(
      context,
      title: '등록 완료',
      message: '후기가 등록됐어요.',
      tone: AppToastTone.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewBoardProvider(widget.targetId));

    return AppDetailScaffold(
      title: '후기',
      onBack: () => context.pop(),
      trailing: GestureDetector(
        onTap: () => setState(() => _writing = !_writing),
        child: Text(
          _writing ? '취소' : '작성',
          style: AppTextStyle.caption.copyWith(
            color: AppColors.textBrand,
            fontWeight: AppFont.bold,
          ),
        ),
      ),
      body: _writing ? _buildWriteForm(state) : _buildList(state),
    );
  }

  Widget _buildWriteForm(ReviewBoardState state) {
    final submitting = state.submitState?.isLoading ?? false;

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
                widget.destinationTitle.isEmpty
                    ? '방문은 어떠셨나요?'
                    : '${widget.destinationTitle}, 어떠셨나요?',
                style: AppTextStyle.body.copyWith(fontWeight: AppFont.bold),
              ),
              const SizedBox(height: AppSpacing.space3),
              AppRating(
                value: state.draftRating,
                starSize: 34,
                onChanged: (v) => _notifier.setRating(v.toDouble()),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        AppTextField(
          label: '후기',
          placeholder: '어떤 점이 좋았는지 알려주세요',
          controller: _textController,
        ),
        const SizedBox(height: AppSpacing.space5),
        AppButton(
          label: submitting ? '등록 중...' : '후기 등록',
          width: double.infinity,
          size: AppButtonSize.lg,
          onPressed: submitting ? null : _submit,
        ),
      ],
    );
  }

  Widget _buildList(ReviewBoardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!state.summaryUnavailable)
          AsyncView<ReviewSummary>(
            value: state.summary,
            loadingHeight: 80,
            builder: (summary) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                border: Border.all(color: AppColors.borderSubtle),
                borderRadius: AppRadius.radiusLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        summary.score.toStringAsFixed(1),
                        style: AppTextStyle.h2,
                      ),
                      const SizedBox(width: AppSpacing.space2),
                      Text(
                        'AI 만족도',
                        style: AppTextStyle.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (summary.keywords != null) ...[
                    const SizedBox(height: AppSpacing.space3),
                    Wrap(
                      spacing: AppSpacing.space2,
                      runSpacing: AppSpacing.space2,
                      children: [
                        for (final k in summary.keywords!.positive)
                          AppTag(label: k),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.space4),
        Row(
          children: [
            for (final sort in ReviewSort.values) ...[
              FilterPill(
                label: sort == ReviewSort.latest ? '최신순' : '별점순',
                active: state.sort == sort,
                onTap: () => _notifier.changeSort(sort),
              ),
              const SizedBox(width: AppSpacing.space2),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.space4),
        AsyncView<Paged<Review>>(
          value: state.reviews,
          loadingHeight: 220,
          onRetry: _notifier.loadReviews,
          isEmpty: (paged) => paged.isEmpty,
          emptyMessage: '아직 등록된 후기가 없어요.',
          builder: (paged) => Column(
            children: [
              for (final review in paged.items) ...[
                _ReviewTile(
                  review: review,
                  helpfulCount: state.helpfulCountOf(review.reviewId),
                  onHelpful: () => _notifier.markHelpful(review.reviewId),
                ),
                const SizedBox(height: AppSpacing.space3),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 서버 [Review] 를 그리는 카드. 목업 전용인 `ReviewCard` 와 모델이 달라 따로 둔다.
class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.review,
    required this.helpfulCount,
    required this.onHelpful,
  });

  final Review review;
  final int helpfulCount;
  final VoidCallback onHelpful;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: AppRadius.radiusLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.author,
                  style: AppTextStyle.caption.copyWith(
                    fontWeight: AppFont.bold,
                  ),
                ),
              ),
              AppRating(value: review.rating, starSize: 14),
            ],
          ),
          if (review.text.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space2),
            Text(
              review.text,
              style: AppTextStyle.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.space3),
          GestureDetector(
            onTap: onHelpful,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.thumb_up_alt_outlined,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '도움돼요 $helpfulCount',
                  style: AppTextStyle.small.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: AppFont.semibold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
