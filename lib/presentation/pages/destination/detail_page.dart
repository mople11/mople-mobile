import 'package:flutter/material.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/destination/congestion_page.dart';
import 'package:mople_mobile/presentation/pages/destination/course_page.dart';
import 'package:mople_mobile/presentation/pages/destination/map_page.dart';
import 'package:mople_mobile/presentation/pages/destination/review_page.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _fav = false;

  @override
  Widget build(BuildContext context) {
    final d = EodiganamData.destinations.first;
    final others = EodiganamData.destinations.sublist(1, 4);

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 280,
                          width: double.infinity,
                          child: Image.network(d.image, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: AppSpacing.space2,
                          left: AppSpacing.space2,
                          right: AppSpacing.space2,
                          child: SafeArea(
                            bottom: false,
                            child: Row(
                              children: [
                                AppIconButton(
                                  icon: const Icon(Icons.chevron_left_rounded),
                                  semanticLabel: '뒤로',
                                  variant: AppIconButtonVariant.solid,
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                const Spacer(),
                                AppIconButton(
                                  icon: const Icon(Icons.share_rounded),
                                  semanticLabel: '공유',
                                  variant: AppIconButtonVariant.solid,
                                  onPressed: () {},
                                ),
                                const SizedBox(width: AppSpacing.space2),
                                AppIconButton(
                                  icon: Icon(
                                    Icons.favorite_rounded,
                                    color: _fav
                                        ? AppColors.brandAccent
                                        : AppColors.neutral700,
                                  ),
                                  semanticLabel: '찜',
                                  variant: AppIconButtonVariant.solid,
                                  onPressed: () => setState(() => _fav = !_fav),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: AppSpacing.space5,
                          bottom: AppSpacing.space4,
                          child: WeatherChip(
                            condition: weatherConditionFromKorean(
                              d.weatherLabel,
                            ),
                            temp: d.weatherTemp,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.space5,
                        AppSpacing.space4,
                        AppSpacing.space5,
                        AppSpacing.space2,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(d.title, style: AppTextStyle.h2),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${d.region} · ${d.duration}',
                                      style: AppTextStyle.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (d.badge != null)
                            AppBadge(
                              label: d.badge!,
                              tone: AppTone.orange,
                              variant: AppBadgeVariant.solid,
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppRating(
                            value: d.rating,
                            showValue: true,
                            count: d.reviewCount,
                          ),
                          const SizedBox(height: AppSpacing.space3),
                          Wrap(
                            spacing: AppSpacing.space2,
                            runSpacing: AppSpacing.space2,
                            children: [
                              for (final t in d.tags) AppTag(label: t),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          Text(
                            d.desc,
                            style: AppTextStyle.body.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (d.congestion != null) ...[
                      const SizedBox(height: AppSpacing.space5),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space5,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '실시간 혼잡도',
                              style: AppTextStyle.bodyLg.copyWith(
                                fontWeight: AppFont.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space3),
                            Material(
                              color: AppColors.surfaceCard,
                              borderRadius: AppRadius.radiusLg,
                              child: InkWell(
                                borderRadius: AppRadius.radiusLg,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CongestionPage(),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    AppSpacing.space4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadius.radiusLg,
                                    border: Border.all(
                                      color: AppColors.borderSubtle,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CongestionBadge(
                                            level: d.congestion!.level,
                                          ),
                                          const SizedBox(
                                            width: AppSpacing.space2,
                                          ),
                                          Expanded(
                                            child: Text(
                                              d.congestion!.hint,
                                              style: AppTextStyle.caption
                                                  .copyWith(
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.chevron_right_rounded,
                                            size: 16,
                                            color: AppColors.textTertiary,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.space3),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.local_parking_rounded,
                                            size: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '주차 ${d.congestion!.parking ? '가능' : '불가'}',
                                            style: AppTextStyle.caption
                                                .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontWeight: AppFont.semibold,
                                                ),
                                          ),
                                          const SizedBox(
                                            width: AppSpacing.space4,
                                          ),
                                          const Icon(
                                            Icons.access_time_rounded,
                                            size: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '대기 약 ${d.congestion!.wait}분',
                                            style: AppTextStyle.caption
                                                .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontWeight: AppFont.semibold,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.space5),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '위치',
                            style: AppTextStyle.bodyLg.copyWith(
                              fontWeight: AppFont.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space3),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MapPage(),
                              ),
                            ),
                            child: const MapPreviewCard(
                              height: 150,
                              pins: 1,
                              label: '지도에서 보기',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space5),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '리뷰 ${d.reviewCount}',
                                style: AppTextStyle.bodyLg.copyWith(
                                  fontWeight: AppFont.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ReviewPage(),
                                  ),
                                ),
                                child: Text(
                                  '전체보기',
                                  style: AppTextStyle.caption.copyWith(
                                    fontWeight: AppFont.semibold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.space3),
                          ReviewCard(review: EodiganamData.reviews.first),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space5),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space5,
                      ),
                      child: Text(
                        '비슷한 여행지',
                        style: AppTextStyle.bodyLg.copyWith(
                          fontWeight: AppFont.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    SizedBox(
                      height: 228,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space5,
                        ),
                        itemCount: others.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.space3),
                        itemBuilder: (context, i) {
                          final x = others[i];
                          return SizedBox(
                            width: 180,
                            child: DestinationCard(
                              image: x.image,
                              title: x.title,
                              region: x.region,
                              rating: x.rating,
                              reviewCount: x.reviewCount,
                              duration: x.duration,
                              badge: x.badge,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space5),
                  ],
                ),
              ),
            ),
            AppBottomActionBar(
              child: Row(
                children: [
                  AppButton(
                    label: '길찾기',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => const MapPage())),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: AppButton(
                      label: '코스에 추가',
                      width: double.infinity,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CoursePage()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
