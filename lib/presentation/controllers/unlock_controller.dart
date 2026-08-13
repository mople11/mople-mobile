import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/mock/mock_api.dart';
import 'package:mople_mobile/data/models/models.dart';
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
  @override
  UnlockState build() => const UnlockState();

  void setLocation({required double lat, required double lng}) {
    state = state.copyWith(
      location: LocationQuery(lat: lat, lng: lng),
    );
  }

  Future<void> load({double? lat, double? lng}) async {
    if (lat != null && lng != null) setLocation(lat: lat, lng: lng);
    state = state.copyWith(status: const AsyncLoading());
    state = state.copyWith(
      status: await guardAsync(() => mockApi.fetchUnlockStatus(state.location)),
    );
  }
}

final unlockProvider = NotifierProvider<UnlockNotifier, UnlockState>(
  UnlockNotifier.new,
);
