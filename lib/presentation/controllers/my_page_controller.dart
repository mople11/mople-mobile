import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/mock/mock_api.dart';
import 'package:mople_mobile/data/models/models.dart';
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
  final AsyncValue<List<SavedCourse>>? savedCourses;
  final AsyncValue<List<MyReview>>? myReviews;
  final AsyncValue<List<LikedPlace>>? likedPlaces;

  /// `PATCH /users/me`
  final AsyncValue<void>? profileUpdate;

  UserProfile get profile => summary?.value?.profile ?? UserProfile.empty;

  UserStats get stats => summary?.value?.stats ?? UserStats.empty;

  MyPageState copyWith({
    AsyncValue<MyPageSummary>? summary,
    AsyncValue<List<SavedCourse>>? savedCourses,
    AsyncValue<List<MyReview>>? myReviews,
    AsyncValue<List<LikedPlace>>? likedPlaces,
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

  Future<void> loadSummary() async {
    state = state.copyWith(summary: const AsyncLoading());
    state = state.copyWith(summary: await guardAsync(mockApi.fetchMe));
  }

  Future<void> loadSavedCourses() async {
    state = state.copyWith(savedCourses: const AsyncLoading());
    state = state.copyWith(
      savedCourses: await guardAsync(mockApi.fetchSavedCourses),
    );
  }

  Future<void> loadMyReviews() async {
    state = state.copyWith(myReviews: const AsyncLoading());
    state = state.copyWith(myReviews: await guardAsync(mockApi.fetchMyReviews));
  }

  Future<void> loadLikedPlaces() async {
    state = state.copyWith(likedPlaces: const AsyncLoading());
    state = state.copyWith(
      likedPlaces: await guardAsync(mockApi.fetchLikedPlaces),
    );
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
    final result = await guardAsync(() => mockApi.updateProfile(request));
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
        current.where((place) => place.placeId != placeId).toList(),
      ),
    );
  }
}

final myPageProvider = NotifierProvider<MyPageNotifier, MyPageState>(
  MyPageNotifier.new,
);
