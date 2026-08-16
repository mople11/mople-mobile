import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/shadow.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/traffic_controller.dart';
import 'package:mople_mobile/presentation/pages/destination/course_page.dart';

/// 동선 지도.
///
/// 지도 자체는 아직 목업이고, 출발/도착 좌표가 넘어오면 상단 배너에
/// 실시간 교통 정보(`GET /traffic/congestion`)를 띄운다.
class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key, this.origin, this.destination});

  final GeoPoint? origin;
  final GeoPoint? destination;

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  @override
  void initState() {
    super.initState();
    final to = widget.destination;
    if (to == null) return;
    // 출발지는 위치 권한이 없으면 알 수 없으므로, 홈/날씨와 같은 기준점을 쓴다.
    // 여기서 origin 이 없다고 건너뛰면 교통 정보가 영영 로드되지 않는다.
    final from =
        widget.origin ??
        GeoPoint(
          lat: LocationQuery.fallback.lat,
          lng: LocationQuery.fallback.lng,
        );
    Future.microtask(() {
      final notifier = ref.read(trafficProvider.notifier);
      notifier.setRoute(from: from, to: to);
      notifier.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final route = EodiganamData.route;
    final traffic = ref.watch(trafficProvider);

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
                        // 교통 정보를 받아왔으면 구간 상태를, 아니면 코스 요약을 보여준다.
                        traffic.segments.isEmpty
                            ? '${route.steps.first.title} → ${route.steps.last.title}'
                            : traffic.segments
                                  .map((s) => s.section)
                                  .join(' · '),
                        style: AppTextStyle.caption.copyWith(
                          fontWeight: AppFont.semibold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      traffic.etaMin == null
                          ? route.distance.replaceAll('약 ', '')
                          : '${traffic.etaMin}분',
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
