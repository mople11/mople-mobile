/// 연동 전까지 쓰는 더미 응답 데이터.
///
/// 모든 값은 **서버가 실제로 내려줄 JSON 그대로**(명세의 `data` 필드 형태)라서,
/// 모델의 `fromJson` 을 그대로 통과한다. 연동 시에는 이 파일만 지우면 된다.
///
/// 무대는 기존 목업(`EodiganamData`)과 같은 전남권이지만, 장소·코스·후기는
/// 전부 겹치지 않는 새 데이터로 채웠다.
abstract final class MockApiData {
  /// 응답 봉투로 감싼다. 실제 클라이언트가 받는 형태를 확인할 때 사용.
  static Map<String, dynamic> ok(Object? data) => {
    'success': true,
    'data': data,
    'error': null,
  };

  static Map<String, dynamic> fail(
    String code, {
    int? status,
    String? message,
  }) => {
    'success': false,
    'data': null,
    'error': {'code': code, 'status': status, 'message': message},
  };

  // ══════════════════════════════════════════════════════════
  // Home
  // ══════════════════════════════════════════════════════════

  /// `GET /weather/current`
  static const Map<String, dynamic> currentWeather = {
    'weatherType': '구름조금',
    'temp': 26,
    'icon': 'partly-cloudy',
  };

  /// `GET /home`
  static const Map<String, dynamic> home = {
    'weather': {'type': '구름조금', 'temp': 26, 'icon': 'partly-cloudy'},
    'recommendedCourses': [
      {
        'courseId': 'course-sinan-purple',
        'name': '신안 퍼플섬 보랏빛 산책',
        'duration': '약 5시간',
        'distance': '12km',
        'thumbnail':
            'https://images.unsplash.com/photo-1499002238440-d264edd596ec?w=800&q=80',
      },
      {
        'courseId': 'course-gangjin-slow',
        'name': '강진 느린 하루',
        'duration': '약 4시간',
        'distance': '18km',
        'thumbnail':
            'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&q=80',
      },
      {
        'courseId': 'course-gokseong-train',
        'name': '곡성 섬진강 기차여행',
        'duration': '약 3시간',
        'distance': '15km',
        'thumbnail':
            'https://images.unsplash.com/photo-1474487548417-781cb71495f3?w=800&q=80',
      },
      {
        'courseId': 'course-haenam-sunset',
        'name': '해남 땅끝 노을 드라이브',
        'duration': '약 4시간',
        'distance': '32km',
        'thumbnail':
            'https://images.unsplash.com/photo-1495954484750-af469f2f9be5?w=800&q=80',
      },
    ],
    'unlockBanner': {'available': true},
  };

  // ══════════════════════════════════════════════════════════
  // Auth
  // ══════════════════════════════════════════════════════════

  /// 로그인 성공 처리되는 데모 계정. 그 외 아이디/비번은 INVALID_CREDENTIALS.
  static const demoLoginId = 'namdo';
  static const demoLoginPw = 'test1234';

  /// 이미 사용 중이라 `available: false` 로 응답할 아이디.
  static const takenIds = <String>['admin', 'test', 'namdo', 'eodiganam'];

  /// 이메일/비밀번호 인증번호. 그 외 값은 CODE_MISMATCH.
  static const demoVerifyCode = '123456';

  /// `POST /auth/login`, `POST /auth/login/social`
  static const Map<String, dynamic> authSession = {
    'accessToken': 'mock.access.token.eyJ1c2VySWQiOiJ1c2VyLTAwNDIifQ',
    'refreshToken': 'mock.refresh.token.4f2b91ce',
    'user': {'id': 'user-0042', 'nickname': '남도한바퀴'},
  };

  /// `POST /auth/signup`
  static const Map<String, dynamic> signupResult = {
    'userId': 'user-0042',
    'accessToken': 'mock.access.token.eyJ1c2VySWQiOiJ1c2VyLTAwNDIifQ',
  };

  // ══════════════════════════════════════════════════════════
  // 검색·정보
  // ══════════════════════════════════════════════════════════

  /// `GET /places/{placeId}` 상세 8건. `GET /search` 결과도 여기서 파생한다.
  static const List<Map<String, dynamic>> placeDetails = [
    {
      'placeId': 'place-sinan-purple',
      'name': '신안 퍼플섬',
      'category': '관광지',
      'description':
          '반월도와 박지도를 잇는 보랏빛 다리와 라벤더 밭. 지붕부터 도로까지 온통 보라색으로 칠해진 섬으로, 6월 라벤더 개화기에 가장 붐빕니다.',
      'address': '전남 신안군 안좌면 두리길 257-13',
      'hours': '09:00 - 18:00 (연중무휴)',
      'images': [
        'https://images.unsplash.com/photo-1499002238440-d264edd596ec?w=800&q=80',
        'https://images.unsplash.com/photo-1468779060412-4049775f1d2b?w=800&q=80',
      ],
      'map': {'lat': 34.7583, 'lng': 126.1042},
      'distanceFromUser': '42.8km',
      'reviewSummary': {'avgRating': 4.6, 'aiSatisfaction': 88},
    },
    {
      'placeId': 'place-gangjin-gaudo',
      'name': '강진 가우도 출렁다리',
      'category': '관광지',
      'description':
          '강진만 한가운데 떠 있는 작은 섬 가우도를 잇는 보행 전용 출렁다리. 섬 둘레를 도는 2.5km 생태탐방로와 짚트랙이 함께 있습니다.',
      'address': '전남 강진군 도암면 신기리 산1',
      'hours': '상시 개방 (짚트랙 09:30 - 17:30)',
      'images': [
        'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&q=80',
      ],
      'map': {'lat': 34.5847, 'lng': 126.7419},
      'distanceFromUser': '18.2km',
      'reviewSummary': {'avgRating': 4.4, 'aiSatisfaction': 81},
    },
    {
      'placeId': 'place-gurye-hwaeomsa',
      'name': '구례 화엄사',
      'category': '관광지',
      'description':
          '지리산 노고단 자락의 천년 고찰. 국보 각황전과 사사자 삼층석탑이 있고, 3월 말 홍매화(흑매)가 필 무렵 사진가들이 몰립니다.',
      'address': '전남 구례군 마산면 화엄사로 539',
      'hours': '07:00 - 18:00',
      'images': [
        'https://images.unsplash.com/photo-1528181304800-259b08848526?w=800&q=80',
        'https://images.unsplash.com/photo-1601823984263-b87b59798b70?w=800&q=80',
      ],
      'map': {'lat': 35.2331, 'lng': 127.4931},
      'distanceFromUser': '56.4km',
      'reviewSummary': {'avgRating': 4.7, 'aiSatisfaction': 91},
    },
    {
      'placeId': 'place-gokseong-train',
      'name': '곡성 섬진강 기차마을',
      'category': '관광지',
      'description':
          '옛 곡성역과 증기기관차를 그대로 살린 테마 공간. 섬진강을 따라 10km 구간을 달리는 증기기관차와 레일바이크가 대표 프로그램입니다.',
      'address': '전남 곡성군 오곡면 기차마을로 232',
      'hours': '09:00 - 18:00 (월요일 휴무)',
      'images': [
        'https://images.unsplash.com/photo-1474487548417-781cb71495f3?w=800&q=80',
      ],
      'map': {'lat': 35.2819, 'lng': 127.2925},
      'distanceFromUser': '38.9km',
      'reviewSummary': {'avgRating': 4.3, 'aiSatisfaction': 79},
    },
    {
      'placeId': 'place-haenam-ttangkkeut',
      'name': '해남 땅끝전망대',
      'category': '관광지',
      'description':
          '한반도 최남단 갈두산 사자봉 정상의 전망대. 모노레일로 올라 다도해 일출과 일몰을 한자리에서 볼 수 있습니다.',
      'address': '전남 해남군 송지면 땅끝마을길 60',
      'hours': '09:00 - 18:00',
      'images': [
        'https://images.unsplash.com/photo-1495954484750-af469f2f9be5?w=800&q=80',
      ],
      'map': {'lat': 34.2967, 'lng': 126.5222},
      'distanceFromUser': '71.5km',
      'reviewSummary': {'avgRating': 4.5, 'aiSatisfaction': 85},
    },
    {
      'placeId': 'place-yeonggwang-baeksu',
      'name': '영광 백수해안도로',
      'category': '관광지',
      'description':
          '칠산 앞바다를 끼고 16.8km 이어지는 드라이브 코스. 노을전시관과 해안 데크길이 이어져 낙조 시간대 방문을 추천합니다.',
      'address': '전남 영광군 백수읍 백암리',
      'hours': '상시 개방',
      'images': [
        'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?w=800&q=80',
      ],
      'map': {'lat': 35.2653, 'lng': 126.3711},
      'distanceFromUser': '88.1km',
      'reviewSummary': {'avgRating': 4.6, 'aiSatisfaction': 87},
    },
    {
      'placeId': 'place-naju-gomtang',
      'name': '나주곰탕 하얀집',
      'category': '맛집',
      'description':
          '1910년 개업한 나주곰탕 노포. 맑은 국물에 양지와 사태를 얹어 내며, 점심 시간대에는 대기가 깁니다.',
      'address': '전남 나주시 금성관길 6-1',
      'hours': '08:00 - 20:00 (첫째·셋째 월요일 휴무)',
      'images': [
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&q=80',
      ],
      'map': {'lat': 35.0294, 'lng': 126.7178},
      'distanceFromUser': '24.6km',
      'reviewSummary': {'avgRating': 4.5, 'aiSatisfaction': 90},
    },
    {
      'placeId': 'place-jangheung-woodland',
      'name': '장흥 편백숲 우드랜드',
      'category': '숙박',
      'description':
          '억불산 자락 편백나무 숲속의 통나무집·황토방 숙소. 목재문화체험관과 말레길 무장애 데크가 이어져 있습니다.',
      'address': '전남 장흥군 장흥읍 우드랜드길 180',
      'hours': '체크인 15:00 / 체크아웃 11:00',
      'images': [
        'https://images.unsplash.com/photo-1449158743715-0a90ebb6d2d8?w=800&q=80',
      ],
      'map': {'lat': 34.6819, 'lng': 126.9256},
      'distanceFromUser': '33.7km',
      'reviewSummary': {'avgRating': 4.8, 'aiSatisfaction': 93},
    },
  ];

  /// `GET /search` 의 `data.results[]` — 상세 데이터에서 파생한 목록 형태.
  static const List<Map<String, dynamic>> searchResults = [
    {
      'id': 'place-sinan-purple',
      'name': '신안 퍼플섬',
      'category': '관광지',
      'location': '신안군 안좌면',
      'rating': 4.6,
      'thumbnail':
          'https://images.unsplash.com/photo-1499002238440-d264edd596ec?w=800&q=80',
    },
    {
      'id': 'place-gangjin-gaudo',
      'name': '강진 가우도 출렁다리',
      'category': '관광지',
      'location': '강진군 도암면',
      'rating': 4.4,
      'thumbnail':
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&q=80',
    },
    {
      'id': 'place-gurye-hwaeomsa',
      'name': '구례 화엄사',
      'category': '관광지',
      'location': '구례군 마산면',
      'rating': 4.7,
      'thumbnail':
          'https://images.unsplash.com/photo-1528181304800-259b08848526?w=800&q=80',
    },
    {
      'id': 'place-gokseong-train',
      'name': '곡성 섬진강 기차마을',
      'category': '관광지',
      'location': '곡성군 오곡면',
      'rating': 4.3,
      'thumbnail':
          'https://images.unsplash.com/photo-1474487548417-781cb71495f3?w=800&q=80',
    },
    {
      'id': 'place-haenam-ttangkkeut',
      'name': '해남 땅끝전망대',
      'category': '관광지',
      'location': '해남군 송지면',
      'rating': 4.5,
      'thumbnail':
          'https://images.unsplash.com/photo-1495954484750-af469f2f9be5?w=800&q=80',
    },
    {
      'id': 'place-yeonggwang-baeksu',
      'name': '영광 백수해안도로',
      'category': '관광지',
      'location': '영광군 백수읍',
      'rating': 4.6,
      'thumbnail':
          'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?w=800&q=80',
    },
    {
      'id': 'place-naju-gomtang',
      'name': '나주곰탕 하얀집',
      'category': '맛집',
      'location': '나주시 금성관길',
      'rating': 4.5,
      'thumbnail':
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&q=80',
    },
    {
      'id': 'place-beolgyo-kkomak',
      'name': '벌교 꼬막정식거리',
      'category': '맛집',
      'location': '보성군 벌교읍',
      'rating': 4.4,
      'thumbnail':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
    },
    {
      'id': 'place-jangheung-woodland',
      'name': '장흥 편백숲 우드랜드',
      'category': '숙박',
      'location': '장흥군 장흥읍',
      'rating': 4.8,
      'thumbnail':
          'https://images.unsplash.com/photo-1449158743715-0a90ebb6d2d8?w=800&q=80',
    },
    {
      'id': 'place-hampyeong-butterfly',
      'name': '함평 나비대축제',
      'category': '축제',
      'location': '함평군 함평읍',
      'rating': 4.2,
      'thumbnail':
          'https://images.unsplash.com/photo-1465146344425-f00d5f5c8f07?w=800&q=80',
    },
    {
      'id': 'place-gwangyang-maehwa',
      'name': '광양 매화축제',
      'category': '축제',
      'location': '광양시 다압면',
      'rating': 4.7,
      'thumbnail':
          'https://images.unsplash.com/photo-1522383225653-ed111181a951?w=800&q=80',
    },
    {
      'id': 'place-jindo-sea',
      'name': '진도 신비의 바닷길',
      'category': '관광지',
      'location': '진도군 고군면',
      'rating': 4.1,
      'thumbnail':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
    },
  ];

  /// `GET /places/{placeId}/congestion` — 장소별 혼잡도.
  static const Map<String, Map<String, dynamic>> placeCongestions = {
    'place-sinan-purple': {
      'level': '혼잡',
      'parkingAvailable': false,
      'hourlyGraph': [
        {'hour': 9, 'level': '여유'},
        {'hour': 11, 'level': '보통'},
        {'hour': 13, 'level': '혼잡'},
        {'hour': 15, 'level': '혼잡'},
        {'hour': 17, 'level': '보통'},
      ],
      'recommendedTime': '오전 9시 - 10시',
    },
    'place-gangjin-gaudo': {
      'level': '여유',
      'parkingAvailable': true,
      'hourlyGraph': [
        {'hour': 9, 'level': '여유'},
        {'hour': 11, 'level': '여유'},
        {'hour': 13, 'level': '보통'},
        {'hour': 15, 'level': '보통'},
        {'hour': 17, 'level': '여유'},
      ],
      'recommendedTime': '지금 방문하기 좋아요',
    },
    'place-naju-gomtang': {
      'level': '혼잡',
      'parkingAvailable': false,
      'hourlyGraph': [
        {'hour': 9, 'level': '여유'},
        {'hour': 11, 'level': '보통'},
        {'hour': 12, 'level': '혼잡'},
        {'hour': 14, 'level': '보통'},
        {'hour': 18, 'level': '혼잡'},
      ],
      'recommendedTime': '오후 2시 - 4시',
    },
  };

  /// 혼잡도 데이터가 없는 장소의 기본값(보통).
  static const Map<String, dynamic> defaultCongestion = {
    'level': '보통',
    'parkingAvailable': true,
    'hourlyGraph': [
      {'hour': 10, 'level': '여유'},
      {'hour': 13, 'level': '보통'},
      {'hour': 16, 'level': '보통'},
      {'hour': 18, 'level': '여유'},
    ],
    'recommendedTime': '오전 10시 전후',
  };

  /// `GET /traffic/congestion`
  static const Map<String, dynamic> trafficCongestion = {
    'segments': [
      {'section': '남해고속도로 순천IC → 벌교IC', 'level': '원활'},
      {'section': '국도 2호선 벌교 → 보성읍', 'level': '서행'},
      {'section': '군도 12호선 강진읍 진입', 'level': '정체'},
    ],
    'etaMin': 47,
    'altRoute': {'available': true, 'etaMin': 39},
  };

  // ══════════════════════════════════════════════════════════
  // 추천 · 코스
  // ══════════════════════════════════════════════════════════

  /// `POST /recommend/ai` — 기분(mood)에 따라 다른 코스를 돌려준다.
  static const Map<String, Map<String, dynamic>> aiRecommendations = {
    'heal': {
      'courseId': 'course-jangheung-forest',
      'name': '장흥 편백숲 반나절 힐링',
      'reason': '‘힐링’ 기분과 도보 이동에 맞춰, 이동 거리가 짧고 그늘이 많은 숲길 위주로 골랐어요.',
      'places': [
        {'placeId': 'place-jangheung-woodland', 'order': 1},
        {'placeId': 'place-gangjin-gaudo', 'order': 2},
      ],
    },
    'photo': {
      'courseId': 'course-sinan-purple',
      'name': '신안 퍼플섬 인생샷 코스',
      'reason': '‘인생샷’ 기분에 맞는 색감 좋은 스팟만 모았어요. 오전 광선이 가장 예쁩니다.',
      'places': [
        {'placeId': 'place-sinan-purple', 'order': 1},
        {'placeId': 'place-yeonggwang-baeksu', 'order': 2},
        {'placeId': 'place-haenam-ttangkkeut', 'order': 3},
      ],
    },
    'food': {
      'courseId': 'course-namdo-food',
      'name': '남도 미식 하루',
      'reason': '‘미식’ 기분 + 자차 이동 기준으로, 웨이팅이 짧은 시간대에 맞춰 순서를 짰어요.',
      'places': [
        {'placeId': 'place-naju-gomtang', 'order': 1},
        {'placeId': 'place-beolgyo-kkomak', 'order': 2},
      ],
    },
  };

  /// 위 목록에 없는 기분일 때 쓰는 기본 추천.
  static const Map<String, dynamic> defaultAiRecommendation = {
    'courseId': 'course-gangjin-slow',
    'name': '강진 느린 하루',
    'reason': '오늘 날씨와 남은 시간을 고려해, 이동 부담이 적은 강진만 일대로 묶었어요.',
    'places': [
      {'placeId': 'place-gangjin-gaudo', 'order': 1},
      {'placeId': 'place-jangheung-woodland', 'order': 2},
      {'placeId': 'place-naju-gomtang', 'order': 3},
    ],
  };

  /// `POST /courses/optimize` 의 `data.route` — 명세상 구조가 비어 있어 임의 구성.
  static const Map<String, dynamic> optimizedRoute = {
    'polyline': 'yjmeF_zwaXkGvA}DrCsBnE',
    'summary': '국도 위주 · 통행료 없음',
    'totalDistanceKm': 27.4,
  };

  /// `GET /users/me/courses`
  static const List<Map<String, dynamic>> savedCourses = [
    {'courseId': 'course-sinan-purple', 'name': '신안 퍼플섬 보랏빛 산책'},
    {'courseId': 'course-gurye-jirisan', 'name': '구례 지리산 자락 사찰 코스'},
    {'courseId': 'course-haenam-sunset', 'name': '해남 땅끝 노을 드라이브'},
  ];

  // ══════════════════════════════════════════════════════════
  // 후기·만족도
  // ══════════════════════════════════════════════════════════

  /// `GET /reviews` — 장소별 후기.
  static const Map<String, List<Map<String, dynamic>>> reviewsByTarget = {
    'place-sinan-purple': [
      {
        'reviewId': 'review-3081',
        'author': '보라돌이',
        'rating': 5,
        'text':
            '라벤더 필 때 갔는데 섬 전체가 보라색이라 어디를 찍어도 그림이었어요. 다리 위는 바람이 세니 모자 조심하세요.',
        'photos': [
          'https://images.unsplash.com/photo-1499002238440-d264edd596ec?w=400&q=80',
          'https://images.unsplash.com/photo-1468779060412-4049775f1d2b?w=400&q=80',
        ],
        'visitWeather': '맑음',
      },
      {
        'reviewId': 'review-3074',
        'author': '정한별',
        'rating': 4,
        'text': '경치는 좋은데 주말 오후엔 주차장이 꽉 차요. 배 시간 확인하고 오전에 들어가는 걸 추천합니다.',
        'photos': [],
        'visitWeather': '구름조금',
      },
      {
        'reviewId': 'review-3060',
        'author': '오시온',
        'rating': 5,
        'text': '보라색 옷 입고 가면 입장료 무료입니다. 섬 한 바퀴 걷는 데 두 시간 정도 걸렸어요.',
        'photos': [
          'https://images.unsplash.com/photo-1468779060412-4049775f1d2b?w=400&q=80',
        ],
        'visitWeather': '맑음',
      },
      {
        'reviewId': 'review-3042',
        'author': '문나래',
        'rating': 3,
        'text': '비 오는 날엔 다리가 미끄러워서 조심해야 해요. 날씨 좋을 때 다시 가보려고요.',
        'photos': [],
        'visitWeather': '비',
      },
    ],
    'place-gangjin-gaudo': [
      {
        'reviewId': 'review-2911',
        'author': '강진사는사람',
        'rating': 5,
        'text': '출렁다리 건너서 섬 둘레길 걷는 코스가 진짜 좋아요. 노을 시간대 강력 추천합니다.',
        'photos': [
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&q=80',
        ],
        'visitWeather': '맑음',
      },
      {
        'reviewId': 'review-2890',
        'author': '주말러',
        'rating': 4,
        'text': '짚트랙은 예약 필수예요. 현장 대기로는 거의 못 탑니다.',
        'photos': [],
        'visitWeather': '흐림',
      },
    ],
    'place-naju-gomtang': [
      {
        'reviewId': 'review-2755',
        'author': '국물러버',
        'rating': 5,
        'text': '국물이 정말 맑고 깊어요. 12시 넘어가면 30분은 기다려야 하니 11시쯤 가세요.',
        'photos': [
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80',
        ],
        'visitWeather': '맑음',
      },
    ],
  };

  /// `GET /reviews/summary` — AI 만족도·키워드 요약.
  static const Map<String, Map<String, dynamic>> reviewSummaries = {
    'place-sinan-purple': {
      'score': 88,
      'keywords': {
        'positive': ['보랏빛 풍경', '포토존', '섬 산책', '친절한 안내'],
        'negative': ['주차 부족', '배 시간', '주말 혼잡'],
      },
    },
    'place-gangjin-gaudo': {
      'score': 81,
      'keywords': {
        'positive': ['노을', '출렁다리', '한적함'],
        'negative': ['짚트랙 예약', '편의시설 부족'],
      },
    },
    'place-naju-gomtang': {
      'score': 90,
      'keywords': {
        'positive': ['맑은 국물', '가성비', '노포 분위기'],
        'negative': ['웨이팅', '주차'],
      },
    },
  };

  /// `GET /users/me/reviews`
  static const List<Map<String, dynamic>> myReviews = [
    {'reviewId': 'review-3081', 'targetName': '신안 퍼플섬', 'rating': 5},
    {'reviewId': 'review-2911', 'targetName': '강진 가우도 출렁다리', 'rating': 5},
    {'reviewId': 'review-2755', 'targetName': '나주곰탕 하얀집', 'rating': 5},
    {'reviewId': 'review-2612', 'targetName': '곡성 섬진강 기차마을', 'rating': 4},
    {'reviewId': 'review-2588', 'targetName': '영광 백수해안도로', 'rating': 5},
  ];

  /// `POST /reviews/{reviewId}/helpful` 직전의 도움돼요 수.
  static const Map<String, int> helpfulCounts = {
    'review-3081': 47,
    'review-3074': 21,
    'review-3060': 33,
    'review-3042': 8,
    'review-2911': 52,
    'review-2890': 14,
    'review-2755': 96,
  };

  // ══════════════════════════════════════════════════════════
  // 마이페이지
  // ══════════════════════════════════════════════════════════

  /// `GET /users/me`
  static const Map<String, dynamic> myPage = {
    'profile': {
      'nickname': '남도한바퀴',
      'profileImg':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
    },
    'stats': {'completedCourses': 7, 'stamps': 9, 'reviews': 12},
  };

  /// `GET /users/me/likes`
  static const List<Map<String, dynamic>> likedPlaces = [
    {'placeId': 'place-sinan-purple', 'name': '신안 퍼플섬'},
    {'placeId': 'place-gurye-hwaeomsa', 'name': '구례 화엄사'},
    {'placeId': 'place-jangheung-woodland', 'name': '장흥 편백숲 우드랜드'},
    {'placeId': 'place-naju-gomtang', 'name': '나주곰탕 하얀집'},
  ];

  // ══════════════════════════════════════════════════════════
  // 게이미피케이션
  // ══════════════════════════════════════════════════════════

  /// 전남 22개 시군 코드 — `GET /stamps` 의 `totalCount: 22` 와 짝이 된다.
  static const List<String> allCityCodes = [
    'mokpo',
    'yeosu',
    'suncheon',
    'naju',
    'gwangyang',
    'damyang',
    'gokseong',
    'gurye',
    'goheung',
    'boseong',
    'hwasun',
    'jangheung',
    'gangjin',
    'haenam',
    'yeongam',
    'muan',
    'hampyeong',
    'yeonggwang',
    'jangseong',
    'wando',
    'jindo',
    'sinan',
  ];

  /// `GET /stamps` — 22개 중 9개 획득.
  static const Map<String, dynamic> stampBook = {
    'collected': [
      'suncheon',
      'yeosu',
      'damyang',
      'boseong',
      'gurye',
      'naju',
      'gokseong',
      'gangjin',
      'sinan',
    ],
    'totalCount': 22,
    'progress': 0.41,
  };

  /// `POST /stamps/checkin` 이 성공할 좌표 반경 안의 시군.
  /// 실제로는 서버가 좌표로 판정하지만, 더미에서는 위도 범위로 흉내 낸다.
  static const Map<String, dynamic> checkInSuccess = {
    'stampAcquired': true,
    'cityCode': 'haenam',
  };

  /// `GET /cards`
  static const List<Map<String, dynamic>> completionCards = [
    {
      'cardId': 'card-0917',
      'courseName': '신안 퍼플섬 보랏빛 산책',
      'date': '2026-06-14',
      'imageUrl':
          'https://images.unsplash.com/photo-1499002238440-d264edd596ec?w=600&q=80',
    },
    {
      'cardId': 'card-0842',
      'courseName': '구례 지리산 자락 사찰 코스',
      'date': '2026-04-02',
      'imageUrl':
          'https://images.unsplash.com/photo-1528181304800-259b08848526?w=600&q=80',
    },
    {
      'cardId': 'card-0770',
      'courseName': '곡성 섬진강 기차여행',
      'date': '2026-03-21',
      'imageUrl':
          'https://images.unsplash.com/photo-1474487548417-781cb71495f3?w=600&q=80',
    },
  ];

  /// `GET /courses/unlocked`
  static const Map<String, dynamic> unlockStatus = {
    'unlockedCourses': [
      {'courseId': 'course-yeonggwang-sunset', 'rarity': 'LEGENDARY'},
      {'courseId': 'course-sinan-purple', 'rarity': 'RARE'},
      {'courseId': 'course-gokseong-train', 'rarity': 'UNCOMMON'},
      {'courseId': 'course-gangjin-slow', 'rarity': 'COMMON'},
    ],
    'lockedCourses': [
      {
        'courseId': 'course-jindo-mystery',
        'unlockCondition': '간조 시간대에 진도 근처에서만 해금돼요',
      },
      {
        'courseId': 'course-gurye-snow',
        'unlockCondition': '눈 내리는 날 구례에서만 해금돼요',
      },
      {'courseId': 'course-haenam-fog', 'unlockCondition': '안개 낀 새벽에만 해금돼요'},
    ],
  };

  // ══════════════════════════════════════════════════════════
  // 공통
  // ══════════════════════════════════════════════════════════

  /// `GET /settings`
  static const Map<String, dynamic> settings = {
    'notifications': {'push': true, 'goldenHour': true},
    'language': 'ko',
    'permissions': {'location': true},
  };
}
