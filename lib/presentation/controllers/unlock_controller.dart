import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/data/repositories/repositories.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';

/// 숨겨진 여행지(날씨 해금) 목록 — `GET /courses/unlocked`.
class UnlockState {
  const UnlockState({this.location, this.status});

  final LocationQuery? location;
  final AsyncValue<UnlockStatus>? status;

  List<UnlockedCourse> get unlocked =>
      status?.value?.unlockedCourses ?? const [];

  List<LockedCourse> get locked => status?.value?.lockedCourses ?? const [];

  int get unlockedCount => unlocked.length;

  int get totalCount => unlocked.length + locked.length;

  /// 희귀도별 개수 — 컬렉션 요약 배지에 사용.
  Map<CourseRarity, int> get rarityCounts {
    final counts = <CourseRarity, int>{};
    for (final course in unlocked) {
      final rarity = course.rarity;
      if (rarity == null) continue;
      counts[rarity] = (counts[rarity] ?? 0) + 1;
    }
    return counts;
  }

  UnlockState copyWith({
    LocationQuery? location,
    AsyncValue<UnlockStatus>? status,
  }) => UnlockState(
    location: location ?? this.location,
    status: status ?? this.status,
  );
}

class UnlockNotifier extends Notifier<UnlockState> {
  /// 위치가 바뀔 때마다 증가. 이전 위치의 응답이 최신 상태를 덮어쓰지 않게 한다.
  int _generation = 0;

  @override
  UnlockState build() => const UnlockState();

  void setLocation({required double lat, required double lng}) {
    _generation++;
    state = state.copyWith(
      location: LocationQuery(lat: lat, lng: lng),
    );
  }

  Future<void> load({double? lat, double? lng}) async {
    if (lat != null && lng != null) setLocation(lat: lat, lng: lng);
    final generation = _generation;
    state = state.copyWith(status: const AsyncLoading());
    final result = await guardAsync(
      () => gamificationRepository.fetchUnlockStatus(state.location),
    );
    if (generation != _generation) return;
    state = state.copyWith(status: result);
  }
}

final unlockProvider = NotifierProvider<UnlockNotifier, UnlockState>(
  UnlockNotifier.new,
);
