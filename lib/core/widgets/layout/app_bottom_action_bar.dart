import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/spacing.dart';

/// 화면 하단에 고정되는 액션 바 — 카드/코스/경로 상세 화면 전반에서 반복되는
/// "상단 구분선 + surfaceCard 배경 + 버튼(들)" 패턴을 하나로 묶습니다.
/// 홈 인디케이터 여백은 내부에서 자체적으로 처리합니다.
class AppBottomActionBar extends StatelessWidget {
  const AppBottomActionBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.space4),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final resolvedPadding = padding
        .resolve(Directionality.of(context))
        .copyWith(
          bottom:
              padding.resolve(Directionality.of(context)).bottom + bottomInset,
        );

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Padding(padding: resolvedPadding, child: child),
    );
  }
}
