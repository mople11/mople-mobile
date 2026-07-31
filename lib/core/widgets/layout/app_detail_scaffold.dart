import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/spacing.dart';
import '../navigation/app_nav_bar.dart';

/// 상단 [AppNavBar] + 스크롤 가능한 본문 + (선택) 하단 고정 바로 구성되는
/// 서브 페이지 공통 뼈대. 로그인 이후 대부분의 상세/설정류 화면이 이 구조를
/// 반복하므로 하나로 묶어 보일러플레이트를 줄입니다.
class AppDetailScaffold extends StatelessWidget {
  const AppDetailScaffold({
    super.key,
    this.title,
    this.onBack,
    this.trailing,
    this.subHeader,
    required this.body,
    this.bottomBar,
    this.scrollable = true,
    this.bodyPadding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.space5,
      vertical: AppSpacing.space4,
    ),
    this.backgroundColor = AppColors.surfacePage,
  });

  final String? title;
  final VoidCallback? onBack;
  final Widget? trailing;

  /// 내비게이션 바 바로 아래, 스크롤되지 않는 영역(필터 pill, 탭 등).
  final Widget? subHeader;

  final Widget body;

  /// 화면 하단에 고정되는 액션 바. 보통 [AppBottomActionBar]를 전달합니다.
  final Widget? bottomBar;

  /// false면 [body]를 그대로 배치합니다(이미 스크롤 위젯을 포함하는 경우).
  final bool scrollable;
  final EdgeInsetsGeometry bodyPadding;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppNavBar(title: title, onBack: onBack, trailing: trailing),
            ?subHeader,
            Expanded(
              child: scrollable
                  ? SingleChildScrollView(padding: bodyPadding, child: body)
                  : Padding(padding: bodyPadding, child: body),
            ),
            ?bottomBar,
          ],
        ),
      ),
    );
  }
}
