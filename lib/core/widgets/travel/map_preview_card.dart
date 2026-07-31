import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/radius.dart';
import '../../constants/spacing.dart';

/// 실제 지도 SDK 없이 위치를 시각적으로 암시하는 스타일라이즈드 지도 카드.
class MapPreviewCard extends StatelessWidget {
  const MapPreviewCard({
    super.key,
    this.height = 200,
    this.pins = 4,
    this.label,
    this.borderRadius = AppRadius.radiusLg,
  });

  /// null이면 부모가 제공하는 크기를 그대로 채웁니다(예: Positioned.fill 안에서 전체 화면 지도로 사용할 때).
  final double? height;
  final int pins;
  final String? label;
  final BorderRadius borderRadius;

  static const List<Offset> _pinFractions = [
    Offset(0.22, 0.45),
    Offset(0.47, 0.6),
    Offset(0.66, 0.4),
    Offset(0.84, 0.7),
  ];

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      fit: StackFit.expand,
      children: [
        Container(color: const Color(0xFFDCEBF7)),
        CustomPaint(painter: _MapDecorationPainter()),
        for (var i = 0; i < pins && i < _pinFractions.length; i++)
          _MapPin(fraction: _pinFractions[i], isPrimary: i == 0, index: i + 1),
        if (label != null)
          Positioned(
            left: AppSpacing.space3,
            bottom: AppSpacing.space3,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space3,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.neutral0.withValues(alpha: 0.92),
                borderRadius: AppRadius.radiusPill,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.map_rounded,
                    size: 13,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label!,
                    style: AppTextStyle.small.copyWith(
                      fontWeight: AppFont.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: height == null
          ? content
          : SizedBox(height: height, child: content),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.fraction,
    required this.isPrimary,
    required this.index,
  });

  final Offset fraction;
  final bool isPrimary;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment((fraction.dx * 2) - 1, (fraction.dy * 2) - 1),
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.blue500 : AppColors.orange500,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.neutral0, width: 2.5),
        ),
        child: Text(
          '$index',
          style: AppTextStyle.small.copyWith(
            color: AppColors.neutral0,
            fontWeight: AppFont.bold,
          ),
        ),
      ),
    );
  }
}

class _MapDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final landPaint = Paint()
      ..color = const Color(0xFFBBDDBB).withValues(alpha: 0.7);
    final land = Path()
      ..moveTo(-10, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.45,
        size.width * 0.5,
        size.height * 0.65,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.85,
        size.width + 10,
        size.height * 0.6,
      )
      ..lineTo(size.width + 10, size.height + 10)
      ..lineTo(-10, size.height + 10)
      ..close();
    canvas.drawPath(land, landPaint);

    final roadPaint = Paint()
      ..color = const Color(0xFF9CC3E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final road = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.2,
        size.width * 0.65,
        size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.45,
        size.width,
        size.height * 0.28,
      );
    canvas.drawPath(road, roadPaint);

    final dashPaint = Paint()
      ..color = AppColors.neutral0.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final dashPath = Path()
      ..moveTo(size.width * 0.12, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.6,
        size.width * 0.7,
        size.height * 0.75,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.82,
        size.width,
        size.height * 0.7,
      );
    canvas.drawPath(_dashPath(dashPath), dashPaint);
  }

  Path _dashPath(Path source) {
    final dashed = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        const dashLen = 6.0;
        const gapLen = 6.0;
        final next = distance + (draw ? dashLen : gapLen);
        if (draw) {
          dashed.addPath(
            metric.extractPath(distance, next.clamp(0, metric.length)),
            Offset.zero,
          );
        }
        distance = next;
        draw = !draw;
      }
    }
    return dashed;
  }

  @override
  bool shouldRepaint(covariant _MapDecorationPainter oldDelegate) => false;
}
