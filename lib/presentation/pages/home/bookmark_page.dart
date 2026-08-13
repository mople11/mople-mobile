import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/controllers/favorites_controller.dart';
import 'package:mople_mobile/presentation/pages/destination/course_page.dart';
import 'package:mople_mobile/presentation/pages/destination/detail_page.dart';

class BookmarkPage extends ConsumerStatefulWidget {
  const BookmarkPage({super.key});

  @override
  ConsumerState<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends ConsumerState<BookmarkPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);

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
      body: Builder(
        builder: (context) {
          if (_tab == 0) {
            final saved = favorites.favoriteDestinations;
            if (saved.isEmpty) {
              return const _EmptyState(
                message: '아직 찜한 여행지가 없어요.\n하트를 눌러 저장해보세요.',
              );
            }
            return Column(
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
                    onTap: () => context.push(DetailPage(destinationId: d.id)),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                ],
              ],
            );
          }

          if (!favorites.isFav(FavoritesNotifier.routeKey)) {
            return const _EmptyState(
              message: '아직 저장한 코스가 없어요.\n코스 화면에서 저장을 눌러보세요.',
            );
          }
          return CourseCard(
            title: EodiganamData.route.title,
            summary: EodiganamData.route.summary,
            stops: EodiganamData.route.steps.length,
            duration: '6시간',
            tags: const ['힐링', '자연'],
            image: EodiganamData.destinations[0].image,
            onTap: () => context.push(const CoursePage()),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
      child: Column(
        children: [
          const Icon(
            Icons.favorite_border_rounded,
            size: 40,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyle.body.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
