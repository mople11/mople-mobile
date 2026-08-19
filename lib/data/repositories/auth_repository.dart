import 'package:mople_mobile/data/api/api_client.dart';
import 'package:mople_mobile/data/api/api_endpoints.dart';
import 'package:mople_mobile/data/models/models.dart';

/// `/auth/**` 연동.
class AuthRepository {
  AuthRepository._();

  static final AuthRepository instance = AuthRepository._();

  Future<bool> checkId(String id) => apiClient.requestObject(
    'GET',
    ApiEndpoints.signupCheckId,
    query: {'id': id},
    parse: (data) => FlagResult.fromJson(data, 'available').value,
  );

  Future<void> sendEmailCode(EmailRequest request) => apiClient.requestVoid(
    'POST',
    ApiEndpoints.emailVerifyCode,
    body: request.toJson(),
  );

  Future<void> confirmEmailCode(EmailVerifyConfirmRequest request) =>
      apiClient.requestVoid(
        'POST',
        ApiEndpoints.emailVerifyConfirm,
        body: request.toJson(),
      );

  Future<SignupResult> signup(SignupRequest request) => apiClient
      .requestObject(
        'POST',
        ApiEndpoints.signup,
        body: request.toJson(),
        parse: SignupResult.fromJson,
      );

  Future<AuthSession> login(LoginRequest request) => apiClient.requestObject(
    'POST',
    ApiEndpoints.login,
    body: request.toJson(),
    parse: AuthSession.fromJson,
  );

  Future<AuthSession> loginWithSocial(SocialLoginRequest request) =>
      apiClient.requestObject(
        'POST',
        ApiEndpoints.socialLogin,
        body: request.toJson(),
        parse: AuthSession.fromJson,
      );

  /// 서버가 바디에 `refreshToken` 을, 헤더에 액세스 토큰을 **둘 다** 요구한다.
  /// (바디가 빠지면 `COMMON_422`, 헤더가 빠지면 `AUTH_401`)
  ///
  /// 로그아웃은 화면을 즉시 전환하려고 로컬 세션을 먼저 비운 뒤에 호출한다.
  /// 그 시점엔 인터셉터가 붙일 토큰이 이미 없으므로, 호출부가 들고 있던
  /// [accessToken] 을 여기서 헤더에 직접 싣는다.
  Future<void> logout(String refreshToken, {String? accessToken}) =>
      apiClient.requestVoid(
        'POST',
        ApiEndpoints.logout,
        body: {'refreshToken': refreshToken},
        headers: accessToken == null || accessToken.isEmpty
            ? null
            : {'Authorization': 'Bearer $accessToken'},
      );

  Future<void> requestPasswordReset(EmailRequest request) =>
      apiClient.requestVoid(
        'POST',
        ApiEndpoints.passwordResetRequest,
        body: request.toJson(),
      );

  Future<void> confirmPasswordReset(PasswordResetConfirmRequest request) =>
      apiClient.requestVoid(
        'POST',
        ApiEndpoints.passwordResetConfirm,
        body: request.toJson(),
      );
}

/// 컨트롤러에서 쓰는 짧은 별칭.
AuthRepository get authRepository => AuthRepository.instance;
