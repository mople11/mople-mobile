import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/data/repositories/repositories.dart';
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
  final AsyncValue<Paged<Review>>? reviews;
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
    AsyncValue<Paged<Review>>? reviews,
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
    final result = await guardAsync(() => reviewRepository.fetchReviews(query));
    state = state.copyWith(reviews: result);
  }

  Future<void> loadSummary() async {
    state = state.copyWith(summary: const AsyncLoading());
    final result = await guardAsync(
      () => reviewRepository.fetchReviewSummary(targetId),
    );
    state = state.copyWith(summary: result);
  }

  Future<void> changeSort(ReviewSort value) async {
    if (state.sort == value) return;
    state = state.copyWith(sort: value);
    await loadReviews();
  }

  /// 다음 페이지를 이어 붙인다(무한 스크롤). 더 없으면 아무 것도 하지 않는다.
  Future<void> loadMoreReviews() async {
    final current = state.reviews?.value;
    if (current == null || !current.hasMore) return;
    final query = ReviewListQuery(targetId: targetId, sort: state.sort);
    final next = await guardAsync(
      () => reviewRepository.fetchReviews(
        query,
        page: PageQuery(page: current.pagination.nextPage),
      ),
    );
    final value = next.value;
    if (value != null) {
      state = state.copyWith(reviews: AsyncData(current.append(value)));
    }
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

  /// 서버로 보내기 전에 필수값을 검증한다.
  ///
  /// 별점과 본문은 실패 사유가 다르므로 각각 다른 메시지를 돌려준다.
  /// 하나로 뭉뚱그리면 이미 채운 별점을 다시 만지게 만든다.
  Future<ReviewCreateResult?> submit() async {
    final request = state.draft;
    final ApiError? invalid = switch (request) {
      _ when request.rating <= 0 => ApiError.local(ApiErrorCode.ratingRequired),
      _ when !request.hasText => ApiError.local(
        ApiErrorCode.validation,
        '후기 내용을 입력해주세요.',
      ),
      _ => null,
    };
    if (invalid != null) {
      state = state.copyWith(
        submitState: AsyncError(invalid, StackTrace.current),
      );
      return null;
    }
    state = state.copyWith(submitState: const AsyncLoading());
    final result = await guardAsync(
      () => reviewRepository.createReview(request),
    );
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
      final count = await reviewRepository.markReviewHelpful(reviewId);
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
      () => reviewRepository.reportReview(reviewId, request),
    );
    state = state.copyWith(reportAction: result);
    return !result.hasError;
  }
}

final reviewBoardProvider = NotifierProvider.autoDispose
    .family<ReviewBoardNotifier, ReviewBoardState, String>(
      ReviewBoardNotifier.new,
    );
