import 'package:mople_mobile/data/models/common/json_utils.dart';
import 'package:mople_mobile/data/models/course/course_models.dart';

/// `GET /weather/current` 의 `data`.
///
/// 홈 응답(`/home`)은 같은 정보를 `type` 키로 내려주기 때문에
/// [CurrentWeather.fromJson] 은 `weatherType` 과 `type` 을 모두 허용한다.
class CurrentWeather {
  const CurrentWeather({
    required this.weatherType,
    required this.temp,
    required this.icon,
  });

  final String weatherType;
  final int temp;
  final String icon;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) => CurrentWeather(
    weatherType: asString(json['weatherType'] ?? json['type']),
    temp: asInt(json['temp']),
    icon: asString(json['icon']),
  );
}

/// `GET /home` 의 `data.unlockBanner`.
class UnlockBanner {
  const UnlockBanner({required this.available});

  final bool available;

  factory UnlockBanner.fromJson(Map<String, dynamic> json) =>
      UnlockBanner(available: asBool(json['available']));
}

/// `GET /home` 의 `data`.
class HomeData {
  const HomeData({
    required this.weather,
    required this.recommendedCourses,
    required this.unlockBanner,
  });

  final CurrentWeather? weather;
  final List<CourseSummary> recommendedCourses;
  final UnlockBanner? unlockBanner;

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
    weather: json['weather'] == null
        ? null
        : CurrentWeather.fromJson(asMap(json['weather'])),
    recommendedCourses: asModelList(
      json['recommendedCourses'],
      CourseSummary.fromJson,
    ),
    unlockBanner: json['unlockBanner'] == null
        ? null
        : UnlockBanner.fromJson(asMap(json['unlockBanner'])),
  );
}

/// `GET /home`, `GET /weather/current`, `GET /courses/unlocked` 의 쿼리 파라미터.
///
/// 세 엔드포인트 모두 `lat`/`lng` 를 **필수**로 요구한다(빠지면 `COMMON_422`).
/// 위치 권한을 아직 못 받았을 때는 [fallback] 을 보낸다.
class LocationQuery {
  const LocationQuery({required this.lat, required this.lng});

  final double lat;
  final double lng;

  /// 위치를 아직 모를 때 쓰는 기본 좌표 — 전남도청(무안).
  static const fallback = LocationQuery(lat: 34.8161, lng: 126.4630);

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}
