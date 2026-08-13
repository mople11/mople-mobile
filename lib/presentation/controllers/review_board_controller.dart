import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/mock/mock_api.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';

/// 후기·만족도 범위(`/reviews/**`) 상태.
///
/// 목업 데이터를 쓰는 `ReviewNotifier` 와 달리 서버 응답 모델([Review])을 다룬다.
class ReviewBoardState {
  const ReviewBoardState({
    required this.targetId,
    this.sort = ReviewSort.latest,
    this.reviews,
    this.summary,
    this.draftRating = 0.0,
    this.draftText = '',
    this.draftPhotos = const <String>[],
    this.draftVisitDate,
    this.draftVisitWeather,
    this.submitState,
    this.helpfulAction,
    this.reportAction,
    this.helpfulCounts = const <String, int>{},
  });

  /// 후기 대상(장소 또는 코스) id.
  final String targetId;

  final ReviewSort sort;
  final AsyncValue<List<Review>>? reviews;
  final AsyncValue<ReviewSummary>? summary;

  // ── 작성 폼 ───────────────────────────────────────────────
  final double draftRating;
  final String draftText;
  final List<String> draftPhotos;
  final String? draftVisitDate;
  final String? draftVisitWeather;
  final AsyncValue<ReviewCreateResult>? submitState;

  // ── 도움돼요 / 신고 ───────────────────────────────────────
  final AsyncValue<void>? helpfulAction;
  final AsyncValue<void>? reportAction;

  /// reviewId → 도움돼요 수. 서버가 갱신된 count 만 돌려주므로 로컬에 겹쳐 둔다.
  final Map<String, int> helpfulCounts;

  /// 후기 데이터가 부족한 경우(`INSUFFICIENT_DATA`).
  bool get summaryUnavailable =>
      summary?.apiError?.code == ApiErrorCode.insufficientData ||
      (summary?.value?.isEmpty ?? false);

  ReviewCreateRequest get draft => ReviewCreateRequest(
    targetId: targetId,
    rating: draftRating,
    text: draftText.trim().isEmpty ? null : draftText.trim(),
    photos: draftPhotos.toList(),
    visitDate: draftVisitDate,
    visitWeather: draftVisitWeather,
  );

  int helpfulCountOf(String reviewId) => helpfulCounts[reviewId] ?? 0;

  ReviewBoardState copyWith({
    ReviewSort? sort,
    AsyncValue<List<Review>>? reviews,
    AsyncValue<ReviewSummary>? summary,
    double? draftRating,
    String? draftText,
    List<String>? draftPhotos,
    AsyncValue<ReviewCreateResult>? submitState,
    AsyncValue<void>? helpfulAction,
    AsyncValue<void>? reportAction,
    Map<String, int>? helpfulCounts,
  }) => ReviewBoardState(
    targetId: targetId,
    sort: sort ?? this.sort,
    reviews: reviews ?? this.reviews,
    summary: summary ?? this.summary,
    draftRating: draftRating ?? this.draftRating,
    draftText: draftText ?? this.draftText,
    draftPhotos: draftPhotos ?? this.draftPhotos,
    draftVisitDate: draftVisitDate,
    draftVisitWeather: draftVisitWeather,
    submitState: submitState ?? this.submitState,
    helpfulAction: helpfulAction ?? this.helpfulAction,
    reportAction: reportAction ?? this.reportAction,
    helpfulCounts: helpfulCounts ?? this.helpfulCounts,
  );
}

class ReviewBoardNotifier extends Notifier<ReviewBoardState> {
  ReviewBoardNotifier(this.targetId);

  final String targetId;

  @override
  ReviewBoardState build() {
    Future.microtask(load);
    return ReviewBoardState(targetId: targetId);
  }

  Future<void> load() async {
    await Future.wait([loadReviews(), loadSummary()]);
  }

  Future<void> loadReviews() async {
    final query = ReviewListQuery(targetId: targetId, sort: state.sort);
    state = state.copyWith(reviews: const AsyncLoading());
    state = state.copyWith(
      reviews: await guardAsync(() => mockApi.fetchReviews(query)),
    );
  }

  Future<void> loadSummary() async {
    state = state.copyWith(summary: const AsyncLoading());
    state = state.copyWith(
      summary: await guardAsync(() => mockApi.fetchReviewSummary(targetId)),
    );
  }

  Future<void> changeSort(ReviewSort value) async {
    if (state.sort == value) return;
    state = state.copyWith(sort: value);
    await loadReviews();
  }

  // ── 작성 ─────────────────────────────────────────────────
  void setRating(double value) => state = state.copyWith(draftRating: value);

  void setText(String value) => state = state.copyWith(draftText: value);

  void addPhoto(String url) =>
      state = state.copyWith(draftPhotos: [...state.draftPhotos, url]);

  void removePhoto(String url) => state = state.copyWith(
    draftPhotos: state.draftPhotos.where((p) => p != url).toList(),
  );

  void setVisitDate(String? value) {
    state = ReviewBoardState(
      targetId: targetId,
      sort: state.sort,
      reviews: state.reviews,
      summary: state.summary,
      draftRating: state.draftRating,
      draftText: state.draftText,
      draftPhotos: state.draftPhotos,
      draftVisitDate: value,
      draftVisitWeather: state.draftVisitWeather,
      submitState: state.submitState,
      helpfulAction: state.helpfulAction,
      reportAction: state.reportAction,
      helpfulCounts: state.helpfulCounts,
    );
  }

  void setVisitWeather(String? value) {
    state = ReviewBoardState(
      targetId: targetId,
      sort: state.sort,
      reviews: state.reviews,
      summary: state.summary,
      draftRating: state.draftRating,
      draftText: state.draftText,
      draftPhotos: state.draftPhotos,
      draftVisitDate: state.draftVisitDate,
      draftVisitWeather: value,
      submitState: state.submitState,
      helpfulAction: state.helpfulAction,
      reportAction: state.reportAction,
      helpfulCounts: state.helpfulCounts,
    );
  }

  /// `RATING_REQUIRED` 를 먼저 검증한 뒤 등록한다.
  Future<ReviewCreateResult?> submit() async {
    final request = state.draft;
    if (!request.isValid) {
      state = state.copyWith(
        submitState: AsyncError(
          ApiError.local(ApiErrorCode.ratingRequired),
          StackTrace.current,
        ),
      );
      return null;
    }
    state = state.copyWith(submitState: const AsyncLoading());
    final result = await guardAsync(() => mockApi.createReview(request));
    state = state.copyWith(submitState: result);
    if (result.value != null) {
      clearDraft();
      await loadReviews();
    }
    return result.value;
  }

  void clearDraft() {
    state = ReviewBoardState(
      targetId: targetId,
      sort: state.sort,
      reviews: state.reviews,
      summary: state.summary,
      helpfulAction: state.helpfulAction,
      reportAction: state.reportAction,
      helpfulCounts: state.helpfulCounts,
    );
  }

  // ── 도움돼요 / 신고 ───────────────────────────────────────
  Future<void> markHelpful(String reviewId) async {
    state = state.copyWith(helpfulAction: const AsyncLoading());
    final result = await guardAsync(() async {
      final count = await mockApi.markReviewHelpful(reviewId);
      state = state.copyWith(
        helpfulCounts: {...state.helpfulCounts, reviewId: count},
      );
    });
    state = state.copyWith(helpfulAction: result);
  }

  Future<bool> report(String reviewId, String reason) async {
    final request = ReviewReportRequest(reason: reason);
    state = state.copyWith(reportAction: const AsyncLoading());
    final result = await guardAsync(
      () => mockApi.reportReview(reviewId, request),
    );
    state = state.copyWith(reportAction: result);
    return !result.hasError;
  }
}

final reviewBoardProvider = NotifierProvider.autoDispose
    .family<ReviewBoardNotifier, ReviewBoardState, String>(
      ReviewBoardNotifier.new,
    );
