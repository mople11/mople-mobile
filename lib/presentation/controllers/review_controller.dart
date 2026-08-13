import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';

/// 리뷰 화면 하나에서만 쓰이는 페이지 스코프 상태.
/// 작성 폼 상태(별점/글쓰기 여부)와 목록을 함께 들고 있어, 등록한 리뷰가
/// 세션 동안 목록에 실제로 반영되게 한다.
class ReviewState {
  const ReviewState({
    required this.reviews,
    this.writing = false,
    this.rating = 5,
  });

  final List<ReviewItem> reviews;
  final bool writing;
  final int rating;

  ReviewState copyWith({
    List<ReviewItem>? reviews,
    bool? writing,
    int? rating,
  }) => ReviewState(
    reviews: reviews ?? this.reviews,
    writing: writing ?? this.writing,
    rating: rating ?? this.rating,
  );
}

class ReviewNotifier extends Notifier<ReviewState> {
  @override
  ReviewState build() => ReviewState(reviews: [...EodiganamData.reviews]);

  void toggleWriting() => state = state.copyWith(writing: !state.writing);

  void setRating(int value) => state = state.copyWith(rating: value);

  void submit(String body, {required String place}) {
    if (body.trim().isEmpty) return;
    final item = ReviewItem(
      id: DateTime.now().millisecondsSinceEpoch,
      name: EodiganamData.user.name,
      avatar: EodiganamData.user.name,
      rating: state.rating.toDouble(),
      date: '방금 전',
      place: place,
      body: body,
      likes: 0,
      images: 0,
    );
    state = state.copyWith(
      reviews: [item, ...state.reviews],
      rating: 5,
      writing: false,
    );
  }
}

final reviewProvider =
    NotifierProvider.autoDispose<ReviewNotifier, ReviewState>(
      ReviewNotifier.new,
    );
