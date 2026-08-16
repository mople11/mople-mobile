import 'package:mople_mobile/data/api/api_client.dart';
import 'package:mople_mobile/data/api/api_endpoints.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/data/repositories/place_repository.dart';

/// `/users/me/**` 연동.
class MyPageRepository {
  MyPageRepository._();

  static final MyPageRepository instance = MyPageRepository._();

  Future<MyPageSummary> fetchMe() =>
      apiClient.requestObject('GET', ApiEndpoints.me, parse: MyPageSummary.fromJson);

  Future<Paged<SavedCourse>> fetchSavedCourses({
    PageQuery page = PageQuery.first,
  }) => apiClient.requestPaged(
    'GET',
    ApiEndpoints.myCourses,
    query: page.toJson(),
    listKey: 'courses',
    parse: SavedCourse.fromJson,
  );

  Future<Paged<MyReview>> fetchMyReviews({
    PageQuery page = PageQuery.first,
  }) => apiClient.requestPaged(
    'GET',
    ApiEndpoints.myReviews,
    query: page.toJson(),
    listKey: 'reviews',
    parse: MyReview.fromJson,
  );

  /// 조회한 찜 목록으로 [PlaceRepository] 의 찜 상태 캐시도 함께 맞춘다.
  Future<Paged<LikedPlace>> fetchLikedPlaces({
    PageQuery page = PageQuery.first,
  }) async {
    final result = await apiClient.requestPaged(
      'GET',
      ApiEndpoints.myLikes,
      query: page.toJson(),
      listKey: 'places',
      parse: LikedPlace.fromJson,
    );
    placeRepository.syncLikedPlaceIds(result.items.map((e) => e.placeId));
    return result;
  }

  Future<void> updateProfile(ProfileUpdateRequest request) =>
      apiClient.requestVoid('PATCH', ApiEndpoints.me, body: request.toJson());
}

MyPageRepository get myPageRepository => MyPageRepository.instance;
