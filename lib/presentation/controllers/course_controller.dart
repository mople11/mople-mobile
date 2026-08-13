import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/mock/mock_api.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';

/// 추천 범위(`POST /recommend/ai`, `/courses/**`) 상태.
///
/// AI 추천 입력 → 코스 확보 → 시작/저장/공유/완주까지 한 흐름이라 하나의 상태로 묶었다.
class CourseState {
  const CourseState({
    this.mood = '',
    this.companion,
    this.transport,
    this.timeAvailable,
    this.freeText,
    this.recommendation,
    this.selectedPlaceIds = const <String>[],
    this.routeTransport = RouteTransport.walk,
    this.optimized,
    this.started,
    this.completed,
    this.shared,
    this.saveAction,
    this.saved = false,
    this.courseId,
  });

  // ── AI 맞춤 추천 입력 (`POST /recommend/ai`) ───────────────
  final String mood;
  final Companion? companion;
  final Transport? transport;
  final String? timeAvailable;
  final String? freeText;

  final AsyncValue<AiCourseRecommendation>? recommendation;

  // ── 동선 최적화 (`POST /courses/optimize`) ─────────────────
  final List<String> selectedPlaceIds;
  final RouteTransport routeTransport;
  final AsyncValue<CourseOptimizeResult>? optimized;

  // ── 코스 액션 ─────────────────────────────────────────────
  final AsyncValue<CourseStartResult>? started;
  final AsyncValue<CourseCompleteResult>? completed;
  final AsyncValue<ShareResult>? shared;
  final AsyncValue<void>? saveAction;
  final bool saved;

  /// 현재 다루고 있는 코스 id. AI 추천 결과가 오면 자동으로 채워진다.
  final String? courseId;

  AiRecommendRequest get recommendRequest => AiRecommendRequest(
    mood: mood,
    companion: companion,
    transport: transport,
    timeAvailable: timeAvailable,
    freeText: freeText,
  );

  bool get canRecommend => mood.trim().isNotEmpty;

  CourseState copyWith({
    String? mood,
    Companion? companion,
    Transport? transport,
    String? timeAvailable,
    String? freeText,
    AsyncValue<AiCourseRecommendation>? recommendation,
    List<String>? selectedPlaceIds,
    RouteTransport? routeTransport,
    AsyncValue<CourseOptimizeResult>? optimized,
    AsyncValue<CourseStartResult>? started,
    AsyncValue<CourseCompleteResult>? completed,
    AsyncValue<ShareResult>? shared,
    AsyncValue<void>? saveAction,
    bool? saved,
    String? courseId,
    bool clearCourseId = false,
  }) => CourseState(
    mood: mood ?? this.mood,
    companion: companion ?? this.companion,
    transport: transport ?? this.transport,
    timeAvailable: timeAvailable ?? this.timeAvailable,
    freeText: freeText ?? this.freeText,
    recommendation: recommendation ?? this.recommendation,
    selectedPlaceIds: selectedPlaceIds ?? this.selectedPlaceIds,
    routeTransport: routeTransport ?? this.routeTransport,
    optimized: optimized ?? this.optimized,
    started: started ?? this.started,
    completed: completed ?? this.completed,
    shared: shared ?? this.shared,
    saveAction: saveAction ?? this.saveAction,
    saved: saved ?? this.saved,
    courseId: clearCourseId ? null : (courseId ?? this.courseId),
  );
}

class CourseNotifier extends Notifier<CourseState> {
  @override
  CourseState build() => const CourseState();

  void setMood(String value) => state = state.copyWith(mood: value);

  void setCompanion(Companion? value) =>
      state = state.copyWith(companion: value);

  void setTransport(Transport? value) =>
      state = state.copyWith(transport: value);

  void setTimeAvailable(String? value) =>
      state = state.copyWith(timeAvailable: value);

  void setFreeText(String? value) => state = state.copyWith(freeText: value);

  void setCourseId(String? value) {
    state = state.copyWith(
      courseId: value,
      clearCourseId: value == null,
      saved: false,
    );
  }

  /// `MOOD_REQUIRED` 를 서버까지 가기 전에 걸러낸다.
  Future<AiCourseRecommendation?> requestRecommendation() async {
    if (!state.canRecommend) {
      state = state.copyWith(
        recommendation: AsyncError(
          ApiError.local(ApiErrorCode.moodRequired),
          StackTrace.current,
        ),
      );
      return null;
    }
    final request = state.recommendRequest;
    state = state.copyWith(recommendation: const AsyncLoading());
    final result = await guardAsync(
      () => mockApi.requestAiRecommendation(request),
    );
    state = state.copyWith(recommendation: result);
    if (result.value != null) setCourseId(result.value!.courseId);
    return result.value;
  }

  // ── 동선 최적화 ───────────────────────────────────────────
  void togglePlace(String placeId) {
    final ids = [...state.selectedPlaceIds];
    if (!ids.remove(placeId)) ids.add(placeId);
    state = state.copyWith(selectedPlaceIds: ids);
  }

  void setRouteTransport(RouteTransport value) =>
      state = state.copyWith(routeTransport: value);

  void reorderPlaces(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final ids = [...state.selectedPlaceIds];
    final item = ids.removeAt(oldIndex);
    ids.insert(newIndex, item);
    state = state.copyWith(selectedPlaceIds: ids);
  }

  /// `MIN_PLACE_REQUIRED` 를 클라이언트에서 먼저 검증한다.
  Future<CourseOptimizeResult?> optimize() async {
    final request = CourseOptimizeRequest(
      placeIds: state.selectedPlaceIds.toList(),
      transport: state.routeTransport,
    );
    if (!request.isValid) {
      state = state.copyWith(
        optimized: AsyncError(
          ApiError.local(ApiErrorCode.minPlaceRequired),
          StackTrace.current,
        ),
      );
      return null;
    }
    state = state.copyWith(optimized: const AsyncLoading());
    final result = await guardAsync(() => mockApi.optimizeCourse(request));
    state = state.copyWith(optimized: result);
    return result.value;
  }

  // ── 시작 / 저장 / 공유 / 완주 ──────────────────────────────
  Future<CourseStartResult?> start([String? id]) async {
    final target = id ?? state.courseId;
    if (target == null) return null;
    state = state.copyWith(started: const AsyncLoading());
    final result = await guardAsync(() => mockApi.startCourse(target));
    state = state.copyWith(started: result);
    return result.value;
  }

  Future<void> save([String? id]) async {
    final target = id ?? state.courseId;
    if (target == null) return;
    final previous = state.saved;
    state = state.copyWith(saved: true, saveAction: const AsyncLoading());
    final result = await guardAsync(() => mockApi.saveCourse(target));
    state = state.copyWith(
      saveAction: result,
      saved: result.hasError ? previous : true,
    );
  }

  Future<ShareResult?> share([String? id]) async {
    final target = id ?? state.courseId;
    if (target == null) return null;
    state = state.copyWith(shared: const AsyncLoading());
    final result = await guardAsync(() => mockApi.shareCourse(target));
    state = state.copyWith(shared: result);
    return result.value;
  }

  /// 완주 인증. 성공하면 `data.cardId` 로 완주 카드 생성까지 이어진다.
  Future<CourseCompleteResult?> complete({
    String? id,
    required List<GeoPoint> checkInLocations,
  }) async {
    final target = id ?? state.courseId;
    if (target == null) return null;
    final request = CourseCompleteRequest(checkInLocations: checkInLocations);
    state = state.copyWith(completed: const AsyncLoading());
    final result = await guardAsync(
      () => mockApi.completeCourse(target, request),
    );
    state = state.copyWith(completed: result);
    return result.value;
  }

  /// copyWith 는 `null` 을 "값 없음 유지"로 취급하므로, 실제로 async 슬롯들을
  /// 비우려면 (idle 로 되돌리려면) 새 [CourseState] 를 직접 만든다.
  void resetPlan() {
    state = CourseState(
      mood: state.mood,
      companion: state.companion,
      transport: state.transport,
      timeAvailable: state.timeAvailable,
      freeText: state.freeText,
      recommendation: state.recommendation,
      routeTransport: state.routeTransport,
      courseId: state.courseId,
    );
  }
}

final courseProvider = NotifierProvider<CourseNotifier, CourseState>(
  CourseNotifier.new,
);
