import 'package:mople_mobile/data/models/common/json_utils.dart';

/// 모든 응답이 공유하는 봉투(envelope).
///
/// ```json
/// { "success": true, "data": { ... }, "error": null }
/// ```
class ApiResponse<T> {
  const ApiResponse({required this.success, this.data, this.error});

  final bool success;
  final T? data;
  final ApiError? error;

  bool get hasData => data != null;
  bool get hasError => error != null;

  /// [parse] 가 null 이면 `data` 를 무시한다(로그아웃처럼 `data: null` 인 응답).
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, [
    T Function(Map<String, dynamic> data)? parse,
  ]) {
    final rawData = json['data'];
    return ApiResponse<T>(
      success: asBool(json['success']),
      data: (parse != null && rawData is Map) ? parse(asMap(rawData)) : null,
      error: json['error'] == null
          ? null
          : ApiError.fromJson(asMap(json['error'])),
    );
  }

  /// `data` 가 `{ "saved": true }` 처럼 단일 값일 때 쓰는 변환기.
  R? mapData<R>(R Function(T data) transform) =>
      data == null ? null : transform(data as T);
}

/// 명세에 error 객체의 필드 구성이 없어 `code`/`message`/`status` 로 가정했다.
/// 실제 서버 포맷이 확정되면 이 클래스만 고치면 된다.
class ApiError {
  const ApiError({required this.code, this.message, this.status});

  final String code;
  final String? message;
  final int? status;

  factory ApiError.fromJson(Map<String, dynamic> json) => ApiError(
    code: asString(json['code'], ApiErrorCode.unknown),
    message: asStringOrNull(json['message']),
    status: json['status'] == null ? null : asInt(json['status']),
  );

  /// 네트워크 예외 등 서버 응답이 아예 없을 때 사용.
  factory ApiError.local(String code, [String? message]) =>
      ApiError(code: code, message: message);

  /// 화면에 그대로 노출할 문구.
  String get displayMessage =>
      message ?? ApiErrorCode.describe(code) ?? '잠시 후 다시 시도해주세요.';

  @override
  String toString() => 'ApiError($code, status: $status, message: $message)';
}

/// 컨트롤러의 `AsyncState.load` 가 잡아서 [ApiError] 로 환원하는 예외.
class ApiException implements Exception {
  const ApiException(this.error);

  final ApiError error;

  @override
  String toString() => 'ApiException(${error.code})';
}

/// 명세에 등장하는 에러 코드 모음. (공통 에러 코드 페이지는 export 에 포함되지 않아
/// 개별 API 에 명시된 코드만 정리했다.)
abstract final class ApiErrorCode {
  // 로컬/미정의
  static const unknown = 'UNKNOWN';
  static const network = 'NETWORK_ERROR';

  /// 아직 repository 연동이 되지 않은 호출(개발 중에만 발생).
  static const notImplemented = 'NOT_IMPLEMENTED';

  // Auth
  static const duplicateId = 'DUPLICATE_ID';
  static const codeMismatch = 'CODE_MISMATCH';
  static const codeExpired = 'CODE_EXPIRED';
  static const emailSendFailed = 'EMAIL_SEND_FAILED';
  static const invalidCredentials = 'INVALID_CREDENTIALS';
  static const oauthFailed = 'OAUTH_FAILED';
  static const userNotFound = 'USER_NOT_FOUND';

  // Home · 검색·정보
  static const weatherFetchFailed = 'WEATHER_FETCH_FAILED';
  static const placeNotFound = 'PLACE_NOT_FOUND';
  static const congestionDataUnavailable = 'CONGESTION_DATA_UNAVAILABLE';
  static const trafficDataUnavailable = 'TRAFFIC_DATA_UNAVAILABLE';

  // 마이페이지
  static const nicknameDuplicate = 'NICKNAME_DUPLICATE';

  // 추천
  static const courseNotFound = 'COURSE_NOT_FOUND';
  static const aiRecommendFailed = 'AI_RECOMMEND_FAILED';
  static const moodRequired = 'MOOD_REQUIRED';
  static const minPlaceRequired = 'MIN_PLACE_REQUIRED';
  static const routeCalcFailed = 'ROUTE_CALC_FAILED';
  static const locationMismatch = 'LOCATION_MISMATCH';

  // 후기·만족도
  static const ratingRequired = 'RATING_REQUIRED';
  static const insufficientData = 'INSUFFICIENT_DATA';

  // 게이미피케이션
  static const outOfRegion = 'OUT_OF_REGION';
  static const alreadyAcquired = 'ALREADY_ACQUIRED';
  static const courseNotCompleted = 'COURSE_NOT_COMPLETED';

  static const Map<String, String> _messages = {
    network: '네트워크 연결을 확인해주세요.',
    notImplemented: '아직 서버와 연동되지 않은 기능입니다.',
    duplicateId: '이미 사용 중인 아이디입니다.',
    codeMismatch: '인증번호가 일치하지 않습니다.',
    codeExpired: '인증번호가 만료되었습니다.',
    emailSendFailed: '메일 발송에 실패했습니다.',
    invalidCredentials: '아이디 또는 비밀번호가 일치하지 않습니다.',
    oauthFailed: '소셜 인증에 실패했습니다.',
    userNotFound: '가입되지 않은 이메일입니다.',
    weatherFetchFailed: '날씨 정보를 불러오지 못했습니다.',
    placeNotFound: '존재하지 않는 장소입니다.',
    congestionDataUnavailable: '혼잡도 정보가 없습니다.',
    trafficDataUnavailable: '현재 교통 정보가 없습니다.',
    nicknameDuplicate: '이미 사용 중인 닉네임입니다.',
    courseNotFound: '존재하지 않는 코스입니다.',
    aiRecommendFailed: '추천 생성에 실패했습니다.',
    moodRequired: '기분을 선택해주세요.',
    minPlaceRequired: '장소를 2개 이상 선택해주세요.',
    routeCalcFailed: '경로 계산에 실패했습니다.',
    locationMismatch: '코스 경로와 위치가 일치하지 않습니다.',
    ratingRequired: '별점을 선택해주세요.',
    insufficientData: '후기 데이터가 부족합니다.',
    outOfRegion: '해당 시군 위치가 아닙니다.',
    alreadyAcquired: '이미 획득한 스탬프입니다.',
    courseNotCompleted: '완주하지 않은 코스입니다.',
  };

  static String? describe(String code) => _messages[code];
}
