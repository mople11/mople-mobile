import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 홈 탭 셸(MainTabShell)의 현재 탭을 앱 전역에서 전환할 수 있게 하는 상태.
///
/// 다른 화면(예: MyPage)에서 `ref.read(mainTabProvider.notifier).switchTab('bookmark')`
/// 형태로 프롭 드릴링 없이 탭을 전환한다.
class MainTabNotifier extends Notifier<String> {
  @override
  String build() => 'home';

  void switchTab(String value) => state = value;
}

final mainTabProvider = NotifierProvider<MainTabNotifier, String>(
  MainTabNotifier.new,
);
