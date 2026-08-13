import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/spacing.dart';

class AppRating extends StatelessWidget {
  const AppRating({
    super.key,
    required this.value,
    this.showValue = false,
    this.count,
    this.starCount = 5,
    this.starSize = 16,
    this.onChanged,
  });

  final double value;
  final bool showValue;
  final int? count;
  final int starCount;
  final double starSize;

  /// 지정하면 각 별이 탭 가능해지고, 탭한 별의 1부터 시작하는 순번을 전달한다.
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < starCount; i++)
          onChanged == null
              ? _buildStar(i)
              : GestureDetector(
                  onTap: () => onChanged!(i + 1),
                  child: _buildStar(i),
                ),
        if (showValue) ...[
          const SizedBox(width: AppSpacing.space1),
          Text(
            value.toStringAsFixed(1),
            style: AppTextStyle.label.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppFont.semibold,
            ),
          ),
        ],
        if (count != null) ...[
          const SizedBox(width: 2),
          Text(
            '($count)',
            style: AppTextStyle.caption.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ],
    );
  }

  Widget _buildStar(int index) {
    final fill = (value - index).clamp(0.0, 1.0);
    if (fill <= 0) {
      return Icon(
        Icons.star_rounded,
        size: starSize,
        color: AppColors.neutral200,
      );
    }
    if (fill >= 1) {
      return Icon(
        Icons.star_rounded,
        size: starSize,
        color: AppColors.orange500,
      );
    }
    return Stack(
      children: [
        Icon(Icons.star_rounded, size: starSize, color: AppColors.neutral200),
        ClipRect(
          clipper: _FractionalClipper(fill),
          child: Icon(
            Icons.star_rounded,
            size: starSize,
            color: AppColors.orange500,
          ),
        ),
      ],
    );
  }
}

class _FractionalClipper extends CustomClipper<Rect> {
  _FractionalClipper(this.fraction);
  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(covariant _FractionalClipper oldClipper) =>
      oldClipper.fraction != fraction;
}
