import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/font.dart';
import '../../constants/spacing.dart';
import '../../mock/eodiganam_data.dart';

/// 여러 개의 [RouteStep]을 순서대로 렌더링 — 코스/경로 상세 화면 전반에서 반복되는 목록 패턴.
class RouteStepList extends StatelessWidget {
  const RouteStepList({super.key, required this.steps});

  final List<RouteStepInfo> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          RouteStep(
            index: steps[i].index,
            title: steps[i].title,
            time: steps[i].time,
            duration: steps[i].duration,
            transport: steps[i].transport,
            subtitle: steps[i].subtitle,
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }
}

class RouteStep extends StatelessWidget {
  const RouteStep({
    super.key,
    required this.index,
    required this.title,
    required this.time,
    required this.duration,
    required this.transport,
    this.subtitle,
    this.isLast = false,
  });

  final int index;
  final String title;
  final String time;
  final String duration;
  final String transport;
  final String? subtitle;
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
                decoration: const BoxDecoration(
                  color: AppColors.brandPrimary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.textOnBrand,
                    fontWeight: AppFont.bold,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.borderSubtle),
                ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyle.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space2),
                      Text(time, style: AppTextStyle.label),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$duration · $transport',
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyle.small.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
