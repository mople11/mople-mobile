import 'package:flutter/material.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/destination/course_page.dart';
import 'package:mople_mobile/presentation/pages/destination/detail_page.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key, required this.onSwitchTab});

  final ValueChanged<String> onSwitchTab;

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final saved = EodiganamData.destinations.take(3).toList();

    return AppDetailScaffold(
      title: '내 여행',
      subHeader: Container(
        color: AppColors.surfaceCard,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space5),
        alignment: Alignment.centerLeft,
        child: AppTabs(
          items: const ['찜한 여행지', '저장한 코스'],
          selectedIndex: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
      ),
      body: _tab == 0
          ? Column(
              children: [
                for (final d in saved) ...[
                  DestinationCard(
                    image: d.image,
                    title: d.title,
                    region: d.region,
                    rating: d.rating,
                    reviewCount: d.reviewCount,
                    duration: d.duration,
                    badge: d.badge,
                    weather: (
                      condition: weatherConditionFromKorean(d.weatherLabel),
                      temp: d.weatherTemp,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DetailPage()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                ],
              ],
            )
          : Column(
              children: [
                CourseCard(
                  title: '순천 힐링 하루 코스',
                  summary: '맑은 날씨에 딱 맞는 자연 코스',
                  stops: 4,
                  duration: '6시간',
                  tags: const ['힐링', '자연'],
                  image: EodiganamData.destinations[0].image,
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const CoursePage())),
                ),
                const SizedBox(height: AppSpacing.space3),
                CourseCard(
                  title: '여수 로맨틱 야경 코스',
                  summary: '연인과 함께하는 밤바다 드라이브',
                  stops: 3,
                  duration: '4시간',
                  tags: const ['야경', '로맨틱'],
                  image: EodiganamData.destinations[1].image,
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const CoursePage())),
                ),
              ],
            ),
    );
  }
}
