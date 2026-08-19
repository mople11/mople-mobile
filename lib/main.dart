import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/data/api/api_client.dart';
import 'package:mople_mobile/data/api/kakao_auth.dart';
import 'package:mople_mobile/presentation/controllers/auth_controller.dart';
import 'package:mople_mobile/presentation/pages/app_boot_page.dart';
import 'package:mople_mobile/presentation/pages/auth/view/login_page.dart';

/// 화면 스택과 무관하게 살아 있는 내비게이터 참조.
///
/// 토큰 만료(401)는 어느 화면에서든 발생할 수 있고, 그때 로그인 화면으로 되돌려야
/// 한다. 특정 위젯에 콜백을 붙이면 `pushAndRemoveAll` 로 그 위젯이 사라지는 순간
/// 처리도 함께 죽으므로, 앱 루트에 키를 두고 여기서 전환한다.
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // 카카오 SDK 는 플랫폼 채널을 쓰므로 바인딩을 먼저 초기화한다.
  WidgetsFlutterBinding.ensureInitialized();
  // 초기화가 끝나기 전에 로그인 요청이 나가지 않도록 반드시 기다린다.
  await KakaoAuth.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // 앱이 살아 있는 동안 유지되는 단일 등록 지점.
    ApiClient.onUnauthorized = _handleUnauthorized;
  }

  @override
  void dispose() {
    ApiClient.onUnauthorized = null;
    super.dispose();
  }

  /// 저장된 토큰이 만료·폐기됐을 때 세션을 비우고 로그인 화면으로 되돌린다.
  void _handleUnauthorized() {
    ref.read(authProvider.notifier).clearSession();
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '어디가남',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: AppFont.family,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brandPrimary,
          primary: AppColors.brandPrimary,
          secondary: AppColors.brandSecondary,
          tertiary: AppColors.brandAccent,
          error: AppColors.danger,
          surface: AppColors.surfaceCard,
        ),
        scaffoldBackgroundColor: AppColors.surfacePage,
      ),
      debugShowCheckedModeBanner: false,
      home: const AppBootPage(),
    );
  }
}
