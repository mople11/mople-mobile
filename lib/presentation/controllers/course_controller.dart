import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/data/repositories/repositories.dart';
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
    // MoodSelector 는 화면 강조용 영문 코드(`heal` 등)를 상태로 들고 있다.
    // 서버는 companion/transport 처럼 한글 라벨을 기대하므로 변환해서 보낸다.
    mood: EodiganamData.moodLabel(mood),
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
  /// 계획 세대 번호. [resetPlan] 이 증가시킨다.
  ///
  /// 요청이 진행 중일 때 초기화하면, 뒤늦게 끝난 이전 요청이 비워둔 상태에 결과를
  /// 다시 써 넣어 화면이 결과 단계로 되돌아간다. 반영 전에 세대를 확인한다.
  int _generation = 0;

  /// 최적화 입력(장소 목록·순서·이동수단) revision.
  ///
  /// 세대([_generation])는 계획 초기화·코스 전환에만 오른다. 같은 계획 안에서
  /// 장소를 바꾸고 다시 최적화하면 세대는 그대로라, 이전 동선 응답이 늦게
  /// 도착해 새 화면에 옛 동선을 그린다.
  int _optimizeRevision = 0;

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

  /// [expectedId] 가 아직 현재 값일 때만 코스 선택을 비운다.
  ///
  /// [courseProvider] 는 전역이라, 먼저 열려 있던 CoursePage 의 정리가 새
  /// CoursePage 의 [setCourseId] 뒤에 실행되면 새 코스 ID 를 지워 버린다.
  void clearCourseIdIfMatches(String expectedId) {
    if (state.courseId != expectedId) return;
    setCourseId(null);
  }

  void setCourseId(String? value) {
    // 다른 코스로 바뀌면 이전 코스의 저장·시작·공유 응답이 새 코스 상태를
    // 건드리지 못하게 세대를 올린다.
    if (value != state.courseId) _generation++;
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
    final generation = _generation;
    state = state.copyWith(recommendation: const AsyncLoading());
    final result = await guardAsync(
      () => courseRepository.requestAiRecommendation(request),
    );
    if (generation != _generation) return null;
    state = state.copyWith(recommendation: result);
    if (result.value != null) setCourseId(result.value!.courseId);
    return result.value;
  }

  // ── 동선 최적화 ───────────────────────────────────────────
  void togglePlace(String placeId) {
    final ids = [...state.selectedPlaceIds];
    if (!ids.remove(placeId)) ids.add(placeId);
    _optimizeRevision++;
    state = state.copyWith(selectedPlaceIds: ids);
  }

  /// 선택 목록을 통째로 갈아끼운다.
  ///
  /// [courseProvider] 는 autoDispose 가 아니라 화면을 나가도 상태가 남는다.
  /// 새 동선을 계산할 때 [togglePlace] 로 추가만 하면 이전 코스의 장소가 그대로
  /// 섞이므로, 화면에서 넘어온 목록으로 교체해야 한다. 중복 id 도 여기서 제거한다.
  void setSelectedPlaces(List<String> placeIds) {
    _optimizeRevision++;
    state = state.copyWith(selectedPlaceIds: placeIds.toSet().toList());
  }

  void setRouteTransport(RouteTransport value) {
    _optimizeRevision++;
    state = state.copyWith(routeTransport: value);
  }

  void reorderPlaces(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final ids = [...state.selectedPlaceIds];
    final item = ids.removeAt(oldIndex);
    ids.insert(newIndex, item);
    _optimizeRevision++;
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
    final generation = _generation;
    final revision = _optimizeRevision;
    state = state.copyWith(optimized: const AsyncLoading());
    final result = await guardAsync(
      () => courseRepository.optimizeCourse(request),
    );
    if (generation != _generation || revision != _optimizeRevision) return null;
    state = state.copyWith(optimized: result);
    return result.value;
  }

  // ── 시작 / 저장 / 공유 / 완주 ──────────────────────────────
  Future<CourseStartResult?> start([String? id]) async {
    final target = id ?? state.courseId;
    if (target == null) return null;
    final generation = _generation;
    state = state.copyWith(started: const AsyncLoading());
    final result = await guardAsync(() => courseRepository.startCourse(target));
    if (generation != _generation) return null;
    state = state.copyWith(started: result);
    return result.value;
  }

  Future<void> save([String? id]) async {
    final target = id ?? state.courseId;
    if (target == null) return;
    final generation = _generation;
    final previous = state.saved;
    state = state.copyWith(saved: true, saveAction: const AsyncLoading());
    final result = await guardAsync(() => courseRepository.saveCourse(target));
    if (generation != _generation) return;
    state = state.copyWith(
      saveAction: result,
      saved: result.hasError ? previous : true,
    );
  }

  Future<ShareResult?> share([String? id]) async {
    final target = id ?? state.courseId;
    if (target == null) return null;
    final generation = _generation;
    state = state.copyWith(shared: const AsyncLoading());
    final result = await guardAsync(() => courseRepository.shareCourse(target));
    if (generation != _generation) return null;
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
    final generation = _generation;
    state = state.copyWith(completed: const AsyncLoading());
    final result = await guardAsync(
      () => courseRepository.completeCourse(target, request),
    );
    if (generation != _generation) return null;
    state = state.copyWith(completed: result);
    return result.value;
  }

  /// copyWith 는 `null` 을 "값 없음 유지"로 취급하므로, 실제로 async 슬롯들을
  /// 비우려면 (idle 로 되돌리려면) 새 [CourseState] 를 직접 만든다.
  void resetPlan() {
    // 진행 중인 요청의 결과가 뒤늦게 반영되지 않도록 세대를 올린다.
    _generation++;
    state = CourseState(
      // 입력값은 남겨 사용자가 조건을 다시 고르지 않아도 되게 한다.
      mood: state.mood,
      companion: state.companion,
      transport: state.transport,
      timeAvailable: state.timeAvailable,
      freeText: state.freeText,
      routeTransport: state.routeTransport,
      // recommendation/optimized/courseId 등 결과 슬롯은 비운다.
      // 여기에 recommendation 을 남기면 화면이 결과 단계에서 못 벗어난다.
    );
  }
}

final courseProvider = NotifierProvider<CourseNotifier, CourseState>(
  CourseNotifier.new,
);
