import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/data/repositories/repositories.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';

/// 스탬프북(`GET /stamps`, `POST /stamps/checkin`) 상태.
class StampState {
  const StampState({this.stampBook, this.checkIn});

  final AsyncValue<StampBook>? stampBook;
  final AsyncValue<StampCheckInResult>? checkIn;

  List<String> get collected => stampBook?.value?.collected ?? const [];

  int get totalCount => stampBook?.value?.totalCount ?? 0;

  int get collectedCount => collected.length;

  /// 0~1 로 정규화한 달성률. 서버 `progress` 가 0~100 로 와도 동일하게 다룬다.
  double get progress {
    final raw = stampBook?.value?.progress;
    if (raw == null || raw == 0) {
      return totalCount == 0 ? 0 : collectedCount / totalCount;
    }
    return raw > 1 ? raw / 100 : raw;
  }

  bool hasStamp(String cityCode) => collected.contains(cityCode);

  /// 방금 체크인으로 새 스탬프를 얻었는지.
  bool get justAcquired => checkIn?.value?.stampAcquired ?? false;

  /// 이미 획득한 지역이라 스탬프가 추가되지 않은 경우(`ALREADY_ACQUIRED`).
  bool get alreadyAcquired =>
      checkIn?.apiError?.code == ApiErrorCode.alreadyAcquired ||
      (checkIn?.hasValue == true && !checkIn!.value!.stampAcquired);

  StampState copyWith({
    AsyncValue<StampBook>? stampBook,
    AsyncValue<StampCheckInResult>? checkIn,
  }) => StampState(
    stampBook: stampBook ?? this.stampBook,
    checkIn: checkIn ?? this.checkIn,
  );
}

class StampNotifier extends Notifier<StampState> {
  @override
  StampState build() => const StampState();

  Future<void> load() async {
    state = state.copyWith(stampBook: const AsyncLoading());
    final result = await guardAsync(gamificationRepository.fetchStampBook);
    state = state.copyWith(stampBook: result);
  }

  /// 위치 체크인. 이미 획득한 지역이면 `stampAcquired: false` 로 온다.
  Future<StampCheckInResult?> checkInAt({
    required double lat,
    required double lng,
  }) async {
    final request = StampCheckInRequest(lat: lat, lng: lng);
    state = state.copyWith(checkIn: const AsyncLoading());
    final result = await guardAsync(
      () => gamificationRepository.checkIn(request),
    );
    state = state.copyWith(checkIn: result);
    if (result.value?.stampAcquired ?? false) await load();
    return result.value;
  }
}

final stampProvider = NotifierProvider<StampNotifier, StampState>(
  StampNotifier.new,
);
