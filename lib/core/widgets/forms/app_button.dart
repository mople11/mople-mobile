import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

enum AppButtonVariant { primary, secondary, accent, outline, ghost, danger }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? leading;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.leading,
    this.width,
  });

  bool get _disabled => onPressed == null;

  @override
  Widget build(BuildContext context) {
    final colors = _AppButtonColors.forVariant(variant);
    final metrics = _AppButtonMetrics.forSize(size);
    // disabled 시 Opacity 위젯 대신 색상 알파를 낮춰 컴포지팅 레이어 생성을 피한다.
    final background = _disabled ? _fade(colors.background) : colors.background;
    final foreground = _disabled ? _fade(colors.foreground) : colors.foreground;
    final border = colors.border == null
        ? null
        : (_disabled ? _fade(colors.border!) : colors.border!);

    return Material(
      color: background,
      borderRadius: AppRadius.radiusMd,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.radiusMd,
        child: Container(
          width: width,
          height: metrics.height,
          padding: EdgeInsets.symmetric(horizontal: metrics.horizontalPadding),
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusMd,
            border: border != null
                ? Border.all(color: border, width: 1.5)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.space2),
              ],
              Text(
                label,
                style: metrics.textStyle.copyWith(
                  color: foreground,
                  fontWeight: AppFont.semibold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _fade(Color color) => color.withValues(alpha: color.a * 0.5);
}

class _AppButtonColors {
  final Color background;
  final Color foreground;
  final Color? border;

  const _AppButtonColors({
    required this.background,
    required this.foreground,
    this.border,
  });

  static _AppButtonColors forVariant(AppButtonVariant variant) {
    switch (variant) {
      case AppButtonVariant.primary:
        return const _AppButtonColors(
          background: AppColors.brandPrimary,
          foreground: AppColors.textOnBrand,
        );
      case AppButtonVariant.secondary:
        return const _AppButtonColors(
          background: AppColors.brandSecondary,
          foreground: AppColors.textOnBrand,
        );
      case AppButtonVariant.accent:
        return const _AppButtonColors(
          background: AppColors.brandAccent,
          foreground: AppColors.textPrimary,
        );
      case AppButtonVariant.outline:
        return const _AppButtonColors(
          background: Colors.transparent,
          foreground: AppColors.textBrand,
          border: AppColors.borderBrand,
        );
      case AppButtonVariant.ghost:
        return const _AppButtonColors(
          background: Colors.transparent,
          foreground: AppColors.textPrimary,
        );
      case AppButtonVariant.danger:
        return const _AppButtonColors(
          background: AppColors.danger,
          foreground: AppColors.textOnBrand,
        );
    }
  }
}

class _AppButtonMetrics {
  final double height;
  final double horizontalPadding;
  final TextStyle textStyle;

  const _AppButtonMetrics({
    required this.height,
    required this.horizontalPadding,
    required this.textStyle,
  });

  static _AppButtonMetrics forSize(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.sm:
        return const _AppButtonMetrics(
          height: 32,
          horizontalPadding: AppSpacing.space3,
          textStyle: AppTextStyle.caption,
        );
      case AppButtonSize.md:
        return const _AppButtonMetrics(
          height: 40,
          horizontalPadding: AppSpacing.space4,
          textStyle: AppTextStyle.body,
        );
      case AppButtonSize.lg:
        return const _AppButtonMetrics(
          height: 54,
          horizontalPadding: AppSpacing.space5,
          textStyle: AppTextStyle.bodyLg,
        );
    }
  }
}
