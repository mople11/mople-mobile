import 'package:flutter/material.dart';

import '../../constants/color.dart';
import 'app_button.dart' show AppButtonSize;

enum AppIconButtonVariant { solid, soft, outline, ghost }

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.variant = AppIconButtonVariant.soft,
    this.size = AppButtonSize.md,
  });

  final Widget icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final AppButtonSize size;

  double get _dimension => switch (size) {
        AppButtonSize.sm => 32,
        AppButtonSize.md => 40,
        AppButtonSize.lg => 48,
      };

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(variant);
    final disabled = onPressed == null;
    // disabled 시 Opacity 위젯 대신 색상 알파를 낮춰 컴포지팅 레이어 생성을 피한다.
    final background = disabled ? _fade(colors.background) : colors.background;
    final foreground = disabled ? _fade(colors.foreground) : colors.foreground;
    final border = colors.border == null
        ? null
        : (disabled ? _fade(colors.border!) : colors.border!);

    return Semantics(
      label: semanticLabel,
      button: true,
      child: Material(
        color: background,
        shape: CircleBorder(side: border != null ? BorderSide(color: border, width: 1.5) : BorderSide.none),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: _dimension,
            height: _dimension,
            child: IconTheme.merge(
              data: IconThemeData(color: foreground, size: _dimension * 0.45),
              child: Center(child: icon),
            ),
          ),
        ),
      ),
    );
  }

  static Color _fade(Color color) => color.withValues(alpha: color.a * 0.5);

  static ({Color background, Color foreground, Color? border}) _colorsFor(AppIconButtonVariant variant) {
    switch (variant) {
      case AppIconButtonVariant.solid:
        return (background: AppColors.brandPrimary, foreground: AppColors.textOnBrand, border: null);
      case AppIconButtonVariant.soft:
        return (background: AppColors.fillBrandSoft, foreground: AppColors.textBrand, border: null);
      case AppIconButtonVariant.outline:
        return (background: Colors.transparent, foreground: AppColors.textPrimary, border: AppColors.borderDefault);
      case AppIconButtonVariant.ghost:
        return (background: Colors.transparent, foreground: AppColors.textSecondary, border: null);
    }
  }
}
