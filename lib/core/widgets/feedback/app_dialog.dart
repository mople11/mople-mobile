import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.description,
    this.actions = const [],
  });

  final String title;
  final String? description;
  final List<Widget> actions;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    String? description,
    List<Widget> actions = const [],
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: AppColors.surfaceOverlay,
      builder: (_) =>
          AppDialog(title: title, description: description, actions: actions),
    );
  }

  /// 로그아웃 확인 다이얼로그 — MY/설정 화면에서 공통으로 쓰는 "취소 · 로그아웃" 패턴.
  /// 실제 로그아웃 이동 로직은 [onConfirm]으로 호출부에서 결정합니다.
  ///
  /// [onConfirm]이 서버 호출 등으로 오래 걸릴 수 있으므로 **다이얼로그를 먼저 닫고**
  /// 실행합니다. 그렇지 않으면 응답을 기다리는 동안 다이얼로그가 떠 있습니다.
  static Future<void> confirmLogout(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return show<void>(
      context,
      title: '로그아웃 하시겠어요?',
      actions: [
        Builder(
          builder: (dialogContext) => TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
        ),
        Builder(
          builder: (dialogContext) => FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
            child: const Text('로그아웃'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyle.h3),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.space2),
              Text(
                description!,
                style: AppTextStyle.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.space6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.space2),
                    actions[i],
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
