import 'package:flutter/material.dart';

import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';
import '../../constants/tone.dart';

export '../../constants/tone.dart' show AppTone;

enum AppBadgeVariant { solid, soft }

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.tone = AppTone.blue,
    this.variant = AppBadgeVariant.soft,
  });

  final String label;
  final AppTone tone;
  final AppBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final solid = variant == AppBadgeVariant.solid;
    final background = solid ? tone.color : tone.softBackground;
    final foreground = solid ? tone.onColor : tone.softForeground;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.radiusPill,
      ),
      child: Text(
        label,
        style: AppTextStyle.small.copyWith(
          color: foreground,
          fontWeight: AppFont.bold,
        ),
      ),
    );
  }
}
