import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';

class AppSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final String Function(double value)? formatValue;

  const AppSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.onChanged,
    this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    final display = formatValue != null ? formatValue!(value) : value.toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyle.label),
            Text(display, style: AppTextStyle.label.copyWith(color: AppColors.textPrimary, fontWeight: AppFont.semibold)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.brandPrimary,
            inactiveTrackColor: AppColors.neutral200,
            thumbColor: AppColors.brandPrimary,
            overlayColor: AppColors.ringBrand,
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
