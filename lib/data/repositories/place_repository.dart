import 'package:mople_mobile/data/api/api_client.dart';
import 'package:mople_mobile/data/api/api_endpoints.dart';
import 'package:mople_mobile/data/models/models.dart';

/// `GET /search`, `/places/**`, `GET /traffic/congestion` 연동.
class PlaceRepository {
  PlaceRepository._();

  static final PlaceRepository instance = PlaceRepository._();

  /// `POST /places/{placeId}/like` 로 확인된 찜 상태 캐시.
  ///
  /// 명세에 "지금 찜했는지"만 확인하는 엔드포인트가 따로 없어서, 토글 응답과
  /// [MyPageRepository.fetchLikedPlaces] 결과로 채운다.
  ///
  /// **계정에 종속된 값**이므로 로그아웃 시 [clearLikedCache] 로 비워야 한다.
  /// 안 그러면 다른 계정으로 로그인했을 때 이전 사용자의 찜 상태가 남는다.
  final Set<String> _likedPlaceIds = {};

  Future<Paged<SearchResultItem>> search(
    SearchQuery query, {
    PageQuery page = PageQuery.first,
  }) => apiClient.requestPaged(
    'GET',
    ApiEndpoints.search,
    query: {...query.toJson(), ...page.toJson()},
    listKey: 'results',
    parse: SearchResultItem.fromJson,
  );

  /// [origin] 을 주면 서버가 `distanceFromUser` 를 계산해 채워준다.
  Future<PlaceDetail> fetchPlace(String placeId, {GeoPoint? origin}) =>
      apiClient.requestObject(
        'GET',
        ApiEndpoints.place(placeId),
        query: origin == null
            ? null
            : {'latitude': origin.lat, 'longitude': origin.lng},
        parse: PlaceDetail.fromJson,
      );

  Future<PlaceCongestion> fetchPlaceCongestion(String placeId) =>
      apiClient.requestObject(
        'GET',
        ApiEndpoints.placeCongestion(placeId),
        parse: PlaceCongestion.fromJson,
      );

  Future<TrafficCongestion> fetchTraffic(TrafficQuery query) =>
      apiClient.requestObject(
        'GET',
        ApiEndpoints.trafficCongestion,
        // 스키마상 파라미터 이름이 점을 포함한 `origin.lat` 형태다.
        query: {
          'origin.lat': query.origin.lat,
          'origin.lng': query.origin.lng,
          'destination.lat': query.destination.lat,
          'destination.lng': query.destination.lng,
        },
        parse: TrafficCongestion.fromJson,
      );

  /// 토글 후의 찜 상태를 돌려준다.
  Future<bool> toggleLike(String placeId) async {
    final liked = await apiClient.requestObject(
      'POST',
      ApiEndpoints.placeLike(placeId),
      parse: (data) => FlagResult.fromJson(data, 'liked').value,
    );
    if (liked) {
      _likedPlaceIds.add(placeId);
    } else {
      _likedPlaceIds.remove(placeId);
    }
    return liked;
  }

  bool isLiked(String placeId) => _likedPlaceIds.contains(placeId);

  /// `GET /users/me/likes` 결과로 찜 상태 캐시를 맞춘다.
  ///
  /// [replace] 가 true 면(첫 페이지) 캐시를 새로 채우고, false 면(다음 페이지)
  /// 기존 값에 더한다. 매 페이지마다 교체하면 앞 페이지의 찜이 사라진다.
  void syncLikedPlaceIds(Iterable<String> placeIds, {required bool replace}) {
    if (replace) _likedPlaceIds.clear();
    _likedPlaceIds.addAll(placeIds);
  }

  /// 로그아웃 시 호출. 계정이 바뀌어도 이전 찜 상태가 남지 않게 한다.
  void clearLikedCache() => _likedPlaceIds.clear();
}

PlaceRepository get placeRepository => PlaceRepository.instance;
