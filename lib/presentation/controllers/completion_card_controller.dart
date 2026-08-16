import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/data/repositories/repositories.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';

/// 완주 카드(`/cards/**`) 상태.
class CompletionCardState {
  const CompletionCardState({this.cards, this.created, this.shared});

  final AsyncValue<List<CompletionCard>>? cards;
  final AsyncValue<CompletionCardCreateResult>? created;
  final AsyncValue<ShareResult>? shared;

  List<CompletionCard> get items => cards?.value ?? const [];

  CompletionCard? cardOf(String cardId) {
    for (final card in items) {
      if (card.cardId == cardId) return card;
    }
    return null;
  }

  CompletionCardState copyWith({
    AsyncValue<List<CompletionCard>>? cards,
    AsyncValue<CompletionCardCreateResult>? created,
    AsyncValue<ShareResult>? shared,
  }) => CompletionCardState(
    cards: cards ?? this.cards,
    created: created ?? this.created,
    shared: shared ?? this.shared,
  );
}

class CompletionCardNotifier extends Notifier<CompletionCardState> {
  @override
  CompletionCardState build() => const CompletionCardState();

  Future<void> load() async {
    state = state.copyWith(cards: const AsyncLoading());
    final result = await guardAsync(gamificationRepository.fetchCards);
    state = state.copyWith(cards: result);
  }

  /// 완주 카드 생성. 완주하지 않은 코스면 `COURSE_NOT_COMPLETED` 가 온다.
  ///
  /// [userPhoto] 는 서버 필수값이라 비어 있으면 요청을 보내지 않고 먼저 거른다.
  Future<CompletionCardCreateResult?> create({
    required String courseId,
    required String userPhoto,
  }) async {
    final request = CompletionCardCreateRequest(
      courseId: courseId,
      userPhoto: userPhoto,
    );
    if (!request.isValid) {
      state = state.copyWith(
        created: AsyncError(
          ApiError.local(ApiErrorCode.validation, '완주 사진을 첨부해주세요.'),
          StackTrace.current,
        ),
      );
      return null;
    }
    state = state.copyWith(created: const AsyncLoading());
    final result = await guardAsync(
      () => gamificationRepository.createCompletionCard(request),
    );
    state = state.copyWith(created: result);
    if (!result.hasError) await load();
    return result.value;
  }

  Future<ShareResult?> share(String cardId) async {
    state = state.copyWith(shared: const AsyncLoading());
    final result = await guardAsync(
      () => gamificationRepository.shareCard(cardId),
    );
    state = state.copyWith(shared: result);
    return result.value;
  }
}

final completionCardProvider =
    NotifierProvider<CompletionCardNotifier, CompletionCardState>(
      CompletionCardNotifier.new,
    );
