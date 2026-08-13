import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/mock/mock_api.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';

/// Auth 범위(`/auth/**`) 상태.
///
/// 로그인 세션은 앱 전역에서 참조하므로 [authProvider] 는 일반(=autoDispose 아닌)
/// `NotifierProvider` 로 등록해 앱 생명주기 동안 유지한다. 각 메서드는 요청 모델
/// 조립·검증까지 수행하고, 통신 자리에는 아직 더미 응답([mockApi])이 들어가 있다.
/// 연동 단계에서 그 한 줄만 repository 호출로 바꾼다.
class AuthState {
  const AuthState({
    this.session,
    this.signup,
    this.idAvailable,
    this.emailCodeSend,
    this.emailCodeConfirm,
    this.emailCodeSent = false,
    this.emailVerified = false,
    this.passwordResetRequest,
    this.passwordResetConfirm,
    this.passwordCodeSent = false,
    this.passwordChanged = false,
    this.logoutAction,
  });

  /// `POST /auth/login`, `POST /auth/login/social`
  final AsyncValue<AuthSession>? session;

  /// `POST /auth/signup`
  final AsyncValue<SignupResult>? signup;

  /// `GET /auth/signup/check-id` — 값이 없으면 아직 확인 전.
  final AsyncValue<bool>? idAvailable;

  /// `POST /auth/email/verify-code` → `POST /auth/email/verify-confirm`
  final AsyncValue<void>? emailCodeSend;
  final AsyncValue<void>? emailCodeConfirm;
  final bool emailCodeSent;
  final bool emailVerified;

  /// `POST /auth/password/reset-request` → `POST /auth/password/reset-confirm`
  final AsyncValue<void>? passwordResetRequest;
  final AsyncValue<void>? passwordResetConfirm;
  final bool passwordCodeSent;
  final bool passwordChanged;

  /// `POST /auth/logout`
  final AsyncValue<void>? logoutAction;

  bool get isLoggedIn => session?.value != null;

  AuthUser? get currentUser => session?.value?.user;

  String? get accessToken => session?.value?.accessToken;

  AuthState copyWith({
    AsyncValue<AuthSession>? session,
    AsyncValue<SignupResult>? signup,
    AsyncValue<bool>? idAvailable,
    bool clearIdAvailable = false,
    AsyncValue<void>? emailCodeSend,
    AsyncValue<void>? emailCodeConfirm,
    bool? emailCodeSent,
    bool? emailVerified,
    AsyncValue<void>? passwordResetRequest,
    AsyncValue<void>? passwordResetConfirm,
    bool? passwordCodeSent,
    bool? passwordChanged,
    AsyncValue<void>? logoutAction,
  }) => AuthState(
    session: session ?? this.session,
    signup: signup ?? this.signup,
    idAvailable: clearIdAvailable ? null : (idAvailable ?? this.idAvailable),
    emailCodeSend: emailCodeSend ?? this.emailCodeSend,
    emailCodeConfirm: emailCodeConfirm ?? this.emailCodeConfirm,
    emailCodeSent: emailCodeSent ?? this.emailCodeSent,
    emailVerified: emailVerified ?? this.emailVerified,
    passwordResetRequest: passwordResetRequest ?? this.passwordResetRequest,
    passwordResetConfirm: passwordResetConfirm ?? this.passwordResetConfirm,
    passwordCodeSent: passwordCodeSent ?? this.passwordCodeSent,
    passwordChanged: passwordChanged ?? this.passwordChanged,
    logoutAction: logoutAction ?? this.logoutAction,
  );
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  // ── 아이디 중복 확인 ───────────────────────────────────────
  Future<void> checkId(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(clearIdAvailable: true);
      return;
    }
    state = state.copyWith(idAvailable: const AsyncLoading());
    state = state.copyWith(
      idAvailable: await guardAsync(() => mockApi.checkId(trimmed)),
    );
  }

  void resetIdCheck() => state = state.copyWith(clearIdAvailable: true);

  // ── 이메일 인증 ───────────────────────────────────────────
  Future<bool> sendEmailCode(String email) async {
    final request = EmailRequest(email: email.trim());
    state = state.copyWith(emailCodeSend: const AsyncLoading());
    final result = await guardAsync(() => mockApi.sendEmailCode(request));
    final ok = !result.hasError;
    state = state.copyWith(
      emailCodeSend: result,
      emailCodeSent: ok ? true : state.emailCodeSent,
    );
    return ok;
  }

  Future<bool> confirmEmailCode({
    required String email,
    required String code,
  }) async {
    final request = EmailVerifyConfirmRequest(
      email: email.trim(),
      code: code.trim(),
    );
    state = state.copyWith(emailCodeConfirm: const AsyncLoading());
    final result = await guardAsync(() => mockApi.confirmEmailCode(request));
    final ok = !result.hasError;
    state = state.copyWith(
      emailCodeConfirm: result,
      emailVerified: ok ? true : state.emailVerified,
    );
    return ok;
  }

  // ── 회원가입 ──────────────────────────────────────────────
  Future<void> submitSignup(SignupRequest request) async {
    state = state.copyWith(signup: const AsyncLoading());
    state = state.copyWith(
      signup: await guardAsync(() => mockApi.signup(request)),
    );
  }

  // ── 로그인 ────────────────────────────────────────────────
  Future<void> login({required String id, required String pw}) async {
    final request = LoginRequest(id: id.trim(), pw: pw);
    state = state.copyWith(session: const AsyncLoading());
    state = state.copyWith(
      session: await guardAsync(() => mockApi.login(request)),
    );
  }

  Future<void> loginWithSocial({
    required SocialProvider provider,
    required String oauthToken,
  }) async {
    final request = SocialLoginRequest(
      provider: provider,
      oauthToken: oauthToken,
    );
    state = state.copyWith(session: const AsyncLoading());
    state = state.copyWith(
      session: await guardAsync(() => mockApi.loginWithSocial(request)),
    );
  }

  Future<void> logout() async {
    state = state.copyWith(logoutAction: const AsyncLoading());
    state = state.copyWith(logoutAction: await guardAsync(mockApi.logout));
    clearSession();
  }

  // ── 비밀번호 재설정 ────────────────────────────────────────
  Future<bool> requestPasswordReset(String email) async {
    final request = EmailRequest(email: email.trim());
    state = state.copyWith(passwordResetRequest: const AsyncLoading());
    final result = await guardAsync(
      () => mockApi.requestPasswordReset(request),
    );
    final ok = !result.hasError;
    state = state.copyWith(
      passwordResetRequest: result,
      passwordCodeSent: ok ? true : state.passwordCodeSent,
    );
    return ok;
  }

  Future<bool> confirmPasswordReset({
    required String email,
    required String code,
    required String newPw,
  }) async {
    final request = PasswordResetConfirmRequest(
      email: email.trim(),
      code: code.trim(),
      newPw: newPw,
    );
    state = state.copyWith(passwordResetConfirm: const AsyncLoading());
    final result = await guardAsync(
      () => mockApi.confirmPasswordReset(request),
    );
    final ok = !result.hasError;
    state = state.copyWith(
      passwordResetConfirm: result,
      passwordChanged: ok ? true : state.passwordChanged,
    );
    return ok;
  }

  /// 로그아웃·토큰 만료 시 인증 관련 상태를 모두 비운다.
  void clearSession() {
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
