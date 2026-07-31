import 'package:flutter/material.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/home/bookmark_page.dart';
import 'package:mople_mobile/presentation/pages/home/home_page.dart';
import 'package:mople_mobile/presentation/pages/home/search_page.dart';
import 'package:mople_mobile/presentation/pages/my/my_page.dart';

/// 홈 · 탐색 · 찜 · MY 4개 탭을 하나의 화면 스택에서 전환하는 셸.
class MainTabShell extends StatefulWidget {
  const MainTabShell({super.key, this.initialTab = 'home'});

  final String initialTab;

  @override
  State<MainTabShell> createState() => _MainTabShellState();
}

class _MainTabShellState extends State<MainTabShell> {
  late String _tab = widget.initialTab;

  static const _tabs = ['home', 'search', 'bookmark', 'my'];

  void switchTab(String tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    final index = _tabs.indexOf(_tab);

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: index,
          children: [
            HomePage(onSwitchTab: switchTab),
            SearchPage(onSwitchTab: switchTab),
            BookmarkPage(onSwitchTab: switchTab),
            MyPage(onSwitchTab: switchTab),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        value: _tab,
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
