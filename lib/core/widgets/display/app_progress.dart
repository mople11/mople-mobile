import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';
import '../../constants/tone.dart';

class AppProgress extends StatelessWidget {
  const AppProgress({
    super.key,
    required this.value,
    required this.max,
    this.tone = AppTone.blue,
    this.showLabel = false,
  });

  final int value;
  final int max;
  final AppTone tone;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final fraction = max == 0 ? 0.0 : (value / max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Text(
            '$value / $max',
            style: AppTextStyle.label.copyWith(fontWeight: AppFont.semibold),
          ),
          const SizedBox(height: AppSpacing.space2),
        ],
        ClipRRect(
          borderRadius: AppRadius.radiusPill,
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(tone.color),
          ),
        ),
      ],
    );
  }
}
