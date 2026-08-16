import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/my_page_controller.dart';
import 'package:mople_mobile/presentation/pages/destination/course_page.dart';
import 'package:mople_mobile/presentation/pages/destination/detail_page.dart';

/// 내 여행 — 찜한 여행지(`GET /users/me/likes`)와 저장한 코스(`GET /users/me/courses`).
class BookmarkPage extends ConsumerStatefulWidget {
  const BookmarkPage({super.key});

  @override
  ConsumerState<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends ConsumerState<BookmarkPage> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(myPageProvider.notifier);
      notifier.loadLikedPlaces();
      notifier.loadSavedCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final myPage = ref.watch(myPageProvider);

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
          ? AsyncView<Paged<LikedPlace>>(
              value: myPage.likedPlaces,
              loadingHeight: 220,
              onRetry: () =>
                  ref.read(myPageProvider.notifier).loadLikedPlaces(),
              isEmpty: (paged) => paged.isEmpty,
              emptyMessage: '아직 찜한 여행지가 없어요.\n하트를 눌러 저장해보세요.',
              builder: (paged) => Column(
                children: [
                  for (final place in paged.items) ...[
                    _SimpleRow(
                      icon: Icons.favorite_rounded,
                      title: place.name,
                      onTap: () => context.push(
                        DetailPage(destinationId: place.placeId),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                  ],
                ],
              ),
            )
          : AsyncView<Paged<SavedCourse>>(
              value: myPage.savedCourses,
              loadingHeight: 220,
              onRetry: () =>
                  ref.read(myPageProvider.notifier).loadSavedCourses(),
              isEmpty: (paged) => paged.isEmpty,
              emptyMessage: '아직 저장한 코스가 없어요.\n코스 화면에서 저장을 눌러보세요.',
              builder: (paged) => Column(
                children: [
                  for (final course in paged.items) ...[
                    _SimpleRow(
                      icon: Icons.route_rounded,
                      title: course.name,
                      onTap: () =>
                          context.push(CoursePage(courseId: course.courseId)),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                  ],
                ],
              ),
            ),
    );
  }
}

/// 서버가 이름과 id 만 내려주는 목록(찜/저장 코스)에 쓰는 한 줄 카드.
class _SimpleRow extends StatelessWidget {
  const _SimpleRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.brandPrimary),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Text(
                title,
                style: AppTextStyle.body.copyWith(fontWeight: AppFont.semibold),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
