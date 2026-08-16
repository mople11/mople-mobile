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

  @override
  SettingsState build() => const SettingsState();

  Future<void> load() async {
    state = state.copyWith(settings: const AsyncLoading());
    final result = await guardAsync(settingsRepository.fetchSettings);
    state = state.copyWith(settings: result);
  }

  Future<bool> setPush(bool value) => _patch(
    SettingsUpdateRequest(
      notifications: state.current.notifications.copyWith(push: value),
    ),
  );

  Future<bool> setGoldenHour(bool value) => _patch(
    SettingsUpdateRequest(
      notifications: state.current.notifications.copyWith(goldenHour: value),
    ),
  );

  Future<bool> setLocationPermission(bool value) => _patch(
    SettingsUpdateRequest(
      permissions: state.current.permissions.copyWith(location: value),
    ),
  );

  Future<bool> setLanguage(AppLanguage value) =>
      _patch(SettingsUpdateRequest(language: value));

  /// 낙관적 반영 후 실패 시 롤백.
  Future<bool> _patch(SettingsUpdateRequest request) {
    // 앞선 요청이 끝난 뒤에 실행되도록 큐에 잇는다.
    final result = _pending.then((_) => _patchNow(request));
    _pending = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<bool> _patchNow(SettingsUpdateRequest request) async {
    if (request.isEmpty) return false;
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
