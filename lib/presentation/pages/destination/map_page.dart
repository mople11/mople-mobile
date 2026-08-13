import 'package:flutter/material.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/shadow.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/destination/course_page.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final route = EodiganamData.route;

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: MapPreviewCard(
              height: null,
              pins: 4,
              borderRadius: BorderRadius.zero,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space2,
                ),
                child: Row(
                  children: [
                    AppIconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      semanticLabel: '뒤로',
                      variant: AppIconButtonVariant.solid,
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    AppIconButton(
                      icon: const Icon(Icons.layers_rounded),
                      semanticLabel: '레이어',
                      variant: AppIconButtonVariant.solid,
                      onPressed: () => AppToast.show(
                        context,
                        title: '지도 레이어',
                        message: '위성/교통 레이어 전환은 준비 중이에요.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.space4,
            right: AppSpacing.space4,
            top: 96,
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space5,
                  vertical: AppSpacing.space3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: AppRadius.radiusPill,
                  boxShadow: AppShadow.md,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.directions_car_rounded,
                      size: 16,
                      color: AppColors.textBrand,
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Expanded(
                      child: Text(
                        '${route.steps.first.title} → ${route.steps.last.title}',
                        style: AppTextStyle.caption.copyWith(
                          fontWeight: AppFont.semibold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      route.distance.replaceAll('약 ', ''),
                      style: AppTextStyle.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: AppFont.semibold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.48,
              ),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space5,
                AppSpacing.space4,
                AppSpacing.space5,
                AppSpacing.space6,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
                boxShadow: AppShadow.lg,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(
                          bottom: AppSpacing.space4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.neutral300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(route.title, style: AppTextStyle.title),
                        ),
                        Text(
                          '${route.distance} · 6시간',
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: AppFont.semibold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    RouteStepList(steps: route.steps),
                    const SizedBox(height: AppSpacing.space2),
                    AppButton(
                      label: '코스 상세로',
                      width: double.infinity,
                      onPressed: () => context.push(const CoursePage()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
