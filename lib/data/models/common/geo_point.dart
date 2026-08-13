import 'package:mople_mobile/data/models/common/json_utils.dart';

/// `{ "lat": 0.0, "lng": 0.0 }` — 위경도 좌표.
class GeoPoint {
  const GeoPoint({required this.lat, required this.lng});

  final double lat;
  final double lng;

  factory GeoPoint.fromJson(Map<String, dynamic> json) =>
      GeoPoint(lat: asDouble(json['lat']), lng: asDouble(json['lng']));

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};

  @override
  bool operator ==(Object other) =>
      other is GeoPoint && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);

  @override
  String toString() => 'GeoPoint($lat, $lng)';
}

/// 단순 플래그(`{ "sent": true }`, `{ "saved": true }` …) 응답 바디.
class FlagResult {
  const FlagResult(this.value);

  final bool value;

  /// `data` 에서 [key] 를 읽어 플래그를 만든다.
  factory FlagResult.fromJson(Map<String, dynamic> json, String key) =>
      FlagResult(asBool(json[key]));

  @override
  String toString() => 'FlagResult($value)';
}

/// 공유 URL 을 돌려주는 응답(`/courses/{id}/share`, `/cards/{id}/share`).
class ShareResult {
  const ShareResult({required this.shareUrl});

  final String shareUrl;

  factory ShareResult.fromJson(Map<String, dynamic> json) =>
      ShareResult(shareUrl: asString(json['shareUrl']));
}
