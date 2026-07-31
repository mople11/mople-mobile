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
  static Future<void> confirmLogout(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return show<void>(
      context,
      title: '로그아웃 하시겠어요?',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: onConfirm,
          child: const Text('로그아웃'),
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
