import 'package:mople_mobile/data/models/common/json_utils.dart';

/// `GET /reviews` 의 정렬 옵션.
enum ReviewSort {
  latest('latest'),
  rating('rating');

  const ReviewSort(this.value);

  final String value;

  static ReviewSort? fromValue(String? value) {
    for (final item in values) {
      if (item.value == value) return item;
    }
    return null;
  }
}

/// `GET /reviews` 쿼리 파라미터.
class ReviewListQuery {
  const ReviewListQuery({
    required this.targetId,
    this.sort = ReviewSort.latest,
  });

  final String targetId;
  final ReviewSort sort;

  Map<String, dynamic> toJson() => {'targetId': targetId, 'sort': sort.value};
}

/// `GET /reviews` 의 `data.reviews[]`.
class Review {
  const Review({
    required this.reviewId,
    required this.author,
    required this.rating,
    required this.text,
    required this.photos,
    required this.visitWeather,
  });

  final String reviewId;
  final String author;
  final double rating;
  final String text;
  final List<String> photos;
  final String visitWeather;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    reviewId: asString(json['reviewId']),
    author: asString(json['author']),
    rating: asDouble(json['rating']),
    text: asString(json['text']),
    photos: asStringList(json['photos']),
    visitWeather: asString(json['visitWeather']),
  );
}

/// `GET /users/me/reviews` 의 `data.reviews[]`.
class MyReview {
  const MyReview({
    required this.reviewId,
    required this.targetName,
    required this.rating,
  });

  final String reviewId;
  final String targetName;
  final double rating;

  factory MyReview.fromJson(Map<String, dynamic> json) => MyReview(
    reviewId: asString(json['reviewId']),
    targetName: asString(json['targetName']),
    rating: asDouble(json['rating']),
  );
}

/// `POST /reviews` 요청 바디.
class ReviewCreateRequest {
  const ReviewCreateRequest({
    required this.targetId,
    required this.rating,
    this.text,
    this.photos = const <String>[],
    this.visitDate,
    this.visitWeather,
  });

  final String targetId;
  final double rating;
  final String? text;
  final List<String> photos;
  final String? visitDate;
  final String? visitWeather;

  /// 명세의 `RATING_REQUIRED` 를 클라이언트에서 먼저 거른다.
  bool get isValid => rating > 0 && hasText;

  /// 서버 스키마상 `text` 는 필수이고 `minLength: 1` 이라 빈 문자열도 거절된다.
  bool get hasText => (text ?? '').trim().isNotEmpty;

  Map<String, dynamic> toJson() => compactJson({
    // 서버는 targetId 를 integer 로 받는다. 숫자가 아니면 원본을 그대로 넘긴다.
    'targetId': int.tryParse(targetId) ?? targetId,
    // rating 도 integer 라 소수점을 반올림해 보낸다.
    'rating': rating.round(),
    // 필수 필드이므로 compactJson 에 걸러지지 않도록 항상 채워 보낸다.
    'text': text?.trim() ?? '',
    'photos': photos.isEmpty ? null : photos,
    'visitDate': visitDate,
    'visitWeather': visitWeather,
  });

  ReviewCreateRequest copyWith({
    String? targetId,
    double? rating,
    String? text,
    List<String>? photos,
    String? visitDate,
    String? visitWeather,
  }) => ReviewCreateRequest(
    targetId: targetId ?? this.targetId,
    rating: rating ?? this.rating,
    text: text ?? this.text,
    photos: photos ?? this.photos,
    visitDate: visitDate ?? this.visitDate,
    visitWeather: visitWeather ?? this.visitWeather,
  );
}

/// `POST /reviews` 의 `data`.
class ReviewCreateResult {
  const ReviewCreateResult({required this.reviewId});

  final String reviewId;

  factory ReviewCreateResult.fromJson(Map<String, dynamic> json) =>
      ReviewCreateResult(reviewId: asString(json['reviewId']));
}

/// `POST /reviews/{reviewId}/report` 요청 바디.
class ReviewReportRequest {
  const ReviewReportRequest({required this.reason});

  final String reason;

  Map<String, dynamic> toJson() => {'reason': reason};
}

/// `POST /reviews/{reviewId}/helpful` 의 `data`.
class ReviewHelpfulResult {
  const ReviewHelpfulResult({required this.count});

  final int count;

  factory ReviewHelpfulResult.fromJson(Map<String, dynamic> json) =>
      ReviewHelpfulResult(count: asInt(json['count']));
}

/// `GET /reviews/summary` 의 `data.keywords`.
class ReviewKeywords {
  const ReviewKeywords({required this.positive, required this.negative});

  final List<String> positive;
  final List<String> negative;

  factory ReviewKeywords.fromJson(Map<String, dynamic> json) => ReviewKeywords(
    positive: asStringList(json['positive']),
    negative: asStringList(json['negative']),
  );
}

/// `GET /reviews/summary` 의 `data`.
///
/// 후기가 부족하면 `INSUFFICIENT_DATA` 와 함께 빈 `data` 가 온다.
class ReviewSummary {
  const ReviewSummary({required this.score, required this.keywords});

  final double score;
  final ReviewKeywords? keywords;

  bool get isEmpty =>
      score == 0 &&
      (keywords == null ||
          (keywords!.positive.isEmpty && keywords!.negative.isEmpty));

  factory ReviewSummary.fromJson(Map<String, dynamic> json) => ReviewSummary(
    score: asDouble(json['score']),
    keywords: json['keywords'] == null
        ? null
        : ReviewKeywords.fromJson(asMap(json['keywords'])),
  );
}
