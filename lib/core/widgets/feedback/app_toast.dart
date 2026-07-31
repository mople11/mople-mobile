import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/shadow.dart';
import '../../constants/spacing.dart';

enum AppToastTone { success, warning, danger, info }

class AppToast extends StatelessWidget {
  const AppToast({
    super.key,
    required this.title,
    required this.message,
    this.tone = AppToastTone.info,
  });

  final String title;
  final String message;
  final AppToastTone tone;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    AppToastTone tone = AppToastTone.info,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        content: AppToast(title: title, message: message, tone: tone),
      ),
    );
  }

  ({Color background, Color border, Color foreground, IconData icon})
  get _colors => switch (tone) {
    AppToastTone.success => (
      background: AppColors.successBg,
      border: AppColors.green200,
      foreground: AppColors.successText,
      icon: Icons.check_circle_rounded,
    ),
    AppToastTone.warning => (
      background: AppColors.warningBg,
      border: AppColors.orange200,
      foreground: AppColors.warningText,
      icon: Icons.wb_cloudy_rounded,
    ),
    AppToastTone.danger => (
      background: AppColors.dangerBg,
      border: AppColors.red500.withValues(alpha: 0.3),
      foreground: AppColors.dangerText,
      icon: Icons.error_rounded,
    ),
    AppToastTone.info => (
      background: AppColors.infoBg,
      border: AppColors.blue200,
      foreground: AppColors.infoText,
      icon: Icons.info_rounded,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final colors = _colors;

    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: colors.border),
        boxShadow: AppShadow.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(colors.icon, color: colors.foreground, size: 20),
          const SizedBox(width: AppSpacing.space3),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyle.label.copyWith(
                    color: colors.foreground,
                    fontWeight: AppFont.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: AppTextStyle.caption.copyWith(
                    color: colors.foreground,
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
