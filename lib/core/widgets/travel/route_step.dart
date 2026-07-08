import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/spacing.dart';

class RouteStep extends StatelessWidget {
  const RouteStep({
    super.key,
    required this.index,
    required this.title,
    required this.time,
    required this.duration,
    required this.transport,
    this.isLast = false,
  });

  final int index;
  final String title;
  final String time;
  final String duration;
  final String transport;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.brandPrimary, shape: BoxShape.circle),
                child: Text(
                  '$index',
                  style: AppTextStyle.caption.copyWith(color: AppColors.textOnBrand, fontWeight: AppFont.bold),
                ),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: AppColors.borderSubtle)),
            ],
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.space5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: AppTextStyle.title),
                      Text(time, style: AppTextStyle.label),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$duration · $transport',
                    style: AppTextStyle.caption.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
