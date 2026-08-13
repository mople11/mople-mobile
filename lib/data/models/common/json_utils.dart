/// JSON 파싱 헬퍼.
///
/// 서버 응답이 명세와 미세하게 달라도(`0` ↔ `"0"`, null 누락 등) 앱이 죽지 않도록
/// 모든 모델의 `fromJson` 은 이 헬퍼를 통해 값을 읽는다.
library;

String asString(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}

String? asStringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  return value.toString();
}

int asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double asDouble(dynamic value, [double fallback = 0]) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

bool asBool(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    if (lower == 'true') return true;
    if (lower == 'false') return false;
  }
  return fallback;
}

/// ISO8601 문자열을 파싱한다. 명세의 `"startedAt": "ISO8601"` 같은 필드에 사용.
DateTime? asDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

Map<String, dynamic> asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
  return const <String, dynamic>{};
}

Map<String, dynamic>? asMapOrNull(dynamic value) {
  if (value == null) return null;
  if (value is Map) return asMap(value);
  return null;
}

List<String> asStringList(dynamic value) {
  if (value is! List) return const <String>[];
  return value.map((e) => asString(e)).where((e) => e.isNotEmpty).toList();
}

List<int> asIntList(dynamic value) {
  if (value is! List) return const <int>[];
  return value.map((e) => asInt(e)).toList();
}

/// 리스트 필드를 모델 리스트로 변환한다. 요소가 Map 이 아니면 조용히 건너뛴다.
List<T> asModelList<T>(
  dynamic value,
  T Function(Map<String, dynamic> json) parse,
) {
  if (value is! List) return <T>[];
  return value
      .whereType<Map>()
      .map((e) => parse(asMap(e)))
      .toList(growable: true);
}

/// null 값을 제거한 요청 바디를 만든다. PATCH 처럼 부분 전송이 필요한 곳에 사용.
Map<String, dynamic> compactJson(Map<String, dynamic> json) {
  final result = <String, dynamic>{};
  json.forEach((key, value) {
    if (value != null) result[key] = value;
  });
  return result;
}
