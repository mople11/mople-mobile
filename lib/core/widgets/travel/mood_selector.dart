import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

class MoodOption {
  const MoodOption({
    required this.value,
    required this.label,
    required this.emoji,
    required this.description,
  });

  final String value;
  final String label;
  final String emoji;
  final String description;
}

class MoodSelector extends StatelessWidget {
  const MoodSelector({
    super.key,
    required this.options,
    this.value,
    this.columns = 4,
    this.onChanged,
  });

  final List<MoodOption> options;
  final String? value;
  final int columns;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: AppSpacing.space3,
        crossAxisSpacing: AppSpacing.space3,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final option = options[index];
        final selected = option.value == value;

        return Material(
          color: selected ? AppColors.fillBrandSoft : AppColors.surfaceCard,
          borderRadius: AppRadius.radiusLg,
          child: InkWell(
            onTap: onChanged == null ? null : () => onChanged!(option.value),
            borderRadius: AppRadius.radiusLg,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.radiusLg,
                border: Border.all(
                  color: selected
                      ? AppColors.borderBrand
                      : AppColors.borderSubtle,
                  width: selected ? 2 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.space4,
                horizontal: AppSpacing.space2,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(option.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    option.label,
                    style: AppTextStyle.label.copyWith(
                      color: selected
                          ? AppColors.textBrand
                          : AppColors.textPrimary,
                      fontWeight: AppFont.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
                    style: AppTextStyle.small.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
