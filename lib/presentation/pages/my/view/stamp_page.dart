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
import 'package:mople_mobile/presentation/controllers/stamp_controller.dart';

/// 전남 여행 도장 — `GET /stamps`.
///
/// 서버는 획득한 시군 코드 목록만 내려주므로, 지역명·이모지 같은 표시용 정보는
/// [EodiganamData.stamps] 의 시군 목록을 기준으로 맞춘다.
class StampPage extends ConsumerStatefulWidget {
  const StampPage({super.key});

  @override
  ConsumerState<StampPage> createState() => _StampPageState();
}

class _StampPageState extends ConsumerState<StampPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(stampProvider.notifier).load());
  }

  /// 서버가 준 `collected[]` 에 이 시군이 들어 있는지 판정한다.
  ///
  /// 서버가 시군 코드(`haenam`)를 주는지 한글명(`해남`)을 주는지 실데이터로
  /// 확인하지 못해 양쪽 모두 대조한다. 코드 대소문자도 무시한다.
  static bool _isCollected(List<String> collected, StampInfo stamp) {
    for (final raw in collected) {
      final value = raw.trim();
      if (value.isEmpty) continue;
      if (value == stamp.region) return true;
      if (value.toLowerCase() == stamp.cityCode.toLowerCase()) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stampProvider);

    return AppDetailScaffold(
      title: '전남 여행 도장',
      onBack: () => context.pop(),
      body: AsyncView<StampBook>(
        value: state.stampBook,
        loadingHeight: 320,
        onRetry: () => ref.read(stampProvider.notifier).load(),
        builder: (book) => Column(
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
                        TextSpan(
                          text: '${state.collectedCount} ',
                          style: AppTextStyle.h1,
                        ),
                        TextSpan(
                          text: '/ ${state.totalCount}',
                          style: AppTextStyle.title.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  AppProgress(
                    value: state.collectedCount,
                    max: state.totalCount == 0 ? 1 : state.totalCount,
                    tone: AppTone.green,
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
                  StampBadge(
                    region: s.region,
                    earned: _isCollected(book.collected, s),
                    emoji: s.emoji,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
