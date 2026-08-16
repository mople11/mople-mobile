import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mople_mobile/data/models/models.dart';

/// 로그인 세션을 기기에 안전하게 보관한다(iOS Keychain / Android Keystore).
///
/// [ApiClient] 의 인터셉터는 매 요청마다 동기적으로 토큰을 읽어야 하는데 보안
/// 저장소는 비동기라, **메모리 캐시를 정본처럼 쓰고 저장소에는 write-through** 한다.
/// 앱 시작 시 [restore] 로 캐시를 채운 뒤에야 인증이 필요한 요청을 보낼 수 있다.
abstract final class AuthTokenStore {
  /// Android 는 v11 부터 암호화가 기본이라 별도 옵션이 필요 없다.
  /// iOS 는 기기 첫 잠금해제 이후에만 읽히도록 제한한다(백그라운드 갱신 대비).
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _sessionKey = 'auth_session';

  static AuthSession? _session;

  /// 인터셉터가 헤더에 실을 액세스 토큰.
  static String? get accessToken => _session?.accessToken;

  /// 로그아웃 요청 바디에 필요한 리프레시 토큰.
  static String? get refreshToken => _session?.refreshToken;

  static AuthSession? get session => _session;

  static bool get hasSession => _session != null;

  /// 로그인·회원가입 성공 시 호출. 메모리와 저장소에 함께 기록한다.
  static Future<void> save(AuthSession session) async {
    _session = session;
    try {
      await _storage.write(
        key: _sessionKey,
        value: jsonEncode(session.toJson()),
      );
    } catch (e) {
      // 저장에 실패해도 이번 세션은 메모리로 계속 쓸 수 있으므로 앱을 멈추지 않는다.
      debugPrint('[Auth] 세션 저장 실패: $e');
    }
  }

  /// 앱 시작 시 1회 호출해 저장된 세션을 메모리로 올린다.
  /// 복원된 세션이 있으면 반환한다.
  static Future<AuthSession?> restore() async {
    try {
      final raw = await _storage.read(key: _sessionKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final session = AuthSession.fromJson(asMap(decoded));
      // 토큰이 비어 있으면 쓸 수 없는 세션이라 지운다.
      if (session.accessToken.isEmpty) {
        await clear();
        return null;
      }
      _session = session;
      return session;
    } catch (e) {
      debugPrint('[Auth] 세션 복원 실패: $e');
      await clear();
      return null;
    }
  }

  /// 로그아웃·토큰 만료 시 메모리와 저장소를 모두 비운다.
  static Future<void> clear() async {
    _session = null;
    try {
      await _storage.delete(key: _sessionKey);
    } catch (e) {
      debugPrint('[Auth] 세션 삭제 실패: $e');
    }
  }
}
