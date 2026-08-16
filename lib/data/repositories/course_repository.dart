import 'package:mople_mobile/data/api/api_client.dart';
import 'package:mople_mobile/data/api/api_endpoints.dart';
import 'package:mople_mobile/data/models/models.dart';

/// `POST /recommend/ai`, `/courses/**` 연동.
class CourseRepository {
  CourseRepository._();

  static final CourseRepository instance = CourseRepository._();

  Future<AiCourseRecommendation> requestAiRecommendation(
    AiRecommendRequest request,
  ) => apiClient.requestObject(
    'POST',
    ApiEndpoints.aiRecommend,
    body: request.toJson(),
    parse: AiCourseRecommendation.fromJson,
  );

  Future<CourseOptimizeResult> optimizeCourse(CourseOptimizeRequest request) =>
      apiClient.requestObject(
        'POST',
        ApiEndpoints.courseOptimize,
        body: request.toJson(),
        parse: CourseOptimizeResult.fromJson,
      );

  Future<CourseStartResult> startCourse(String courseId) =>
      apiClient.requestObject(
        'POST',
        ApiEndpoints.courseStart(courseId),
        parse: CourseStartResult.fromJson,
      );

  Future<void> saveCourse(String courseId) =>
      apiClient.requestVoid('POST', ApiEndpoints.courseSave(courseId));

  Future<ShareResult> shareCourse(String courseId) => apiClient.requestObject(
    'POST',
    ApiEndpoints.courseShare(courseId),
    parse: ShareResult.fromJson,
  );

  Future<CourseCompleteResult> completeCourse(
    String courseId,
    CourseCompleteRequest request,
  ) => apiClient.requestObject(
    'POST',
    ApiEndpoints.courseComplete(courseId),
    body: request.toJson(),
    parse: CourseCompleteResult.fromJson,
  );
}

CourseRepository get courseRepository => CourseRepository.instance;
