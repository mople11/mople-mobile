import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/controllers/main_tab_controller.dart';
import 'package:mople_mobile/presentation/pages/home/view/bookmark_page.dart';
import 'package:mople_mobile/presentation/pages/home/view/home_page.dart';
import 'package:mople_mobile/presentation/pages/home/view/search_page.dart';
import 'package:mople_mobile/presentation/pages/my/view/my_page.dart';

/// 홈 · 탐색 · 찜 · MY 4개 탭을 하나의 화면 스택에서 전환하는 셸.
class MainTabShell extends ConsumerWidget {
  const MainTabShell({super.key});

  static const _tabs = ['home', 'search', 'bookmark', 'my'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(mainTabProvider);
    final switchTab = ref.read(mainTabProvider.notifier).switchTab;
    final index = _tabs.indexOf(tab);

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: index,
          children: const [HomePage(), SearchPage(), BookmarkPage(), MyPage()],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        value: tab,
        onChanged: switchTab,
        items: const [
          AppBottomNavItem(value: 'home', label: '홈', icon: Icons.home_rounded),
          AppBottomNavItem(
            value: 'search',
            label: '탐색',
            icon: Icons.explore_rounded,
          ),
          AppBottomNavItem(
            value: 'bookmark',
            label: '찜',
            icon: Icons.favorite_rounded,
          ),
          AppBottomNavItem(
            value: 'my',
            label: 'MY',
            icon: Icons.person_rounded,
          ),
        ],
      ),
    );
  }
}
