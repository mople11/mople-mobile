import 'package:mople_mobile/data/models/common/geo_point.dart';
import 'package:mople_mobile/data/models/common/json_utils.dart';

/// `POST /recommend/ai` 의 동행자.
enum Companion {
  alone('혼자'),
  couple('커플'),
  family('가족'),
  friend('친구');

  const Companion(this.value);

  final String value;

  static Companion? fromValue(String? value) {
    for (final item in values) {
      if (item.value == value) return item;
    }
    return null;
  }
}

/// `POST /recommend/ai` 의 이동수단.
///
/// 동선 최적화(`/courses/optimize`)는 값 집합이 달라 [RouteTransport] 를 따로 둔다.
/// (명세상 추천은 `자차`, 최적화는 `차량` 을 쓴다.)
enum Transport {
  walk('도보'),
  transit('대중교통'),
  car('자차');

  const Transport(this.value);

  final String value;

  static Transport? fromValue(String? value) {
    for (final item in values) {
      if (item.value == value) return item;
    }
    return null;
  }
}

/// `POST /courses/optimize` 의 이동수단.
enum RouteTransport {
  walk('도보'),
  car('차량'),
  transit('대중교통');

  const RouteTransport(this.value);

  final String value;

  static RouteTransport? fromValue(String? value) {
    for (final item in values) {
      if (item.value == value) return item;
    }
    return null;
  }
}

/// `GET /home` 의 `data.recommendedCourses[]`.
class CourseSummary {
  const CourseSummary({
    required this.courseId,
    required this.name,
    required this.duration,
    required this.distance,
    required this.thumbnail,
  });

  final String courseId;
  final String name;
  final String duration;
  final String distance;
  final String thumbnail;

  factory CourseSummary.fromJson(Map<String, dynamic> json) => CourseSummary(
    courseId: asString(json['courseId']),
    name: asString(json['name']),
    duration: asString(json['duration']),
    distance: asString(json['distance']),
    thumbnail: asString(json['thumbnail']),
  );
}

/// `GET /users/me/courses` 의 `data.courses[]`.
class SavedCourse {
  const SavedCourse({required this.courseId, required this.name});

  final String courseId;
  final String name;

  factory SavedCourse.fromJson(Map<String, dynamic> json) => SavedCourse(
    courseId: asString(json['courseId']),
    name: asString(json['name']),
  );
}

/// `POST /recommend/ai` 요청 바디.
class AiRecommendRequest {
  const AiRecommendRequest({
    required this.mood,
    this.companion,
    this.transport,
    this.timeAvailable,
    this.freeText,
  });

  final String mood;
  final Companion? companion;
  final Transport? transport;
  final String? timeAvailable;
  final String? freeText;

  Map<String, dynamic> toJson() => compactJson({
    'mood': mood,
    'companion': companion?.value,
    'transport': transport?.value,
    'timeAvailable': timeAvailable,
    'freeText': freeText,
  });

  AiRecommendRequest copyWith({
    String? mood,
    Companion? companion,
    Transport? transport,
    String? timeAvailable,
    String? freeText,
  }) => AiRecommendRequest(
    mood: mood ?? this.mood,
    companion: companion ?? this.companion,
    transport: transport ?? this.transport,
    timeAvailable: timeAvailable ?? this.timeAvailable,
    freeText: freeText ?? this.freeText,
  );
}

/// AI 추천 결과의 `places[]` — 방문 순서가 매겨진 장소.
class CoursePlaceOrder {
  const CoursePlaceOrder({required this.placeId, required this.order});

  final String placeId;
  final int order;

  factory CoursePlaceOrder.fromJson(Map<String, dynamic> json) =>
      CoursePlaceOrder(
        placeId: asString(json['placeId']),
        order: asInt(json['order']),
      );
}

/// `POST /recommend/ai` 의 `data`.
class AiCourseRecommendation {
  const AiCourseRecommendation({
    required this.courseId,
    required this.name,
    required this.reason,
    required this.places,
  });

  final String courseId;
  final String name;
  final String reason;
  final List<CoursePlaceOrder> places;

  factory AiCourseRecommendation.fromJson(Map<String, dynamic> json) =>
      AiCourseRecommendation(
        courseId: asString(json['courseId']),
        name: asString(json['name']),
        reason: asString(json['reason']),
        places: asModelList(json['places'], CoursePlaceOrder.fromJson),
      );
}

/// `POST /courses/optimize` 요청 바디.
class CourseOptimizeRequest {
  const CourseOptimizeRequest({
    required this.placeIds,
    required this.transport,
  });

  final List<String> placeIds;
  final RouteTransport transport;

  /// 명세의 `MIN_PLACE_REQUIRED` 를 클라이언트에서 미리 걸러내기 위한 검증.
  bool get isValid => placeIds.length >= 2;

  Map<String, dynamic> toJson() => {
    'placeIds': placeIds,
    'transport': transport.value,
  };
}

/// `POST /courses/optimize` 의 `data`.
///
/// `route` 는 명세에 구조가 비어 있어(`{}`) 원본 Map 그대로 보관한다.
class CourseOptimizeResult {
  const CourseOptimizeResult({
    required this.orderedPlaces,
    required this.segmentTimes,
    required this.totalTime,
    required this.route,
  });

  final List<String> orderedPlaces;
  final List<int> segmentTimes;
  final int totalTime;
  final Map<String, dynamic> route;

  factory CourseOptimizeResult.fromJson(Map<String, dynamic> json) =>
      CourseOptimizeResult(
        orderedPlaces: asStringList(json['orderedPlaces']),
        segmentTimes: asIntList(json['segmentTimes']),
        totalTime: asInt(json['totalTime']),
        route: asMap(json['route']),
      );
}

/// `POST /courses/{courseId}/start` 의 `data`.
class CourseStartResult {
  const CourseStartResult({required this.startedAt});

  final DateTime? startedAt;

  factory CourseStartResult.fromJson(Map<String, dynamic> json) =>
      CourseStartResult(startedAt: asDateTime(json['startedAt']));
}

/// `POST /courses/{courseId}/complete` 요청 바디.
class CourseCompleteRequest {
  const CourseCompleteRequest({required this.checkInLocations});

  final List<GeoPoint> checkInLocations;

  Map<String, dynamic> toJson() => {
    'checkInLocations': checkInLocations.map((e) => e.toJson()).toList(),
  };
}

/// `POST /courses/{courseId}/complete` 의 `data`.
class CourseCompleteResult {
  const CourseCompleteResult({required this.completed, this.cardId});

  final bool completed;
  /// 스키마상 nullable — 완주는 됐지만 카드가 아직 안 만들어진 경우가 있다.
  final String? cardId;

  factory CourseCompleteResult.fromJson(Map<String, dynamic> json) =>
      CourseCompleteResult(
        completed: asBool(json['completed']),
        cardId: asStringOrNull(json['cardId']),
      );
}
