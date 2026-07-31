import 'package:flutter/material.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/destination/detail_page.dart';
import 'package:mople_mobile/presentation/pages/destination/map_page.dart';

class CongestionPage extends StatefulWidget {
  const CongestionPage({super.key});

  @override
  State<CongestionPage> createState() => _CongestionPageState();
}

class _CongestionPageState extends State<CongestionPage> {
  bool _alertOn = false;
  static const _hourLabels = ['9시', '12시', '15시', '18시', '21시', '24시'];

  @override
  Widget build(BuildContext context) {
    final d = EodiganamData.destinations.first;
    final c = d.congestion!;
    final alternatives = EodiganamData.destinations
        .where((x) => x.id != d.id && x.congestion?.level != '혼잡')
        .take(2)
        .toList();

    return AppDetailScaffold(
      title: '관광지 혼잡도',
      onBack: () => Navigator.of(context).pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.space5),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              border: Border.all(color: AppColors.borderSubtle),
              borderRadius: AppRadius.radiusLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.title,
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: AppFont.semibold,
                  ),
                ),
                const SizedBox(height: AppSpacing.space2),
                Row(
                  children: [
                    CongestionBadge(level: c.level),
                    const SizedBox(width: AppSpacing.space2),
                    Expanded(
                      child: Text(
                        c.hint,
                        style: AppTextStyle.caption.copyWith(
                          fontWeight: AppFont.semibold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space5),
                SizedBox(
                  height: 90,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < c.hourly.length; i++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: i == c.hourly.length - 1
                                  ? 0
                                  : AppSpacing.space2,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: FractionallySizedBox(
                                      heightFactor: (c.hourly[i] / 100).clamp(
                                        0.02,
                                        1.0,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: c.hourly[i] >= 80
                                              ? AppColors.danger
                                              : c.hourly[i] >= 50
                                              ? AppColors.warning
                                              : AppColors.success,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _hourLabels[i],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textTertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.local_parking_rounded,
                  label: '주차 ${c.parking ? '가능' : '불가'}',
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: _InfoTile(
                  icon: Icons.access_time_rounded,
                  label: '예상 대기 ${c.wait}분',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space3,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceSunken,
              borderRadius: AppRadius.radiusMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '혼잡도 알림 받기',
                  style: AppTextStyle.caption.copyWith(
                    fontWeight: AppFont.semibold,
                  ),
                ),
                Switch(
                  value: _alertOn,
                  onChanged: (v) => setState(() => _alertOn = v),
                  activeTrackColor: AppColors.brandPrimary,
                ),
              ],
            ),
          ),
          if (alternatives.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space5),
            Text(
              '대안 장소 추천',
              style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
            ),
            const SizedBox(height: AppSpacing.space3),
            for (final alt in alternatives) ...[
              CourseCard(
                title: alt.title,
                summary: alt.region,
                stops: 1,
                duration: alt.duration,
                tags: alt.tags,
                image: alt.image,
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const DetailPage())),
              ),
              const SizedBox(height: AppSpacing.space3),
            ],
          ],
        ],
      ),
      bottomBar: AppBottomActionBar(
        child: AppButton(
          label: '경로 찾기',
          width: double.infinity,
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const MapPage())),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: AppRadius.radiusMd,
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.textBrand),
          const SizedBox(height: AppSpacing.space2),
          Text(
            label,
            style: AppTextStyle.caption.copyWith(fontWeight: AppFont.bold),
          ),
        ],
      ),
    );
  }
}
