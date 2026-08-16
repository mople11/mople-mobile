import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/api/auth_token_store.dart';
import 'package:mople_mobile/data/api/kakao_auth.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/data/repositories/repositories.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';

/// Auth 범위(`/auth/**`) 상태.
///
/// 로그인 세션은 앱 전역에서 참조하므로 [authProvider] 는 일반(=autoDispose 아닌)
/// `NotifierProvider` 로 등록해 앱 생명주기 동안 유지한다. 각 메서드는 요청 모델
/// 조립·검증까지 수행하고 [authRepository] 로 통신한다. 로그인/회원가입에 성공하면
/// [AuthTokenStore] 에 액세스 토큰을 채워 이후 요청의 `Authorization` 헤더에 쓴다.
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

  /// 앱 시작 시 저장된 세션을 상태로 올린다. 복원됐으면 true.
  ///
  /// 서버에 다시 물어보지 않고 저장된 토큰을 그대로 신뢰한다. 만료됐다면 이후
  /// 첫 인증 요청이 401 로 떨어지므로 그때 [clearSession] 으로 정리하면 된다.
  Future<bool> restoreSession() async {
    final session = await AuthTokenStore.restore();
    if (session == null) return false;
    state = state.copyWith(session: AsyncData(session));
    return true;
  }

  /// 로그인·회원가입 성공 응답을 세션으로 확정하고 기기에 저장한다.
  Future<void> _persist(AuthSession session) => AuthTokenStore.save(session);

  // ── 아이디 중복 확인 ───────────────────────────────────────
  Future<void> checkId(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(clearIdAvailable: true);
      return;
    }
    state = state.copyWith(idAvailable: const AsyncLoading());
    final result = await guardAsync(() => authRepository.checkId(trimmed));
    state = state.copyWith(idAvailable: result);
  }

  void resetIdCheck() => state = state.copyWith(clearIdAvailable: true);

  // ── 이메일 인증 ───────────────────────────────────────────
  Future<bool> sendEmailCode(
    String email, {
    EmailPurpose purpose = EmailPurpose.signup,
  }) async {
    final request = EmailRequest(email: email.trim(), purpose: purpose);
    state = state.copyWith(emailCodeSend: const AsyncLoading());
    final result = await guardAsync(
      () => authRepository.sendEmailCode(request),
    );
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
    EmailPurpose purpose = EmailPurpose.signup,
  }) async {
    final request = EmailVerifyConfirmRequest(
      email: email.trim(),
      code: code.trim(),
      purpose: purpose,
    );
    state = state.copyWith(emailCodeConfirm: const AsyncLoading());
    final result = await guardAsync(
      () => authRepository.confirmEmailCode(request),
    );
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
    final result = await guardAsync(() => authRepository.signup(request));
    final signup = result.value;
    if (signup != null) {
      // 회원가입 응답에는 accessToken 만 있고 refreshToken·user 가 없다.
      // 가입 요청 값으로 사용자 정보를 채우고, refreshToken 은 비워 둔다.
      // (비어 있으면 [logout] 이 서버 호출 없이 로컬 세션만 정리한다.)
      await _persist(
        AuthSession(
          accessToken: signup.accessToken,
          refreshToken: '',
          user: AuthUser(id: request.id, nickname: request.nickname),
        ),
      );
      state = state.copyWith(session: AsyncData(AuthTokenStore.session!));
    }
    state = state.copyWith(signup: result);
  }

  // ── 로그인 ────────────────────────────────────────────────
  Future<void> login({required String id, required String pw}) async {
    final request = LoginRequest(id: id.trim(), pw: pw);
    state = state.copyWith(session: const AsyncLoading());
    final result = await guardAsync(() => authRepository.login(request));
    final session = result.value;
    // 이후 요청이 토큰 없이 나가지 않도록 상태보다 저장을 먼저 끝낸다.
    if (session != null) await _persist(session);
    state = state.copyWith(session: result);
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
    final result = await guardAsync(
      () => authRepository.loginWithSocial(request),
    );
    final session = result.value;
    if (session != null) await _persist(session);
    state = state.copyWith(session: result);
  }

  /// 서버 로그아웃은 `refreshToken` 을 요구한다. 토큰이 없으면(이미 만료·미로그인)
  /// 굳이 호출하지 않고 로컬 세션만 정리한다.
  /// 로컬 세션을 **먼저** 비워 화면이 즉시 로그아웃 상태가 되게 한다.
  ///
  /// 서버 로그아웃은 성공하든 실패하든 사용자가 기다릴 이유가 없다(토큰은 이미
  /// 기기에서 지워졌다). 응답을 기다리면 최대 10초간 화면이 멈춘 것처럼 보인다.
  Future<void> logout() async {
    final refreshToken = AuthTokenStore.refreshToken;
    await clearSession();
    if (refreshToken == null || refreshToken.isEmpty) return;
    unawaited(guardAsync(() => authRepository.logout(refreshToken)));
  }

  // ── 비밀번호 재설정 ────────────────────────────────────────
  Future<bool> requestPasswordReset(String email) async {
    final request = EmailRequest(email: email.trim());
    state = state.copyWith(passwordResetRequest: const AsyncLoading());
    final result = await guardAsync(
      () => authRepository.requestPasswordReset(request),
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
      () => authRepository.confirmPasswordReset(request),
    );
    final ok = !result.hasError;
    state = state.copyWith(
      passwordResetConfirm: result,
      passwordChanged: ok ? true : state.passwordChanged,
    );
    return ok;
  }

  /// 로그아웃·토큰 만료 시 인증 상태와 기기에 저장된 세션을 모두 비운다.
  ///
  /// 카카오 세션 정리는 네트워크 호출이라 기다리지 않는다. Keychain 삭제만
  /// 확실히 끝낸 뒤 상태를 비워야 다음 요청에 옛 토큰이 실리지 않는다.
  Future<void> clearSession() async {
    unawaited(KakaoAuth.logout());
    await AuthTokenStore.clear();
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
