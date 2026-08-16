/// API 명세의 엔드포인트 경로 상수.
///
/// 여기에는 경로/기본 URL 만 둔다. 실제 통신(Dio 클라이언트, 인터셉터, repository)은
/// 연동 단계에서 별도로 추가한다.
abstract final class ApiEndpoints {
  static const localBaseUrl = 'https://eodiganam.duckdns.org/api/v1';

  /// 배포 예정 주소(변경될 수 있음).
  static const remoteBaseUrl = 'https://api-odiganam.duckdns.org/api/v1';

  // ── Home ────────────────────────────────────────────────
  static const home = '/home';
  static const currentWeather = '/weather/current';

  // ── Auth ────────────────────────────────────────────────
  static const signup = '/auth/signup';
  static const signupCheckId = '/auth/signup/check-id';
  static const login = '/auth/login';
  static const socialLogin = '/auth/login/social';
  static const logout = '/auth/logout';
  static const emailVerifyCode = '/auth/email/verify-code';
  static const emailVerifyConfirm = '/auth/email/verify-confirm';
  static const passwordResetRequest = '/auth/password/reset-request';
  static const passwordResetConfirm = '/auth/password/reset-confirm';

  // ── 검색·정보 ────────────────────────────────────────────
  static const search = '/search';
  static const trafficCongestion = '/traffic/congestion';
  static String place(String placeId) => '/places/$placeId';
  static String placeCongestion(String placeId) =>
      '/places/$placeId/congestion';

  // ── 마이페이지 ───────────────────────────────────────────
  static const me = '/users/me';
  static const myCourses = '/users/me/courses';
  static const myReviews = '/users/me/reviews';
  static const myLikes = '/users/me/likes';
  static String placeLike(String placeId) => '/places/$placeId/like';

  // ── 추천 ────────────────────────────────────────────────
  static const aiRecommend = '/recommend/ai';
  static const courseOptimize = '/courses/optimize';
  static String courseStart(String courseId) => '/courses/$courseId/start';
  static String courseSave(String courseId) => '/courses/$courseId/save';
  static String courseComplete(String courseId) =>
      '/courses/$courseId/complete';
  static String courseShare(String courseId) => '/courses/$courseId/share';

  // ── 후기·만족도 ──────────────────────────────────────────
  static const reviews = '/reviews';
  static const reviewSummary = '/reviews/summary';
  static String reviewHelpful(String reviewId) => '/reviews/$reviewId/helpful';
  static String reviewReport(String reviewId) => '/reviews/$reviewId/report';

  // ── 게이미피케이션 ───────────────────────────────────────
  static const stamps = '/stamps';
  static const stampCheckIn = '/stamps/checkin';
  static const cards = '/cards';
  static const completionCard = '/cards/completion';
  static const unlockedCourses = '/courses/unlocked';
  static String cardShare(String cardId) => '/cards/$cardId/share';

  // ── 공통 ────────────────────────────────────────────────
  static const settings = '/settings';
}
