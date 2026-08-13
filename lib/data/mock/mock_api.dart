import 'package:mople_mobile/data/mock/mock_api_data.dart';
import 'package:mople_mobile/data/models/models.dart';

/// 연동 전까지 컨트롤러가 호출하는 가짜 API.
///
/// [MockApiData] 의 JSON 을 **실제 모델의 `fromJson` 으로 파싱해서** 돌려주기 때문에,
/// 나중에 진짜 repository 로 바꿔도 화면 쪽 코드는 그대로 동작한다.
/// 인위적인 지연을 넣어 로딩 상태도 화면에서 확인할 수 있다.
///
/// 연동 시: 컨트롤러의 `mockApi.xxx(...)` 를 `xxxRepository.xxx(...)` 로 교체하고
/// `lib/data/mock/` 을 삭제하면 된다.
class MockApi {
  MockApi._();

  static final MockApi instance = MockApi._();

  /// 응답 지연. 테스트에서는 `Duration.zero` 로 바꿔 쓴다.
  Duration latency = const Duration(milliseconds: 450);

  // ── 세션 동안만 유지되는 가변 상태 ─────────────────────────
  final Set<String> _likedPlaces = {
    for (final place in MockApiData.likedPlaces) place['placeId'] as String,
  };
  final Set<String> _savedCourses = {
    for (final course in MockApiData.savedCourses) course['courseId'] as String,
  };
  final Set<String> _collectedStamps = {
    ...MockApiData.stampBook['collected'] as List<dynamic>,
  }.cast<String>();
  final Map<String, List<Map<String, dynamic>>> _reviews = {
    for (final entry in MockApiData.reviewsByTarget.entries)
      entry.key: [...entry.value],
  };
  final Map<String, int> _helpfulCounts = {...MockApiData.helpfulCounts};
  final List<Map<String, dynamic>> _cards = [...MockApiData.completionCards];
  Map<String, dynamic> _settings = {...MockApiData.settings};
  Map<String, dynamic> _profile = asMap(MockApiData.myPage['profile']);

  /// courseId → 코스 이름. 저장·완주 카드에서 id 만 넘어와도 이름을 붙일 수 있게 모아둔다.
  final Map<String, String> _courseNames = {
    for (final course in MockApiData.savedCourses)
      course['courseId'] as String: course['name'] as String,
    for (final course
        in MockApiData.home['recommendedCourses'] as List<dynamic>)
      asMap(course)['courseId'] as String: asMap(course)['name'] as String,
    for (final entry in MockApiData.aiRecommendations.values)
      entry['courseId'] as String: entry['name'] as String,
    MockApiData.defaultAiRecommendation['courseId'] as String:
        MockApiData.defaultAiRecommendation['name'] as String,
  };

  int _sequence = 0;

  String _nextId(String prefix) => '$prefix-${++_sequence + 9000}';

  String _courseName(String courseId) => _courseNames[courseId] ?? courseId;

  Future<T> _respond<T>(T Function() build) async {
    await Future<void>.delayed(latency);
    return build();
  }

  Future<T> _reject<T>(String code, {int? status}) async {
    await Future<void>.delayed(latency);
    throw ApiException(ApiError(code: code, status: status));
  }

  // ══════════════════════════════════════════════════════════
  // Home
  // ══════════════════════════════════════════════════════════

  Future<HomeData> fetchHome(LocationQuery? query) =>
      _respond(() => HomeData.fromJson(MockApiData.home));

  Future<CurrentWeather> fetchCurrentWeather(LocationQuery? query) =>
      _respond(() => CurrentWeather.fromJson(MockApiData.currentWeather));

  // ══════════════════════════════════════════════════════════
  // Auth
  // ══════════════════════════════════════════════════════════

  Future<bool> checkId(String id) =>
      _respond(() => !MockApiData.takenIds.contains(id.toLowerCase()));

  Future<void> sendEmailCode(EmailRequest request) => _respond(() {});

  Future<void> confirmEmailCode(EmailVerifyConfirmRequest request) {
    if (request.code != MockApiData.demoVerifyCode) {
      return _reject(ApiErrorCode.codeMismatch, status: 400);
    }
    return _respond(() {});
  }

  Future<SignupResult> signup(SignupRequest request) {
    if (MockApiData.takenIds.contains(request.id.toLowerCase())) {
      return _reject(ApiErrorCode.duplicateId, status: 409);
    }
    if (request.verifyCode != MockApiData.demoVerifyCode) {
      return _reject(ApiErrorCode.codeMismatch, status: 400);
    }
    return _respond(() => SignupResult.fromJson(MockApiData.signupResult));
  }

  Future<AuthSession> login(LoginRequest request) {
    final matched =
        request.id == MockApiData.demoLoginId &&
        request.pw == MockApiData.demoLoginPw;
    if (!matched) {
      return _reject(ApiErrorCode.invalidCredentials, status: 401);
    }
    return _respond(() => AuthSession.fromJson(MockApiData.authSession));
  }

  Future<AuthSession> loginWithSocial(SocialLoginRequest request) {
    if (request.oauthToken.isEmpty) {
      return _reject(ApiErrorCode.oauthFailed, status: 401);
    }
    return _respond(() => AuthSession.fromJson(MockApiData.authSession));
  }

  Future<void> logout() => _respond(() {});

  Future<void> requestPasswordReset(EmailRequest request) {
    if (!request.email.contains('@')) {
      return _reject(ApiErrorCode.userNotFound, status: 404);
    }
    return _respond(() {});
  }

  Future<void> confirmPasswordReset(PasswordResetConfirmRequest request) {
    if (request.code != MockApiData.demoVerifyCode) {
      return _reject(ApiErrorCode.codeMismatch, status: 400);
    }
    return _respond(() {});
  }

  // ══════════════════════════════════════════════════════════
  // 검색·정보
  // ══════════════════════════════════════════════════════════

  Future<List<SearchResultItem>> search(SearchQuery query) => _respond(() {
    final keyword = query.keyword?.trim() ?? '';
    final category = query.category?.value;
    var rows = MockApiData.searchResults.where((row) {
      final matchesKeyword =
          keyword.isEmpty ||
          (row['name'] as String).contains(keyword) ||
          (row['location'] as String).contains(keyword);
      final matchesCategory = category == null || row['category'] == category;
      final matchesRegion =
          query.region == null ||
          (row['location'] as String).contains(query.region!);
      return matchesKeyword && matchesCategory && matchesRegion;
    }).toList();

    if (query.sort == 'rating') {
      rows.sort((a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
    }
    return rows.map(SearchResultItem.fromJson).toList();
  });

  Future<PlaceDetail> fetchPlace(String placeId) {
    Map<String, dynamic>? row;
    for (final place in MockApiData.placeDetails) {
      if (place['placeId'] == placeId) row = place;
    }
    if (row == null) return _reject(ApiErrorCode.placeNotFound, status: 404);
    return _respond(() => PlaceDetail.fromJson(row!));
  }

  Future<PlaceCongestion> fetchPlaceCongestion(String placeId) => _respond(
    () => PlaceCongestion.fromJson(
      MockApiData.placeCongestions[placeId] ?? MockApiData.defaultCongestion,
    ),
  );

  Future<TrafficCongestion> fetchTraffic(TrafficQuery query) =>
      _respond(() => TrafficCongestion.fromJson(MockApiData.trafficCongestion));

  // ══════════════════════════════════════════════════════════
  // 마이페이지
  // ══════════════════════════════════════════════════════════

  Future<MyPageSummary> fetchMe() => _respond(
    () => MyPageSummary.fromJson({
      ...MockApiData.myPage,
      'profile': _profile,
      'stats': {
        ...asMap(MockApiData.myPage['stats']),
        'stamps': _collectedStamps.length,
      },
    }),
  );

  Future<List<SavedCourse>> fetchSavedCourses() => _respond(
    () => _savedCourses
        .map(
          (courseId) => SavedCourse.fromJson({
            'courseId': courseId,
            'name': _courseName(courseId),
          }),
        )
        .toList(),
  );

  Future<List<MyReview>> fetchMyReviews() =>
      _respond(() => MockApiData.myReviews.map(MyReview.fromJson).toList());

  Future<List<LikedPlace>> fetchLikedPlaces() => _respond(
    () => MockApiData.likedPlaces
        .where((place) => _likedPlaces.contains(place['placeId']))
        .map(LikedPlace.fromJson)
        .toList(),
  );

  Future<void> updateProfile(ProfileUpdateRequest request) {
    if (request.nickname == '남도한바퀴') {
      return _reject(ApiErrorCode.nicknameDuplicate, status: 409);
    }
    return _respond(() {
      _profile = {
        'nickname': request.nickname ?? _profile['nickname'],
        'profileImg': request.profileImg ?? _profile['profileImg'],
      };
    });
  }

  /// `POST /places/{placeId}/like` — 토글 후의 찜 상태를 돌려준다.
  Future<bool> toggleLike(String placeId) => _respond(() {
    if (!_likedPlaces.remove(placeId)) {
      _likedPlaces.add(placeId);
      return true;
    }
    return false;
  });

  bool isLiked(String placeId) => _likedPlaces.contains(placeId);

  // ══════════════════════════════════════════════════════════
  // 추천 · 코스
  // ══════════════════════════════════════════════════════════

  Future<AiCourseRecommendation> requestAiRecommendation(
    AiRecommendRequest request,
  ) {
    if (request.mood.trim().isEmpty) {
      return _reject(ApiErrorCode.moodRequired, status: 400);
    }
    return _respond(
      () => AiCourseRecommendation.fromJson(
        MockApiData.aiRecommendations[request.mood] ??
            MockApiData.defaultAiRecommendation,
      ),
    );
  }

  Future<CourseOptimizeResult> optimizeCourse(CourseOptimizeRequest request) {
    if (!request.isValid) {
      return _reject(ApiErrorCode.minPlaceRequired, status: 400);
    }
    return _respond(() {
      // 이동수단에 따라 구간 소요시간을 다르게 흉내 낸다.
      final perSegment = switch (request.transport) {
        RouteTransport.walk => 35,
        RouteTransport.transit => 28,
        RouteTransport.car => 16,
      };
      final ordered = [...request.placeIds]..sort();
      final segmentTimes = List<int>.generate(
        ordered.length - 1,
        (index) => perSegment + index * 4,
      );
      return CourseOptimizeResult.fromJson({
        'orderedPlaces': ordered,
        'segmentTimes': segmentTimes,
        'totalTime': segmentTimes.fold<int>(0, (sum, time) => sum + time),
        'route': MockApiData.optimizedRoute,
      });
    });
  }

  Future<CourseStartResult> startCourse(String courseId) => _respond(
    () => CourseStartResult.fromJson({
      'startedAt': DateTime.now().toUtc().toIso8601String(),
    }),
  );

  Future<void> saveCourse(String courseId) =>
      _respond(() => _savedCourses.add(courseId));

  Future<ShareResult> shareCourse(String courseId) => _respond(
    () => ShareResult.fromJson({'shareUrl': 'https://odiganam.kr/c/$courseId'}),
  );

  Future<CourseCompleteResult> completeCourse(
    String courseId,
    CourseCompleteRequest request,
  ) {
    if (request.checkInLocations.isEmpty) {
      return _reject(ApiErrorCode.locationMismatch, status: 400);
    }
    return _respond(
      () => CourseCompleteResult.fromJson({
        'completed': true,
        'cardId': _nextId('card'),
      }),
    );
  }

  // ══════════════════════════════════════════════════════════
  // 후기·만족도
  // ══════════════════════════════════════════════════════════

  Future<List<Review>> fetchReviews(ReviewListQuery query) => _respond(() {
    final rows = [...?_reviews[query.targetId]];
    if (query.sort == ReviewSort.rating) {
      rows.sort((a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
    }
    return rows.map(Review.fromJson).toList();
  });

  Future<ReviewSummary> fetchReviewSummary(String targetId) {
    final row = MockApiData.reviewSummaries[targetId];
    if (row == null) {
      return _reject(ApiErrorCode.insufficientData, status: 200);
    }
    return _respond(() => ReviewSummary.fromJson(row));
  }

  Future<ReviewCreateResult> createReview(ReviewCreateRequest request) {
    if (!request.isValid) {
      return _reject(ApiErrorCode.ratingRequired, status: 400);
    }
    return _respond(() {
      final reviewId = _nextId('review');
      _reviews.putIfAbsent(request.targetId, () => []).insert(0, {
        'reviewId': reviewId,
        'author': _profile['nickname'],
        'rating': request.rating,
        'text': request.text ?? '',
        'photos': request.photos,
        'visitWeather': request.visitWeather ?? '',
      });
      return ReviewCreateResult.fromJson({'reviewId': reviewId});
    });
  }

  /// 갱신된 도움돼요 수를 돌려준다.
  Future<int> markReviewHelpful(String reviewId) => _respond(() {
    final next = (_helpfulCounts[reviewId] ?? 0) + 1;
    _helpfulCounts[reviewId] = next;
    return next;
  });

  Future<void> reportReview(String reviewId, ReviewReportRequest request) =>
      _respond(() {});

  int helpfulCountOf(String reviewId) => _helpfulCounts[reviewId] ?? 0;

  // ══════════════════════════════════════════════════════════
  // 게이미피케이션
  // ══════════════════════════════════════════════════════════

  Future<StampBook> fetchStampBook() => _respond(
    () => StampBook.fromJson({
      'collected': _collectedStamps.toList(),
      'totalCount': MockApiData.allCityCodes.length,
      'progress': _collectedStamps.length / MockApiData.allCityCodes.length,
    }),
  );

  /// 위도 34.2~34.4 를 해남 권역으로 보고 스탬프를 준다. 그 밖이면 OUT_OF_REGION.
  Future<StampCheckInResult> checkIn(StampCheckInRequest request) {
    final inRegion = request.lat >= 34.2 && request.lat <= 34.4;
    if (!inRegion) {
      return _reject(ApiErrorCode.outOfRegion, status: 400);
    }
    return _respond(() {
      const cityCode = 'haenam';
      final acquired = _collectedStamps.add(cityCode);
      return StampCheckInResult.fromJson({
        'stampAcquired': acquired,
        'cityCode': cityCode,
      });
    });
  }

  Future<List<CompletionCard>> fetchCards() =>
      _respond(() => _cards.map(CompletionCard.fromJson).toList());

  Future<CompletionCardCreateResult> createCompletionCard(
    CompletionCardCreateRequest request,
  ) => _respond(() {
    final cardId = _nextId('card');
    const imageUrl =
        'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=600&q=80';
    _cards.insert(0, {
      'cardId': cardId,
      'courseName': _courseName(request.courseId),
      'date': DateTime.now().toIso8601String().split('T').first,
      'imageUrl': imageUrl,
    });
    return CompletionCardCreateResult.fromJson({
      'cardId': cardId,
      'cardImageUrl': imageUrl,
    });
  });

  Future<ShareResult> shareCard(String cardId) => _respond(
    () =>
        ShareResult.fromJson({'shareUrl': 'https://odiganam.kr/card/$cardId'}),
  );

  Future<UnlockStatus> fetchUnlockStatus(LocationQuery? query) =>
      _respond(() => UnlockStatus.fromJson(MockApiData.unlockStatus));

  // ══════════════════════════════════════════════════════════
  // 공통
  // ══════════════════════════════════════════════════════════

  Future<AppSettings> fetchSettings() =>
      _respond(() => AppSettings.fromJson(_settings));

  Future<void> updateSettings(SettingsUpdateRequest request) => _respond(() {
    final patch = request.toJson();
    _settings = {..._settings, ...patch};
  });
}

/// 컨트롤러에서 쓰는 짧은 별칭.
MockApi get mockApi => MockApi.instance;
