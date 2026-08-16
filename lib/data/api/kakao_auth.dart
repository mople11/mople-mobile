import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:mople_mobile/core/config/app_config.dart';
import 'package:mople_mobile/data/models/models.dart';

/// 카카오 로그인으로 OAuth 액세스 토큰을 받아오는 얇은 래퍼.
///
/// 여기서 받은 토큰을 서버의 `POST /auth/login/social` 에 넘기면 우리 앱의
/// 세션(accessToken/refreshToken)으로 교환된다. 카카오 토큰 자체는 앱에 보관하지
/// 않는다 — 서버 세션만 [AuthTokenStore] 에 저장한다.
abstract final class KakaoAuth {
  /// [AppConfig.kakaoNativeAppKey] 가 있을 때만 SDK 를 초기화한다.
  /// 키가 없으면 조용히 넘어가고, 로그인 시도 시 안내 에러를 돌려준다.
  static void init() {
    if (!AppConfig.hasKakaoKey) {
      debugPrint('[Kakao] 네이티브 앱 키가 없어 카카오 로그인을 비활성화합니다.');
      return;
    }
    KakaoSdk.init(nativeAppKey: AppConfig.kakaoNativeAppKey);
  }

  /// 카카오톡 앱이 있으면 앱으로, 없으면 웹 계정 로그인으로 진행한다.
  ///
  /// 성공하면 카카오 액세스 토큰을, 실패하면 [ApiException] 을 던진다.
  /// 사용자가 로그인 창을 닫은 경우도 실패로 본다.
  static Future<String> obtainAccessToken() async {
    if (!AppConfig.hasKakaoKey) {
      throw const ApiException(
        ApiError(
          code: ApiErrorCode.oauthFailed,
          message: '카카오 로그인이 아직 설정되지 않았어요.',
        ),
      );
    }

    try {
      final token = await _login();
      return token.accessToken;
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('[Kakao] 로그인 실패: $e');
      throw ApiException(
        ApiError(
          code: ApiErrorCode.oauthFailed,
          message: _describe(e),
        ),
      );
    }
  }

  static Future<OAuthToken> _login() async {
    // 카카오톡이 깔려 있어도 실행이 막히는 경우(로그아웃 상태 등)가 있어
    // 실패하면 계정 로그인으로 한 번 더 시도한다.
    if (await isKakaoTalkInstalled()) {
      try {
        return await UserApi.instance.loginWithKakaoTalk();
      } catch (e) {
        debugPrint('[Kakao] 카카오톡 로그인 실패 → 계정 로그인으로 전환: $e');
      }
    }
    return UserApi.instance.loginWithKakaoAccount();
  }

  /// 로그아웃 시 카카오 세션도 함께 끊는다. 실패해도 앱 로그아웃은 진행한다.
  static Future<void> logout() async {
    if (!AppConfig.hasKakaoKey) return;
    try {
      await UserApi.instance.logout();
    } catch (e) {
      debugPrint('[Kakao] 카카오 로그아웃 실패(무시): $e');
    }
  }

  static String _describe(Object e) {
    if (e is PlatformException && e.code == 'CANCELED') {
      return '카카오 로그인을 취소했어요.';
    }
    if (e is KakaoAuthException) return e.errorDescription ?? '카카오 인증에 실패했어요.';
    if (e is KakaoClientException) return e.message ?? '카카오 로그인에 실패했어요.';
    return '카카오 로그인에 실패했어요.';
  }
}
