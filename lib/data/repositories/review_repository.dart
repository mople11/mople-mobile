import 'package:mople_mobile/data/api/api_client.dart';
import 'package:mople_mobile/data/api/api_endpoints.dart';
import 'package:mople_mobile/data/models/models.dart';

/// `/reviews/**` 연동.
class ReviewRepository {
  ReviewRepository._();

  static final ReviewRepository instance = ReviewRepository._();

  Future<Paged<Review>> fetchReviews(
    ReviewListQuery query, {
    PageQuery page = PageQuery.first,
  }) => apiClient.requestPaged(
    'GET',
    ApiEndpoints.reviews,
    query: {...query.toJson(), ...page.toJson()},
    listKey: 'reviews',
    parse: Review.fromJson,
  );

  Future<ReviewSummary> fetchReviewSummary(String targetId) =>
      apiClient.requestObject(
        'GET',
        ApiEndpoints.reviewSummary,
        query: {'targetId': targetId},
        parse: ReviewSummary.fromJson,
      );

  Future<ReviewCreateResult> createReview(ReviewCreateRequest request) =>
      apiClient.requestObject(
        'POST',
        ApiEndpoints.reviews,
        body: request.toJson(),
        parse: ReviewCreateResult.fromJson,
      );

  /// 갱신된 도움돼요 수를 돌려준다.
  Future<int> markReviewHelpful(String reviewId) => apiClient.requestObject(
    'POST',
    ApiEndpoints.reviewHelpful(reviewId),
    parse: (data) => ReviewHelpfulResult.fromJson(data).count,
  );

  Future<void> reportReview(String reviewId, ReviewReportRequest request) =>
      apiClient.requestVoid(
        'POST',
        ApiEndpoints.reviewReport(reviewId),
        body: request.toJson(),
      );
}

ReviewRepository get reviewRepository => ReviewRepository.instance;
