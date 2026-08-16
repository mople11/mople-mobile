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

  /// "로그아웃이 아직 끝나지 않았다"는 표시.
  ///
  /// 세션 삭제가 실패하면 저장소에 세션이 그대로 남는다. 메모리 플래그만으로는
  /// 앱을 껐다 켜는 순간 사라져 [restore] 가 그 세션을 되살리므로, 삭제를
  /// **시도하기 전에** 이 표시를 먼저 남기고 삭제가 확인된 뒤에만 거둔다.
  static const _logoutMarkerKey = 'auth_logged_out';

  static AuthSession? _session;

  /// 이번 프로세스에서 삭제가 실패한 적이 있으면 true.
  /// 저장소 표시([_logoutMarkerKey])까지 실패한 최악의 경우를 대비한 2중 방어다.
  static bool _deleteFailed = false;

  /// 인터셉터가 헤더에 실을 액세스 토큰.
  static String? get accessToken => _session?.accessToken;

  /// 로그아웃 요청 바디에 필요한 리프레시 토큰.
  static String? get refreshToken => _session?.refreshToken;

  static AuthSession? get session => _session;

  static bool get hasSession => _session != null;

  /// 로그인·회원가입 성공 시 호출. 메모리와 저장소에 함께 기록한다.
  static Future<void> save(AuthSession session) async {
    _session = session;
    _deleteFailed = false;
    try {
      await _storage.write(
        key: _sessionKey,
        value: jsonEncode(session.toJson()),
      );
      // 새로 로그인했으므로 이전 로그아웃 표시는 더 이상 유효하지 않다.
      await _storage.delete(key: _logoutMarkerKey);
    } catch (e) {
      // 저장에 실패해도 이번 세션은 메모리로 계속 쓸 수 있으므로 앱을 멈추지 않는다.
      debugPrint('[Auth] 세션 저장 실패: $e');
    }
  }

  /// 앱 시작 시 1회 호출해 저장된 세션을 메모리로 올린다.
  /// 복원된 세션이 있으면 반환한다.
  static Future<AuthSession?> restore() async {
    // 삭제에 실패한 세션이 저장소에 남아 있을 수 있다. 되살리면 로그아웃한
    // 계정으로 다시 로그인되므로 복원하지 않는다.
    if (_deleteFailed) {
      debugPrint('[Auth] 이전 삭제 실패로 세션 복원을 건너뜁니다.');
      return null;
    }
    try {
      // 이전 실행에서 로그아웃이 끝나지 않았다면(삭제 실패 후 앱 종료) 세션이
      // 남아 있을 수 있다. 되살리지 않고 삭제를 다시 시도한다.
      final marker = await _storage.read(key: _logoutMarkerKey);
      if (marker != null && marker.isNotEmpty) {
        debugPrint('[Auth] 완료되지 않은 로그아웃이 있어 세션을 복원하지 않습니다.');
        await _clearQuietly();
        return null;
      }
      final raw = await _storage.read(key: _sessionKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final session = AuthSession.fromJson(asMap(decoded));
      // 토큰이 비어 있으면 쓸 수 없는 세션이라 지운다.
      if (session.accessToken.isEmpty) {
        await _clearQuietly();
        return null;
      }
      _session = session;
      return session;
    } catch (e) {
      debugPrint('[Auth] 세션 복원 실패: $e');
      await _clearQuietly();
      return null;
    }
  }

  /// 로그아웃·토큰 만료 시 메모리와 저장소를 모두 비운다.
  ///
  /// 삭제에 실패하면 **예외를 그대로 올린다.** 조용히 넘어가면 호출부가 성공으로
  /// 오해한다. 다만 예외를 무시하고 진행하더라도 [_logoutMarkerKey] 표시와
  /// [_deleteFailed] 가 남아 [restore] 가 그 세션을 되살리지는 않는다.
  static Future<void> clear() async {
    _session = null;
    // 삭제보다 먼저 표시를 남긴다. 삭제가 실패한 채 앱이 종료돼도 다음 실행에서
    // 복원을 막을 수 있는 근거는 이 표시뿐이다.
    try {
      await _storage.write(key: _logoutMarkerKey, value: '1');
    } catch (e) {
      debugPrint('[Auth] 로그아웃 표시 기록 실패: $e');
    }
    try {
      await _storage.delete(key: _sessionKey);
      _deleteFailed = false;
    } catch (e) {
      debugPrint('[Auth] 세션 삭제 실패: $e');
      // 저장소에 남아 있을 수 있으므로 이번 프로세스에서도 복원을 금지한다.
      _deleteFailed = true;
      rethrow;
    }
    // 삭제가 확인된 뒤에만 표시를 거둔다. 여기서 실패해 표시가 남더라도
    // 다음 로그인의 [save] 가 지우므로 사용자를 가두지 않는다.
    try {
      await _storage.delete(key: _logoutMarkerKey);
    } catch (e) {
      debugPrint('[Auth] 로그아웃 표시 제거 실패: $e');
    }
  }

  /// 복원 경로 전용 삭제. 어차피 복원하지 않는 자리라 예외를 올리지 않는다.
  /// 표시와 [_deleteFailed] 는 [clear] 가 남기므로 안전성은 그대로다.
  static Future<void> _clearQuietly() async {
    try {
      await clear();
    } catch (_) {
      // 로그는 clear 에서 남긴다.
    }
  }
}
