import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:path_provider/path_provider.dart';

/// 로그인 세션을 기기에 안전하게 보관한다(iOS Keychain / Android Keystore).
///
/// [ApiClient] 의 인터셉터는 매 요청마다 동기적으로 토큰을 읽어야 하는데 보안
/// 저장소는 비동기라, **메모리 캐시를 정본처럼 쓰고 저장소에는 write-through** 한다.
/// 앱 시작 시 [restore] 로 캐시를 채운 뒤에야 인증이 필요한 요청을 보낼 수 있다.
///
/// ## 로그아웃이 실패해도 세션이 되살아나지 않게 하는 방법
///
/// 보안 저장소 삭제는 실패할 수 있다. 실패한 사실을 메모리에만 두면 앱을 껐다
/// 켜는 순간 사라져, 남아 있던 세션을 [restore] 가 그대로 복원해 **로그아웃한
/// 계정으로 다시 로그인된 상태**가 된다. 그래서 서로 독립적인 근거를 겹쳐 둔다.
///
/// 1. 보안 저장소의 `auth_logged_out` 표시
/// 2. 앱 지원 디렉터리의 표시 파일 — Keychain 이 통째로 실패해도 파일은 써진다
/// 3. 1·2 가 모두 실패하면 세션 자체를 빈 값으로 덮어쓴다(삭제와 다른 연산이다)
/// 4. 이번 프로세스 한정 [_deleteFailed] 플래그
/// 5. 표시를 한 곳이라도 **읽지 못하면** 복원하지 않는다(fail-closed)
///
/// 표시는 로그아웃 여부일 뿐 비밀이 아니므로 파일에 평문으로 두어도 무방하다.
abstract final class AuthTokenStore {
  /// Android 는 v11 부터 암호화가 기본이라 별도 옵션이 필요 없다.
  /// iOS 는 기기 첫 잠금해제 이후에만 읽히도록 제한한다(백그라운드 갱신 대비).
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _sessionKey = 'auth_session';
  static const _logoutMarkerKey = 'auth_logged_out';
  static const _logoutMarkerFileName = 'auth_logout_pending';

  static AuthSession? _session;

  /// 이번 프로세스에서 삭제가 실패한 적이 있으면 true.
  static bool _deleteFailed = false;

  /// 세션이 바뀔 때마다 오른다. 요청을 보낸 시점의 세션과 응답이 도착한 시점의
  /// 세션이 같은지 판별하는 데 쓴다(계정 A 의 응답이 계정 B 세션을 건드리지
  /// 못하게 한다).
  static int _revision = 0;

  static int get revision => _revision;

  /// 인터셉터가 헤더에 실을 액세스 토큰.
  static String? get accessToken => _session?.accessToken;

  /// 로그아웃 요청 바디에 필요한 리프레시 토큰.
  static String? get refreshToken => _session?.refreshToken;

  static AuthSession? get session => _session;

  static bool get hasSession => _session != null;

  /// 로그인·회원가입 성공 시 호출. 메모리와 저장소에 함께 기록한다.
  static Future<void> _saveUnlocked(AuthSession session) async {
    _session = session;
    _deleteFailed = false;
    _revision++;
    var persisted = false;
    try {
      await _storage.write(
        key: _sessionKey,
        value: jsonEncode(session.toJson()),
      );
      persisted = true;
    } catch (e) {
      // 저장에 실패해도 이번 세션은 메모리로 계속 쓸 수 있으므로 앱을 멈추지 않는다.
      debugPrint('[Auth] 세션 저장 실패: $e');
    }
    // 새 세션을 실제로 기록했을 때만 이전 로그아웃 표시를 거둔다.
    //
    // 쓰기가 실패했는데 표시까지 지우면, 저장소에 남아 있는 **이전 계정의**
    // 세션이 다음 실행에서 복원된다. 표시를 남겨 두면 그 복원이 막히고,
    // 이번 실행은 메모리 세션으로 정상 동작한다.
    if (persisted) await _removeLogoutMarker();
  }

  /// 앱 시작 시 1회 호출해 저장된 세션을 메모리로 올린다.
  /// 복원된 세션이 있으면 반환한다.
  static Future<AuthSession?> _restoreUnlocked() async {
    if (_deleteFailed) {
      debugPrint('[Auth] 이전 삭제 실패로 세션 복원을 건너뜁니다.');
      return null;
    }
    // 이전 실행에서 로그아웃이 끝나지 않았다면 세션이 남아 있을 수 있다.
    // 표시를 확인할 수 없는 경우도 복원하지 않는다(fail-closed).
    final bool pending;
    try {
      pending = await _hasLogoutMarker();
    } catch (e) {
      // 확인할 수 없으면 복원하지 않는다. 다만 세션을 지우지는 않는다 —
      // 일시적인 저장소 오류로 멀쩡한 세션을 날려 강제 로그아웃시키지 않기
      // 위해서다. 복원을 안 하므로 이번 실행에서 토큰이 쓰이는 일은 없고,
      // 다음 실행에서 표시를 읽을 수 있으면 그때 정리된다.
      debugPrint('[Auth] 로그아웃 표시를 읽지 못해 세션을 복원하지 않습니다: $e');
      return null;
    }
    if (pending) {
      debugPrint('[Auth] 완료되지 않은 로그아웃이 있어 세션을 복원하지 않습니다.');
      await _clearQuietly();
      return null;
    }

    try {
      final raw = await _storage.read(key: _sessionKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final session = AuthSession.fromJson(asMap(decoded));
      // 토큰이 비어 있으면 쓸 수 없는 세션이라 지운다(삭제 실패 시의 덮어쓴 값 포함).
      if (session.accessToken.isEmpty) {
        await _clearQuietly();
        return null;
      }
      _session = session;
      // 복원 전에 나간 요청은 옛 revision 을 들고 있다. 여기서 올리지 않으면
      // 그 요청이 401 로 돌아왔을 때 같은 세션으로 판정돼, 방금 복원한 세션이
      // 지워진다.
      _revision++;
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
  /// 오해한다. 다만 예외를 무시하고 진행하더라도 위에 적은 다중 방어가 남아
  /// [restore] 는 그 세션을 되살리지 않는다.
  static Future<void> _clearUnlocked() async {
    _session = null;
    _revision++;
    // 삭제보다 먼저 표시를 남긴다. 삭제가 실패한 채 앱이 종료돼도 다음 실행에서
    // 복원을 막을 근거는 이 표시뿐이다.
    final marked = await _writeLogoutMarker();

    try {
      await _storage.delete(key: _sessionKey);
    } catch (e) {
      _deleteFailed = true;
      debugPrint('[Auth] 세션 삭제 실패: $e');
      if (!marked) {
        // 표시도 못 남겼고 삭제도 실패했다. 마지막 수단으로 세션을 빈 값으로
        // 덮어쓴다. 삭제(SecItemDelete)와 쓰기(SecItemUpdate)는 다른 연산이라
        // 하나가 막혀도 다른 하나는 통할 수 있다. restore 는 빈 값을 세션 없음으로
        // 취급한다.
        try {
          await _storage.write(key: _sessionKey, value: '');
          debugPrint('[Auth] 세션을 빈 값으로 덮어써 복원을 차단했습니다.');
        } catch (e2) {
          debugPrint('[Auth] 세션 무효화 실패 — 저장소에 세션이 남을 수 있습니다: $e2');
        }
      }
      rethrow;
    }

    _deleteFailed = false;
    // 삭제가 확인된 뒤에만 표시를 거둔다. 여기서 실패해 표시가 남더라도
    // 다음 로그인의 [save] 가 지우므로 사용자를 가두지 않는다.
    await _removeLogoutMarker();
  }

  // ── 직렬화 ────────────────────────────────────────────────
  //
  // save 는 메모리 세션을 먼저 바꾸고 저장소 쓰기를 await 한다. 그 사이에 401
  // 이나 로그아웃이 clear 를 실행하면, 뒤늦게 재개된 쓰기가 **로그아웃한
  // 세션을 다시 저장**하거나 새 세션의 값을 지운다. 세 연산을 한 줄로 세운다.

  static Future<void> _lock = Future<void>.value();

  static Future<T> _synchronized<T>(Future<T> Function() action) {
    final result = _lock.then((_) => action());
    _lock = result.then((_) {}, onError: (_) {});
    return result;
  }

  /// 로그인·회원가입 성공 시 호출.
  static Future<void> save(AuthSession session) =>
      _synchronized(() => _saveUnlocked(session));

  /// 앱 시작 시 1회 호출해 저장된 세션을 메모리로 올린다.
  static Future<AuthSession?> restore() =>
      _synchronized(_restoreUnlocked);

  /// 로그아웃·토큰 만료 시 메모리와 저장소를 모두 비운다.
  static Future<void> clear() => _synchronized(_clearUnlocked);

  /// 복원 경로 전용 삭제. 어차피 복원하지 않는 자리라 예외를 올리지 않는다.
  static Future<void> _clearQuietly() async {
    try {
      await _clearUnlocked();
    } catch (_) {
      // 로그는 clear 에서 남긴다.
    }
  }

  // ── 로그아웃 표시 ─────────────────────────────────────────
  // 보안 저장소와 파일 두 곳에 남긴다. 한쪽이 실패해도 다른 쪽이 근거로 남는다.

  /// 최소 한 곳에 표시를 남겼으면 true.
  static Future<bool> _writeLogoutMarker() async {
    var marked = false;
    try {
      await _storage.write(key: _logoutMarkerKey, value: '1');
      marked = true;
    } catch (e) {
      debugPrint('[Auth] 로그아웃 표시 기록 실패(보안 저장소): $e');
    }
    try {
      final file = await _logoutMarkerFile();
      await file.writeAsString('1', flush: true);
      marked = true;
    } catch (e) {
      debugPrint('[Auth] 로그아웃 표시 기록 실패(파일): $e');
    }
    return marked;
  }

  /// 어느 한 곳이라도 표시가 있으면 true.
  ///
  /// **한 곳이라도 읽지 못하면 예외를 올린다** — 호출부는 복원을 포기한다.
  /// 표시는 한쪽에만 기록됐을 수 있어서(기록도 한쪽이 실패할 수 있다), 읽지 못한
  /// 저장소에 표시가 있었는지 알 수 없다. 나머지 한 곳이 "표시 없음"이라고
  /// 해서 로그아웃이 없었다고 단정하면 남아 있는 세션이 되살아난다.
  static Future<bool> _hasLogoutMarker() async {
    Object? storageError;
    Object? fileError;
    var found = false;

    try {
      final value = await _storage.read(key: _logoutMarkerKey);
      if (value != null && value.isNotEmpty) found = true;
    } catch (e) {
      storageError = e;
    }
    try {
      final file = await _logoutMarkerFile();
      if (file.existsSync()) found = true;
    } catch (e) {
      fileError = e;
    }

    if (found) return true;
    if (storageError != null || fileError != null) {
      throw StateError('로그아웃 표시 확인 실패: $storageError / $fileError');
    }
    return false;
  }

  static Future<void> _removeLogoutMarker() async {
    try {
      await _storage.delete(key: _logoutMarkerKey);
    } catch (e) {
      debugPrint('[Auth] 로그아웃 표시 제거 실패(보안 저장소): $e');
    }
    try {
      final file = await _logoutMarkerFile();
      if (file.existsSync()) await file.delete();
    } catch (e) {
      debugPrint('[Auth] 로그아웃 표시 제거 실패(파일): $e');
    }
  }

  static Future<File> _logoutMarkerFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_logoutMarkerFileName');
  }
}
