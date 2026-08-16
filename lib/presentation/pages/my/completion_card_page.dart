import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/completion_card_controller.dart';

/// 완주 카드 — `GET /cards`, `POST /cards/{cardId}/share`.
class CompletionCardPage extends ConsumerStatefulWidget {
  const CompletionCardPage({super.key});

  @override
  ConsumerState<CompletionCardPage> createState() =>
      _CompletionCardPageState();
}

class _CompletionCardPageState extends ConsumerState<CompletionCardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(completionCardProvider.notifier).load());
  }

  Future<void> _share(String cardId) async {
    final result = await ref
        .read(completionCardProvider.notifier)
        .share(cardId);
    if (!mounted) return;
    AppToast.show(
      context,
      title: result == null ? '공유 실패' : '공유 링크',
      message: result?.shareUrl ?? '공유 링크를 만들지 못했어요.',
      tone: result == null ? AppToastTone.danger : AppToastTone.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(completionCardProvider);

    return AppDetailScaffold(
      title: '완주 카드',
      onBack: () => context.pop(),
      body: AsyncView<List<CompletionCard>>(
        value: state.cards,
        loadingHeight: 300,
        onRetry: () => ref.read(completionCardProvider.notifier).load(),
        isEmpty: (cards) => cards.isEmpty,
        emptyMessage: '아직 완주한 코스가 없어요.\n코스를 완주하면 카드가 만들어져요.',
        builder: (cards) => Column(
          children: [
            for (final card in cards) ...[
              _CardTile(card: card, onShare: () => _share(card.cardId)),
              const SizedBox(height: AppSpacing.space4),
            ],
          ],
        ),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card, required this.onShare});

  final CompletionCard card;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: AppRadius.radiusLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (card.imageUrl.isNotEmpty)
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Image.network(
                card.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(color: AppColors.surfaceSunken),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.courseName,
                        style: AppTextStyle.body.copyWith(
                          fontWeight: AppFont.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        card.date,
                        style: AppTextStyle.small.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppIconButton(
                  icon: const Icon(Icons.share_rounded),
                  semanticLabel: '공유',
                  variant: AppIconButtonVariant.ghost,
                  onPressed: onShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
