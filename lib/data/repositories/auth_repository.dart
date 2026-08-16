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

  /// 서버가 바디에 `refreshToken` 을 **필수**로 요구한다(빠지면 `COMMON_422`).
  Future<void> logout(String refreshToken) => apiClient.requestVoid(
    'POST',
    ApiEndpoints.logout,
    body: {'refreshToken': refreshToken},
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
