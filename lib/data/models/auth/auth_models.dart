import 'package:mople_mobile/data/models/common/json_utils.dart';

/// `POST /auth/login/social` 의 provider.
///
/// 서버 스키마(`ProviderEnum`)는 `google` 도 받지만, 제품 결정상 앱은 카카오만
/// 지원한다. 그래서 로그인 화면에도 카카오 버튼만 둔다.
enum SocialProvider {
  kakao('kakao');

  const SocialProvider(this.value);

  final String value;

  static SocialProvider? fromValue(String? value) {
    for (final item in values) {
      if (item.value == value) return item;
    }
    return null;
  }
}

/// `POST /auth/signup`
class SignupRequest {
  const SignupRequest({
    required this.id,
    required this.pw,
    required this.pwCheck,
    required this.nickname,
    required this.email,
    required this.verifyCode,
    required this.agreeTerms,
  });

  final String id;
  final String pw;
  final String pwCheck;
  final String nickname;
  final String email;
  final String verifyCode;
  final bool agreeTerms;

  Map<String, dynamic> toJson() => {
    'id': id,
    'pw': pw,
    'pwCheck': pwCheck,
    'nickname': nickname,
    'email': email,
    'verifyCode': verifyCode,
    'agreeTerms': agreeTerms,
  };
}

/// `POST /auth/signup` 의 `data`.
class SignupResult {
  const SignupResult({required this.userId, required this.accessToken});

  final String userId;
  final String accessToken;

  factory SignupResult.fromJson(Map<String, dynamic> json) => SignupResult(
    userId: asString(json['userId']),
    accessToken: asString(json['accessToken']),
  );
}

/// `POST /auth/login`
class LoginRequest {
  const LoginRequest({required this.id, required this.pw});

  final String id;
  final String pw;

  Map<String, dynamic> toJson() => {'id': id, 'pw': pw};
}

/// `POST /auth/login/social`
class SocialLoginRequest {
  const SocialLoginRequest({required this.provider, required this.oauthToken});

  final SocialProvider provider;
  final String oauthToken;

  Map<String, dynamic> toJson() => {
    'provider': provider.value,
    'oauthToken': oauthToken,
  };
}

/// 로그인/소셜 로그인 응답의 `data.user`.
class AuthUser {
  const AuthUser({required this.id, required this.nickname});

  final String id;
  final String nickname;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      AuthUser(id: asString(json['id']), nickname: asString(json['nickname']));

  Map<String, dynamic> toJson() => {'id': id, 'nickname': nickname};
}

/// 로그인/소셜 로그인 응답의 `data`.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AuthUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    accessToken: asString(json['accessToken']),
    refreshToken: asString(json['refreshToken']),
    user: AuthUser.fromJson(asMap(json['user'])),
  );

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'user': user.toJson(),
  };

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    AuthUser? user,
  }) => AuthSession(
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    user: user ?? this.user,
  );
}

/// 이메일 인증 용도.
///
/// 서버가 `/auth/email/**` 에서 `purpose` 를 필수로 요구한다(빠지면 `COMMON_422`).
/// 값 집합은 실제 서버 응답으로 확인했다 — 이 둘 외에는 "유효하지 않은 선택"으로 거절된다.
enum EmailPurpose {
  signup('signup'),
  passwordReset('password_reset');

  const EmailPurpose(this.value);

  final String value;
}

/// `POST /auth/email/verify-code`, `POST /auth/password/reset-request`
///
/// `purpose` 는 `/auth/email/verify-code` 에만 필요하고,
/// `/auth/password/reset-request` 는 없이도 동작하므로 선택 필드로 둔다.
class EmailRequest {
  const EmailRequest({required this.email, this.purpose});

  final String email;
  final EmailPurpose? purpose;

  Map<String, dynamic> toJson() =>
      compactJson({'email': email, 'purpose': purpose?.value});
}

/// `POST /auth/email/verify-confirm`
class EmailVerifyConfirmRequest {
  const EmailVerifyConfirmRequest({
    required this.email,
    required this.code,
    this.purpose = EmailPurpose.signup,
  });

  final String email;
  final String code;
  final EmailPurpose purpose;

  Map<String, dynamic> toJson() => {
    'email': email,
    'code': code,
    'purpose': purpose.value,
  };
}

/// `POST /auth/password/reset-confirm`
class PasswordResetConfirmRequest {
  const PasswordResetConfirmRequest({
    required this.email,
    required this.code,
    required this.newPw,
  });

  final String email;
  final String code;
  final String newPw;

  Map<String, dynamic> toJson() => {
    'email': email,
    'code': code,
    'newPw': newPw,
  };
}
