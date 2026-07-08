import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';

enum AppAvatarSize { sm, md, lg }

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.size = AppAvatarSize.md,
    this.ring = false,
  });

  final String name;
  final AppAvatarSize size;
  final bool ring;

  double get _dimension => switch (size) {
        AppAvatarSize.sm => 32,
        AppAvatarSize.md => 40,
        AppAvatarSize.lg => 56,
      };

  double get _fontSize => switch (size) {
        AppAvatarSize.sm => 12,
        AppAvatarSize.md => 15,
        AppAvatarSize.lg => 20,
      };

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final dimension = _dimension;

    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.brandPrimary,
        border: ring ? Border.all(color: AppColors.surfaceCard, width: 2.5) : null,
        boxShadow: ring ? [BoxShadow(color: AppColors.brandPrimary.withValues(alpha: 0.35), blurRadius: 0, spreadRadius: 2)] : null,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: AppTextStyle.label.copyWith(
          color: AppColors.textOnBrand,
          fontWeight: AppFont.bold,
          fontSize: _fontSize,
        ),
      ),
    );
  }
}
