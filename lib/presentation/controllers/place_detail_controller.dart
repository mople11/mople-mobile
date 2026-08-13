import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/mock/mock_api.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';

/// 장소 상세 화면 상태.
///
/// - `GET /places/{placeId}` 상세
/// - `GET /places/{placeId}/congestion` 혼잡도
/// - `POST /places/{placeId}/like` 찜 토글
///
/// 로컬 목업 찜 상태를 다루는 `FavoritesNotifier` 와 달리, 여기의 찜은 서버 기준이다.
class PlaceDetailState {
  const PlaceDetailState({
    required this.placeId,
    this.detail,
    this.congestion,
    this.likeAction,
    this.liked = false,
  });

  final String placeId;
  final AsyncValue<PlaceDetail>? detail;
  final AsyncValue<PlaceCongestion>? congestion;
  final AsyncValue<void>? likeAction;

  /// `POST /places/{placeId}/like` 의 `data.liked`.
  final bool liked;

  /// 혼잡도 데이터가 없는 경우(`CONGESTION_DATA_UNAVAILABLE`).
  bool get congestionUnavailable =>
      congestion?.apiError?.code == ApiErrorCode.congestionDataUnavailable ||
      (congestion?.value?.isEmpty ?? false);

  PlaceDetailState copyWith({
    AsyncValue<PlaceDetail>? detail,
    AsyncValue<PlaceCongestion>? congestion,
    AsyncValue<void>? likeAction,
    bool? liked,
  }) => PlaceDetailState(
    placeId: placeId,
    detail: detail ?? this.detail,
    congestion: congestion ?? this.congestion,
    likeAction: likeAction ?? this.likeAction,
    liked: liked ?? this.liked,
  );
}

class PlaceDetailNotifier extends Notifier<PlaceDetailState> {
  PlaceDetailNotifier(this.placeId);

  final String placeId;

  @override
  PlaceDetailState build() {
    Future.microtask(load);
    return PlaceDetailState(placeId: placeId, liked: mockApi.isLiked(placeId));
  }

  Future<void> load() async {
    await Future.wait([loadDetail(), loadCongestion()]);
  }

  Future<void> loadDetail() async {
    state = state.copyWith(detail: const AsyncLoading());
    state = state.copyWith(
      detail: await guardAsync(() => mockApi.fetchPlace(placeId)),
    );
  }

  Future<void> loadCongestion() async {
    state = state.copyWith(congestion: const AsyncLoading());
    state = state.copyWith(
      congestion: await guardAsync(() => mockApi.fetchPlaceCongestion(placeId)),
    );
  }

  /// 서버 응답을 기다리는 동안 먼저 UI 를 뒤집고, 실패하면 되돌린다.
  Future<void> toggleLike() async {
    final previous = state.liked;
    state = state.copyWith(liked: !previous, likeAction: const AsyncLoading());
    final result = await guardAsync(() => mockApi.toggleLike(placeId));
    state = state.copyWith(
      likeAction: result,
      liked: result.hasError ? previous : (result.value ?? previous),
    );
  }
}

final placeDetailProvider = NotifierProvider.autoDispose
    .family<PlaceDetailNotifier, PlaceDetailState, String>(
      PlaceDetailNotifier.new,
    );
