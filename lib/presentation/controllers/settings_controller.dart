import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/data/repositories/repositories.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';

/// 공통 범위(`GET /settings`, `PATCH /settings`) 상태.
///
/// 스위치를 누르는 즉시 UI 를 바꾸고 PATCH 를 보내며, 실패하면 이전 값으로 되돌린다.
class SettingsState {
  const SettingsState({this.settings, this.updateAction});

  final AsyncValue<AppSettings>? settings;
  final AsyncValue<void>? updateAction;

  AppSettings get current => settings?.value ?? AppSettings.defaults;

  bool get pushEnabled => current.notifications.push;

  bool get goldenHourEnabled => current.notifications.goldenHour;

  bool get locationGranted => current.permissions.location;

  AppLanguage get language => current.language;

  SettingsState copyWith({
    AsyncValue<AppSettings>? settings,
    AsyncValue<void>? updateAction,
  }) => SettingsState(
    settings: settings ?? this.settings,
    updateAction: updateAction ?? this.updateAction,
  );
}

class SettingsNotifier extends Notifier<SettingsState> {
  /// 진행 중인 PATCH 체인. 스위치를 연달아 누를 때 요청이 겹치면 이전 요청의
  /// 실패 롤백이 이후 변경을 되돌릴 수 있어, 순서대로 하나씩 보낸다.
  Future<void> _pending = Future<void>.value();

  /// 설정 revision. PATCH 를 시작할 때마다 오른다.
  ///
  /// `_pending` 은 PATCH 끼리만 줄 세운다. 조회는 따로 나가므로, GET 을 띄운 뒤
  /// 스위치를 만지면 **서버가 바뀌기 전에 읽은 값**이 뒤늦게 도착해 방금 켠
  /// 스위치를 도로 꺼 버린다. 그 GET 을 버리는 데 쓴다.
  int _revision = 0;

  @override
  SettingsState build() => const SettingsState();

  Future<void> load() async {
    final revision = ++_revision;
    state = state.copyWith(settings: const AsyncLoading());
    final result = await guardAsync(settingsRepository.fetchSettings);
    // 대기 중에 PATCH 가 시작됐으면 이 응답은 이미 낡았다.
    if (revision != _revision) return;
    state = state.copyWith(settings: result);
  }

  Future<bool> setPush(bool value) => _patch(
    (current) => SettingsUpdateRequest(
      notifications: current.notifications.copyWith(push: value),
    ),
  );

  Future<bool> setGoldenHour(bool value) => _patch(
    (current) => SettingsUpdateRequest(
      notifications: current.notifications.copyWith(goldenHour: value),
    ),
  );

  Future<bool> setLocationPermission(bool value) => _patch(
    (current) => SettingsUpdateRequest(
      permissions: current.permissions.copyWith(location: value),
    ),
  );

  Future<bool> setLanguage(AppLanguage value) =>
      _patch((_) => SettingsUpdateRequest(language: value));

  /// 낙관적 반영 후 실패 시 롤백.
  ///
  /// 요청은 **큐가 실행될 때** 만든다. 미리 만들어 두면 앞선 요청이 바꾼 값을
  /// 반영하지 못한다. 예를 들어 푸시를 켠 직후 골든아워를 켜면, 두 번째 요청이
  /// 담고 있던 옛 `push: false` 가 서버와 화면의 푸시를 도로 꺼 버린다.
  Future<bool> _patch(SettingsUpdateRequest Function(AppSettings current) build) {
    // 앞선 요청이 끝난 뒤에 실행되도록 큐에 잇는다.
    final result = _pending.then((_) => _patchNow(build(state.current)));
    _pending = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<bool> _patchNow(SettingsUpdateRequest request) async {
    if (request.isEmpty) return false;
    // 진행 중인 조회 응답이 이 변경을 덮어쓰지 못하게 한다.
    _revision++;
    final previous = state.current;
    state = state.copyWith(
      settings: AsyncData(
        previous.copyWith(
          notifications: request.notifications,
          language: request.language,
          permissions: request.permissions,
        ),
      ),
      updateAction: const AsyncLoading(),
    );

    final result = await guardAsync(
      () => settingsRepository.updateSettings(request),
    );
    final ok = !result.hasError;
    state = state.copyWith(
      updateAction: result,
      settings: ok ? state.settings : AsyncData(previous),
    );
    return ok;
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
