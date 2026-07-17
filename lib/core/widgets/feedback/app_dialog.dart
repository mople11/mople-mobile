import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String? description;
  final List<Widget> actions;

  const AppDialog({
    super.key,
    required this.title,
    this.description,
    this.actions = const [],
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    String? description,
    List<Widget> actions = const [],
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: AppColors.surfaceOverlay,
      builder: (_) => AppDialog(title: title, description: description, actions: actions),
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
              Text(description!, style: AppTextStyle.body.copyWith(color: AppColors.textSecondary)),
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
