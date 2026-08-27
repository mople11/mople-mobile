/// 빌드 시점에 주입하는 설정값.
///
/// 키를 소스에 하드코딩하지 않도록 `--dart-define` 으로 받는다.
///
/// ```bash
/// flutter run --dart-define=KAKAO_NATIVE_APP_KEY=발급받은_네이티브_앱_키
/// ```
///
/// 여러 값을 자주 쓰게 되면 `--dart-define-from-file=env.json` 으로 묶는 편이 낫다.
abstract final class AppConfig {
  /// 카카오 개발자 콘솔 > 앱 설정 > 앱 키 > **네이티브 앱 키**.
  ///
  /// JavaScript 키나 REST API 키가 아니다. 값이 없으면 카카오 로그인은
  /// 비활성 상태로 두고 안내만 띄운다(앱이 죽지는 않는다).
  static const kakaoNativeAppKey = String.fromEnvironment(
    'KAKAO_NATIVE_APP_KEY',
  );

  static bool get hasKakaoKey => kakaoNativeAppKey.isNotEmpty;
}
