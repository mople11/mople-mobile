import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/data/repositories/repositories.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';

/// 마이페이지 범위(`/users/me/**`) 상태.
///
/// 프로필·활동요약, 저장한 코스, 내 후기, 찜 목록을 한 화면에서 함께 쓰기 때문에
/// 하나의 상태에 모았다.
class MyPageState {
  const MyPageState({
    this.summary,
    this.savedCourses,
    this.myReviews,
    this.likedPlaces,
    this.profileUpdate,
  });

  final AsyncValue<MyPageSummary>? summary;
  final AsyncValue<Paged<SavedCourse>>? savedCourses;
  final AsyncValue<Paged<MyReview>>? myReviews;
  final AsyncValue<Paged<LikedPlace>>? likedPlaces;

  /// `PATCH /users/me`
  final AsyncValue<void>? profileUpdate;

  UserProfile get profile => summary?.value?.profile ?? UserProfile.empty;

  UserStats get stats => summary?.value?.stats ?? UserStats.empty;

  MyPageState copyWith({
    AsyncValue<MyPageSummary>? summary,
    AsyncValue<Paged<SavedCourse>>? savedCourses,
    AsyncValue<Paged<MyReview>>? myReviews,
    AsyncValue<Paged<LikedPlace>>? likedPlaces,
    AsyncValue<void>? profileUpdate,
  }) => MyPageState(
    summary: summary ?? this.summary,
    savedCourses: savedCourses ?? this.savedCourses,
    myReviews: myReviews ?? this.myReviews,
    likedPlaces: likedPlaces ?? this.likedPlaces,
    profileUpdate: profileUpdate ?? this.profileUpdate,
  );
}

class MyPageNotifier extends Notifier<MyPageState> {
  /// 목록별로 진행 중인 다음-페이지 요청. 같은 페이지를 두 번 이어 붙이지 않도록 막는다.
  final Set<String> _loadingMore = {};

  @override
  MyPageState build() => const MyPageState();

  Future<void> loadAll() async {
    await Future.wait([
      loadSummary(),
      loadSavedCourses(),
      loadMyReviews(),
      loadLikedPlaces(),
    ]);
  }

  // 아래 로더들은 화면에서 동시에 호출된다.
  //
  // `state = state.copyWith(x: await ...)` 로 쓰면 Dart 가 수신자 `state` 를 await
  // 보다 먼저 평가하기 때문에, await 중에 다른 로더가 갱신한 필드가 통째로
  // 되돌아간다(먼저 끝난 요청 결과가 사라져 영원히 로딩으로 남는다).
  // 반드시 결과를 지역 변수로 받은 뒤 최신 state 에 얹어야 한다.

  Future<void> loadSummary() async {
    state = state.copyWith(summary: const AsyncLoading());
    final result = await guardAsync(myPageRepository.fetchMe);
    state = state.copyWith(summary: result);
  }

  Future<void> loadSavedCourses() async {
    state = state.copyWith(savedCourses: const AsyncLoading());
    final result = await guardAsync(() => myPageRepository.fetchSavedCourses());
    state = state.copyWith(savedCourses: result);
  }

  Future<void> loadMyReviews() async {
    state = state.copyWith(myReviews: const AsyncLoading());
    final result = await guardAsync(() => myPageRepository.fetchMyReviews());
    state = state.copyWith(myReviews: result);
  }

  Future<void> loadLikedPlaces() async {
    state = state.copyWith(likedPlaces: const AsyncLoading());
    final result = await guardAsync(() => myPageRepository.fetchLikedPlaces());
    state = state.copyWith(likedPlaces: result);
  }

  /// 다음 페이지를 이어 붙인다(무한 스크롤). 더 없으면 아무 것도 하지 않는다.
  Future<void> loadMoreSavedCourses() async {
    final current = state.savedCourses?.value;
    if (current == null || !current.hasMore) return;
    if (!_loadingMore.add('courses')) return;
    try {
      final requestedPage = current.pagination.nextPage;
      final next = await guardAsync(
        () => myPageRepository.fetchSavedCourses(
          page: PageQuery(page: requestedPage),
        ),
      );
      final value = next.value;
      if (value == null) return;
      // 대기 중에 목록이 새로고침됐으면(페이지가 되돌아갔으면) 이어 붙이지 않는다.
      final latest = state.savedCourses?.value;
      if (latest == null || latest.pagination.nextPage != requestedPage) return;
      state = state.copyWith(savedCourses: AsyncData(latest.append(value)));
    } finally {
      _loadingMore.remove('courses');
    }
  }

  Future<void> loadMoreLikedPlaces() async {
    final current = state.likedPlaces?.value;
    if (current == null || !current.hasMore) return;
    if (!_loadingMore.add('likes')) return;
    try {
      final requestedPage = current.pagination.nextPage;
      final next = await guardAsync(
        () => myPageRepository.fetchLikedPlaces(
          page: PageQuery(page: requestedPage),
        ),
      );
      final value = next.value;
      if (value == null) return;
      final latest = state.likedPlaces?.value;
      if (latest == null || latest.pagination.nextPage != requestedPage) return;
      state = state.copyWith(likedPlaces: AsyncData(latest.append(value)));
    } finally {
      _loadingMore.remove('likes');
    }
  }

  /// 닉네임/프로필 이미지 수정. 성공하면 로컬 요약도 즉시 갱신한다.
  /// 중복 닉네임이면 `NICKNAME_DUPLICATE` 가 온다.
  Future<bool> updateProfile({String? nickname, String? profileImg}) async {
    final request = ProfileUpdateRequest(
      nickname: nickname?.trim(),
      profileImg: profileImg,
    );
    if (request.isEmpty) return false;

    state = state.copyWith(profileUpdate: const AsyncLoading());
    final result = await guardAsync(
      () => myPageRepository.updateProfile(request),
    );
    state = state.copyWith(profileUpdate: result);

    final ok = !result.hasError;
    if (ok) {
      final current = state.summary?.value;
      if (current != null) {
        state = state.copyWith(
          summary: AsyncData(
            current.copyWith(
              profile: current.profile.copyWith(
                nickname: request.nickname,
                profileImg: request.profileImg,
              ),
            ),
          ),
        );
      }
    }
    return ok;
  }

  /// 찜 해제 후 목록에서 즉시 제거(서버 재조회 없이 반영).
  void removeLikedPlaceLocally(String placeId) {
    final current = state.likedPlaces?.value;
    if (current == null) return;
    state = state.copyWith(
      likedPlaces: AsyncData(
        Paged(
          items: current.items
              .where((place) => place.placeId != placeId)
              .toList(),
          pagination: current.pagination,
        ),
      ),
    );
  }
}

final myPageProvider = NotifierProvider<MyPageNotifier, MyPageState>(
  MyPageNotifier.new,
);
