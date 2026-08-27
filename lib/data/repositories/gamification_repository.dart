import 'package:mople_mobile/data/api/api_client.dart';
import 'package:mople_mobile/data/api/api_endpoints.dart';
import 'package:mople_mobile/data/models/models.dart';

/// `/stamps/**`, `/cards/**`, `GET /courses/unlocked` 연동.
class GamificationRepository {
  GamificationRepository._();

  static final GamificationRepository instance = GamificationRepository._();

  Future<StampBook> fetchStampBook() => apiClient.requestObject(
    'GET',
    ApiEndpoints.stamps,
    parse: StampBook.fromJson,
  );

  Future<StampCheckInResult> checkIn(StampCheckInRequest request) =>
      apiClient.requestObject(
        'POST',
        ApiEndpoints.stampCheckIn,
        body: request.toJson(),
        parse: StampCheckInResult.fromJson,
      );

  Future<List<CompletionCard>> fetchCards() => apiClient.requestList(
    'GET',
    ApiEndpoints.cards,
    listKey: 'cards',
    parse: CompletionCard.fromJson,
  );

  Future<CompletionCardCreateResult> createCompletionCard(
    CompletionCardCreateRequest request,
  ) => apiClient.requestObject(
    'POST',
    ApiEndpoints.completionCard,
    body: request.toJson(),
    parse: CompletionCardCreateResult.fromJson,
  );

  Future<ShareResult> shareCard(String cardId) => apiClient.requestObject(
    'POST',
    ApiEndpoints.cardShare(cardId),
    parse: ShareResult.fromJson,
  );

  /// `lat`/`lng` 는 서버 필수값이라 위치를 모를 때도 [LocationQuery.fallback] 을 보낸다.
  Future<UnlockStatus> fetchUnlockStatus(LocationQuery? query) =>
      apiClient.requestObject(
        'GET',
        ApiEndpoints.unlockedCourses,
        query: (query ?? LocationQuery.fallback).toJson(),
        parse: UnlockStatus.fromJson,
      );
}

GamificationRepository get gamificationRepository =>
    GamificationRepository.instance;
