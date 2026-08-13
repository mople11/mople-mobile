import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/mock/mock_api.dart';
import 'package:mople_mobile/data/models/models.dart';
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
    state = state.copyWith(cards: await guardAsync(mockApi.fetchCards));
  }

  /// 완주 카드 생성. 완주하지 않은 코스면 `COURSE_NOT_COMPLETED` 가 온다.
  Future<CompletionCardCreateResult?> create({
    required String courseId,
    String? userPhoto,
  }) async {
    final request = CompletionCardCreateRequest(
      courseId: courseId,
      userPhoto: userPhoto,
    );
    state = state.copyWith(created: const AsyncLoading());
    final result = await guardAsync(
      () => mockApi.createCompletionCard(request),
    );
    state = state.copyWith(created: result);
    if (!result.hasError) await load();
    return result.value;
  }

  Future<ShareResult?> share(String cardId) async {
    state = state.copyWith(shared: const AsyncLoading());
    final result = await guardAsync(() => mockApi.shareCard(cardId));
    state = state.copyWith(shared: result);
    return result.value;
  }
}

final completionCardProvider =
    NotifierProvider<CompletionCardNotifier, CompletionCardState>(
      CompletionCardNotifier.new,
    );
