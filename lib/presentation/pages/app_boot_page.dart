import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/presentation/controllers/auth_controller.dart';
import 'package:mople_mobile/presentation/pages/app_start_page.dart';
import 'package:mople_mobile/presentation/pages/home/view/main_tab_shell.dart';

/// 앱의 첫 화면. 저장된 로그인 세션을 복원한 뒤 갈 곳을 정한다.
///
/// - 세션이 있으면 곧바로 [MainTabShell]
/// - 없으면 기존 시작 화면([AppStartPage])
///
/// 복원은 Keychain 접근이라 한 프레임 안에 끝나지 않으므로, 그동안 로고만 띄운다.
class AppBootPage extends ConsumerStatefulWidget {
  const AppBootPage({super.key});

  @override
  ConsumerState<AppBootPage> createState() => _AppBootPageState();
}

class _AppBootPageState extends ConsumerState<AppBootPage> {
  bool? _restored;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final restored = await ref.read(authProvider.notifier).restoreSession();
    if (!mounted) return;
    setState(() => _restored = restored);
  }

  @override
  Widget build(BuildContext context) {
    final restored = _restored;
    if (restored == null) {
      return const Scaffold(
        backgroundColor: AppColors.surfacePage,
        body: Center(
          child: Icon(
            Icons.explore_rounded,
            size: 52,
            color: AppColors.brandPrimary,
          ),
        ),
      );
    }
    return restored ? const MainTabShell() : const AppStartPage();
  }
}
