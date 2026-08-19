import 'package:mople_mobile/data/models/common/geo_point.dart';
import 'package:mople_mobile/data/models/common/json_utils.dart';

/// `GET /search` 의 category 필터.
enum PlaceCategory {
  food('맛집'),
  attraction('관광지'),
  stay('숙박'),
  festival('축제');

  const PlaceCategory(this.value);

  final String value;

  static PlaceCategory? fromValue(String? value) {
    for (final item in values) {
      if (item.value == value) return item;
    }
    return null;
  }
}

/// `GET /places/{placeId}/congestion` 의 혼잡 단계.
enum CongestionLevel {
  relaxed('여유'),
  normal('보통'),
  crowded('혼잡');

  const CongestionLevel(this.value);

  final String value;

  static CongestionLevel? fromValue(String? value) {
    for (final item in values) {
      if (item.value == value) return item;
    }
    return null;
  }
}

/// `GET /traffic/congestion` 의 구간 소통 단계.
enum TrafficLevel {
  smooth('원활'),
  slow('서행'),
  jam('정체'),

  /// 서버가 해당 구간의 소통 정보를 갖고 있지 않을 때 보내는 값.
  /// 명세에는 없지만 실제 응답의 대부분이 이 값이라 정상 값으로 취급한다.
  unknown('정보없음');

  const TrafficLevel(this.value);

  final String value;

  static TrafficLevel? fromValue(String? value) {
    for (final item in values) {
      if (item.value == value) return item;
    }
    return null;
  }
}

/// `GET /search` 쿼리 파라미터.
class SearchQuery {
  const SearchQuery({this.keyword, this.category, this.region, this.sort});

  final String? keyword;
  final PlaceCategory? category;
  final String? region;
  final String? sort;

  Map<String, dynamic> toJson() => compactJson({
    'keyword': keyword,
    'category': category?.value,
    'region': region,
    'sort': sort,
  });

  SearchQuery copyWith({
    String? keyword,
    PlaceCategory? category,
    String? region,
    String? sort,
    bool clearCategory = false,
  }) => SearchQuery(
    keyword: keyword ?? this.keyword,
    category: clearCategory ? null : (category ?? this.category),
    region: region ?? this.region,
    sort: sort ?? this.sort,
  );
}

/// `GET /search` 의 `data.results[]`.
class SearchResultItem {
  const SearchResultItem({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.rating,
    required this.thumbnail,
  });

  final String id;
  final String name;
  final String category;
  final String location;
  final double rating;
  final String thumbnail;

  factory SearchResultItem.fromJson(Map<String, dynamic> json) =>
      SearchResultItem(
        id: asString(json['id']),
        name: asString(json['name']),
        category: asString(json['category']),
        location: asString(json['location']),
        rating: asDouble(json['rating']),
        thumbnail: asString(json['thumbnail']),
      );
}

/// `GET /places/{placeId}` 의 `data.reviewSummary`.
class PlaceReviewSummary {
  const PlaceReviewSummary({
    required this.avgRating,
    required this.aiSatisfaction,
  });

  final double avgRating;
  final double aiSatisfaction;

  factory PlaceReviewSummary.fromJson(Map<String, dynamic> json) =>
      PlaceReviewSummary(
        avgRating: asDouble(json['avgRating']),
        aiSatisfaction: asDouble(json['aiSatisfaction']),
      );
}

/// `GET /places/{placeId}` 의 `data`.
class PlaceDetail {
  const PlaceDetail({
    required this.placeId,
    required this.name,
    required this.category,
    required this.description,
    required this.address,
    required this.hours,
    required this.images,
    required this.map,
    required this.distanceFromUser,
    required this.reviewSummary,
  });

  final String placeId;
  final String name;
  final String category;
  final String description;
  final String address;
  final String hours;
  final List<String> images;
  final GeoPoint? map;
  final String distanceFromUser;
  final PlaceReviewSummary? reviewSummary;

  factory PlaceDetail.fromJson(Map<String, dynamic> json) => PlaceDetail(
    placeId: asString(json['placeId']),
    name: asString(json['name']),
    category: asString(json['category']),
    description: asString(json['description']),
    address: asString(json['address']),
    hours: asString(json['hours']),
    images: asStringList(json['images']),
    map: json['map'] == null ? null : GeoPoint.fromJson(asMap(json['map'])),
    distanceFromUser: asString(json['distanceFromUser']),
    reviewSummary: json['reviewSummary'] == null
        ? null
        : PlaceReviewSummary.fromJson(asMap(json['reviewSummary'])),
  );
}

/// `GET /places/{placeId}/congestion` 의 `data.hourlyGraph[]`.
class HourlyCongestion {
  const HourlyCongestion({required this.hour, required this.level});

  final int hour;
  final String level;

  CongestionLevel? get levelEnum => CongestionLevel.fromValue(level);

  factory HourlyCongestion.fromJson(Map<String, dynamic> json) =>
      HourlyCongestion(
        hour: asInt(json['hour']),
        level: asString(json['level']),
      );
}

/// `GET /places/{placeId}/congestion` 의 `data`.
///
/// 데이터가 없으면 `CONGESTION_DATA_UNAVAILABLE` 과 함께 빈 `data` 가 온다.
class PlaceCongestion {
  const PlaceCongestion({
    required this.level,
    required this.parkingAvailable,
    required this.hourlyGraph,
    required this.recommendedTime,
  });

  final CongestionLevel? level;
  final bool parkingAvailable;
  final List<HourlyCongestion> hourlyGraph;
  final String recommendedTime;

  bool get isEmpty => level == null && hourlyGraph.isEmpty;

  factory PlaceCongestion.fromJson(Map<String, dynamic> json) =>
      PlaceCongestion(
        level: CongestionLevel.fromValue(asStringOrNull(json['level'])),
        parkingAvailable: asBool(json['parkingAvailable']),
        hourlyGraph: asModelList(
          json['hourlyGraph'],
          HourlyCongestion.fromJson,
        ),
        recommendedTime: asString(json['recommendedTime']),
      );
}

/// `GET /traffic/congestion` 쿼리 파라미터.
class TrafficQuery {
  const TrafficQuery({required this.origin, required this.destination});

  final GeoPoint origin;
  final GeoPoint destination;

  Map<String, dynamic> toJson() => {
    'origin': origin.toJson(),
    'destination': destination.toJson(),
  };
}

/// `GET /traffic/congestion` 의 `data.segments[]`.
class TrafficSegment {
  const TrafficSegment({required this.section, required this.level});

  final String section;
  final TrafficLevel? level;

  factory TrafficSegment.fromJson(Map<String, dynamic> json) => TrafficSegment(
    section: asString(json['section']),
    level: TrafficLevel.fromValue(asStringOrNull(json['level'])),
  );
}

/// `GET /traffic/congestion` 의 `data.altRoute`.
class AltRoute {
  const AltRoute({required this.available, required this.etaMin});

  final bool available;
  final int etaMin;

  factory AltRoute.fromJson(Map<String, dynamic> json) => AltRoute(
    available: asBool(json['available']),
    etaMin: asInt(json['etaMin']),
  );
}

/// `GET /traffic/congestion` 의 `data`.
///
/// 데이터가 없으면 `TRAFFIC_DATA_UNAVAILABLE` 과 함께 빈 `data` 가 온다.
class TrafficCongestion {
  const TrafficCongestion({
    required this.segments,
    required this.etaMin,
    required this.altRoute,
  });

  final List<TrafficSegment> segments;
  final int etaMin;
  final AltRoute? altRoute;

  bool get isEmpty => segments.isEmpty && etaMin == 0;

  factory TrafficCongestion.fromJson(Map<String, dynamic> json) =>
      TrafficCongestion(
        segments: asModelList(json['segments'], TrafficSegment.fromJson),
        etaMin: asInt(json['etaMin']),
        altRoute: json['altRoute'] == null
            ? null
            : AltRoute.fromJson(asMap(json['altRoute'])),
      );
}

/// `GET /users/me/likes` 의 `data.places[]`.
class LikedPlace {
  const LikedPlace({required this.placeId, required this.name});

  final String placeId;
  final String name;

  factory LikedPlace.fromJson(Map<String, dynamic> json) => LikedPlace(
    placeId: asString(json['placeId']),
    name: asString(json['name']),
  );
}
