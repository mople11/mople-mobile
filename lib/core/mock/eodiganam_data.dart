import 'package:mople_mobile/core/widgets/travel/mood_selector.dart';
import 'package:mople_mobile/core/widgets/travel/weather_chip.dart';

/// 어디가남 — 목업 데이터. Claude Design 원본 `EODIGANAM_DATA` 를 그대로 옮겼습니다.

class CongestionInfo {
  const CongestionInfo({
    required this.level,
    required this.parking,
    required this.wait,
    required this.hourly,
    required this.hint,
  });

  final String level; // 여유 · 보통 · 혼잡
  final bool parking;
  final int wait;
  final List<int> hourly;
  final String hint;
}

class Destination {
  const Destination({
    required this.id,
    required this.title,
    required this.region,
    required this.rating,
    required this.reviewCount,
    required this.duration,
    required this.weatherLabel,
    required this.weatherTemp,
    required this.tags,
    required this.image,
    required this.desc,
    this.badge,
    this.congestion,
  });

  final String id;
  final String title;
  final String region;
  final double rating;
  final int reviewCount;
  final String duration;
  final String weatherLabel;
  final int weatherTemp;
  final List<String> tags;
  final String image;
  final String desc;
  final String? badge;
  final CongestionInfo? congestion;
}

class AiRecommendation {
  const AiRecommendation({
    required this.title,
    required this.reason,
    required this.tags,
    required this.match,
    required this.image,
  });

  final String title;
  final String reason;
  final List<String> tags;
  final int match;
  final String image;
}

class ReviewItem {
  const ReviewItem({
    required this.id,
    required this.name,
    required this.avatar,
    required this.rating,
    required this.date,
    required this.place,
    required this.body,
    required this.likes,
    required this.images,
  });

  final int id;
  final String name;
  final String avatar;
  final double rating;
  final String date;
  final String place;
  final String body;
  final int likes;
  final int images;
}

class StampInfo {
  const StampInfo({
    required this.region,
    required this.earned,
    required this.emoji,
    required this.cityCode,
  });

  /// 화면에 보여줄 한글 시군명.
  final String region;

  /// 목업 전용 획득 여부. 서버 연동 화면에서는 `GET /stamps` 의 `collected` 를 쓴다.
  final bool earned;

  final String emoji;

  /// 서버 `collected[]` 와 대조할 시군 코드(로마자).
  ///
  /// 서버가 코드/한글명 중 무엇을 내려주는지 실데이터로 확인하지 못했으므로,
  /// 화면에서는 이 값과 [region] 을 모두 대조한다.
  final String cityCode;
}

class UnlockCourseInfo {
  const UnlockCourseInfo({
    required this.id,
    required this.title,
    required this.rarity,
    required this.requiredWeather,
    required this.condition,
    required this.image,
  });

  final String id;
  final String title;
  final String rarity; // COMMON · UNCOMMON · RARE · LEGENDARY
  final String requiredWeather;
  final String condition;
  final String image;
}

class RouteStepInfo {
  const RouteStepInfo({
    required this.index,
    required this.title,
    required this.time,
    required this.duration,
    required this.transport,
    this.subtitle,
  });

  final int index;
  final String title;
  final String time;
  final String duration;
  final String transport;
  final String? subtitle;
}

class RouteInfo {
  const RouteInfo({
    required this.title,
    required this.summary,
    required this.distance,
    required this.cost,
    required this.steps,
  });

  final String title;
  final String summary;
  final String distance;
  final String cost;
  final List<RouteStepInfo> steps;
}

class UserInfo {
  const UserInfo({
    required this.name,
    required this.email,
    required this.level,
    required this.stamps,
    required this.trips,
    required this.reviews,
  });

  final String name;
  final String email;
  final String level;
  final int stamps;
  final int trips;
  final int reviews;
}

abstract final class EodiganamData {
  EodiganamData._();

  static const String currentWeatherCondition = '맑음';
  static const int currentWeatherTemp = 24;

  static const UserInfo user = UserInfo(
    name: '김여행',
    email: 'traveler@eodiganam.kr',
    level: '여행 탐험가',
    stamps: 12,
    trips: 8,
    reviews: 5,
  );

  static const List<Destination> destinations = [
    Destination(
      id: 'suncheon-garden',
      title: '순천만 국가정원',
      region: '순천시',
      rating: 4.8,
      reviewCount: 3421,
      duration: '약 2시간',
      badge: '인기',
      tags: ['자연', '산책', '가족'],
      weatherLabel: '맑음',
      weatherTemp: 24,
      congestion: CongestionInfo(
        level: '여유',
        parking: true,
        wait: 0,
        hourly: [20, 35, 55, 60, 40, 25],
        hint: '지금 덜 붐비고 있어요. 방문하기 좋은 시간이에요.',
      ),
      image:
          'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800&q=80',
      desc: '순천만의 광활한 정원과 갈대밭이 어우러진 국내 최대 생태 정원입니다. 사계절 내내 다른 풍경을 즐길 수 있어요.',
    ),
    Destination(
      id: 'yeosu-night',
      title: '여수 밤바다',
      region: '여수시',
      rating: 4.9,
      reviewCount: 5210,
      duration: '약 3시간',
      badge: '야경',
      tags: ['바다뷰', '야경', '드라이브'],
      weatherLabel: '맑음',
      weatherTemp: 22,
      congestion: CongestionInfo(
        level: '혼잡',
        parking: false,
        wait: 25,
        hourly: [30, 50, 70, 95, 90, 70],
        hint: '주말 저녁이라 혼잡해요. 대안 장소를 확인해보세요.',
      ),
      image:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
      desc: '낭만포차와 돌산대교의 불빛이 어우러진 여수 밤바다. 노래로도 유명한 대표 야경 명소예요.',
    ),
    Destination(
      id: 'damyang-bamboo',
      title: '죽녹원 대나무숲',
      region: '담양군',
      rating: 4.7,
      reviewCount: 2180,
      duration: '약 1.5시간',
      tags: ['자연', '힐링', '포토존'],
      weatherLabel: '구름',
      weatherTemp: 21,
      congestion: CongestionInfo(
        level: '보통',
        parking: true,
        wait: 10,
        hourly: [15, 30, 50, 55, 45, 30],
        hint: '보통 수준이에요. 잠시 기다리면 여유로워져요.',
      ),
      image:
          'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=800&q=80',
      desc: '31만㎡ 규모의 울창한 대나무숲. 청량한 바람 소리와 함께 걷는 힐링 산책로가 일품입니다.',
    ),
    Destination(
      id: 'boseong-tea',
      title: '보성 녹차밭',
      region: '보성군',
      rating: 4.6,
      reviewCount: 1890,
      duration: '약 2시간',
      badge: 'NEW',
      tags: ['자연', '포토존', '차'],
      weatherLabel: '맑음',
      weatherTemp: 23,
      congestion: CongestionInfo(
        level: '여유',
        parking: true,
        wait: 0,
        hourly: [10, 20, 35, 40, 30, 15],
        hint: '지금 방문하기 좋아요.',
      ),
      image:
          'https://images.unsplash.com/photo-1523920290228-4f321a939b4c?w=800&q=80',
      desc: '계단식 녹차밭이 능선을 따라 펼쳐지는 보성 대한다원. 초록 물결 사이를 걷는 대표 인생샷 명소.',
    ),
    Destination(
      id: 'wando-cheonghaejin',
      title: '완도 청해진',
      region: '완도군',
      rating: 4.5,
      reviewCount: 940,
      duration: '약 2시간',
      tags: ['바다뷰', '역사', '섬'],
      weatherLabel: '바람',
      weatherTemp: 19,
      congestion: CongestionInfo(
        level: '여유',
        parking: true,
        wait: 0,
        hourly: [10, 15, 25, 30, 20, 10],
        hint: '한적하게 둘러보기 좋은 시간이에요.',
      ),
      image:
          'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800&q=80',
      desc: '장보고의 해상왕국 청해진 유적지. 완도의 푸른 바다와 역사를 함께 만나는 곳이에요.',
    ),
    Destination(
      id: 'mokpo-cablecar',
      title: '목포 해상케이블카',
      region: '목포시',
      rating: 4.7,
      reviewCount: 3050,
      duration: '약 1시간',
      badge: '인기',
      tags: ['바다뷰', '전망', '가족'],
      weatherLabel: '맑음',
      weatherTemp: 24,
      congestion: CongestionInfo(
        level: '혼잡',
        parking: false,
        wait: 35,
        hourly: [20, 40, 75, 95, 80, 50],
        hint: '대기줄이 길어요. 30분 이후 방문을 추천해요.',
      ),
      image:
          'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800&q=80',
      desc: '국내 최장 해상케이블카에서 목포 앞바다와 유달산을 한눈에. 낮과 밤 모두 인기 만점.',
    ),
  ];

  static const List<MoodOption> moods = [
    MoodOption(value: 'heal', label: '힐링', emoji: '🌿', description: '느긋하게'),
    MoodOption(
      value: 'active',
      label: '액티비티',
      emoji: '🚴',
      description: '활기차게',
    ),
    MoodOption(value: 'food', label: '미식', emoji: '🍽️', description: '맛집 위주'),
    MoodOption(
      value: 'culture',
      label: '문화',
      emoji: '🏛️',
      description: '보고 배우기',
    ),
    MoodOption(
      value: 'photo',
      label: '인생샷',
      emoji: '📸',
      description: '포토존 위주',
    ),
    MoodOption(
      value: 'romantic',
      label: '로맨틱',
      emoji: '💕',
      description: '둘이서',
    ),
  ];

  /// [moods] 의 UI 코드(`value`, 예: `heal`)를 서버 전송용 한글 라벨(`힐링`)로 바꾼다.
  ///
  /// `POST /recommend/ai` 는 `companion`/`transport` 처럼 한글 값을 기대하는데,
  /// `MoodSelector` 는 화면 강조 표시를 위해 영문 코드를 상태로 들고 있어서
  /// 그대로 보내면 서버가 mood 를 인식하지 못한다. 목록에 없는 값(빈 문자열 등)은
  /// 그대로 돌려준다.
  static String moodLabel(String value) => moods
      .firstWhere(
        (m) => m.value == value,
        orElse: () =>
            MoodOption(value: value, label: value, emoji: '', description: ''),
      )
      .label;

  static const RouteInfo route = RouteInfo(
    title: '순천 힐링 하루 코스',
    summary: '맑은 가을 날씨에 딱 맞는 느긋한 자연 코스',
    distance: '약 24km',
    cost: '1인 32,000원',
    steps: [
      RouteStepInfo(
        index: 1,
        title: '순천만 국가정원',
        time: '10:30',
        duration: '1시간 30분',
        transport: '도착',
        subtitle: '정원1호 · 국가정원 산책',
      ),
      RouteStepInfo(
        index: 2,
        title: '순천만 습지 갈대밭',
        time: '12:30',
        duration: '1시간',
        transport: '차로 10분',
        subtitle: '탐방로 · 흑두루미 관찰',
      ),
      RouteStepInfo(
        index: 3,
        title: '순천 웃장 국밥거리',
        time: '14:00',
        duration: '1시간',
        transport: '차로 12분',
        subtitle: '점심 · 순천식 국밥',
      ),
      RouteStepInfo(
        index: 4,
        title: '순천드라마촬영장',
        time: '15:30',
        duration: '1시간 30분',
        transport: '차로 15분',
        subtitle: '레트로 세트장 · 포토존',
      ),
    ],
  );

  static const List<AiRecommendation> aiRecs = [
    AiRecommendation(
      title: '비 오는 날 실내 코스',
      reason: '오후 강수 확률 70% — 실내 위주로 짰어요',
      tags: ['실내', '카페', '박물관'],
      match: 96,
      image:
          'https://images.unsplash.com/photo-1533903345306-15d1c30952de?w=800&q=80',
    ),
    AiRecommendation(
      title: '연인과 여수 야경 코스',
      reason: "'로맨틱' 기분 + 저녁 시간대에 최적",
      tags: ['야경', '바다', '드라이브'],
      match: 92,
      image:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
    ),
  ];

  static const List<ReviewItem> reviews = [
    ReviewItem(
      id: 1,
      name: '이순천',
      avatar: '이순',
      rating: 5,
      date: '3일 전',
      place: '순천만 국가정원',
      body: '갈대밭 노을이 정말 장관이었어요. 아이랑 걷기에도 좋고 유모차도 무리 없었습니다.',
      likes: 42,
      images: 2,
    ),
    ReviewItem(
      id: 2,
      name: '박여수',
      avatar: '박여',
      rating: 4,
      date: '1주 전',
      place: '여수 밤바다',
      body: '낭만포차 분위기 최고! 다만 주말 저녁은 사람이 정말 많으니 참고하세요.',
      likes: 28,
      images: 1,
    ),
    ReviewItem(
      id: 3,
      name: '최담양',
      avatar: '최담',
      rating: 5,
      date: '2주 전',
      place: '죽녹원 대나무숲',
      body: '대나무 사이로 부는 바람 소리가 힐링 그 자체. 여름에 시원하게 다녀왔어요.',
      likes: 19,
      images: 3,
    ),
  ];

  /// 전라남도 22개 시군(5시 17군) 도장 목록.
  ///
  /// 서버 `GET /stamps` 의 `totalCount` 가 22 이므로 전 시군을 나열한다.
  /// `cityCode` 는 국문 지명의 표준 로마자 표기를 따랐다 — 서버가 실제로 어떤 코드를
  /// 쓰는지 실데이터로 확인하지 못했으므로, 화면에서는 코드와 한글명을 모두 대조한다.
  static const List<StampInfo> stamps = [
    // ── 시(5) ──────────────────────────────────────────────
    StampInfo(region: '목포', earned: true, emoji: '⛴️', cityCode: 'mokpo'),
    StampInfo(region: '여수', earned: true, emoji: '🌊', cityCode: 'yeosu'),
    StampInfo(region: '순천', earned: true, emoji: '🌿', cityCode: 'suncheon'),
    StampInfo(region: '나주', earned: true, emoji: '🍐', cityCode: 'naju'),
    StampInfo(region: '광양', earned: false, emoji: '🌸', cityCode: 'gwangyang'),
    // ── 군(17) ─────────────────────────────────────────────
    StampInfo(region: '담양', earned: true, emoji: '🎋', cityCode: 'damyang'),
    StampInfo(region: '곡성', earned: false, emoji: '🚂', cityCode: 'gokseong'),
    StampInfo(region: '구례', earned: true, emoji: '⛰️', cityCode: 'gurye'),
    StampInfo(region: '고흥', earned: false, emoji: '🚀', cityCode: 'goheung'),
    StampInfo(region: '보성', earned: true, emoji: '🍵', cityCode: 'boseong'),
    StampInfo(region: '화순', earned: false, emoji: '🗿', cityCode: 'hwasun'),
    StampInfo(region: '장흥', earned: false, emoji: '🌾', cityCode: 'jangheung'),
    StampInfo(region: '강진', earned: false, emoji: '🏺', cityCode: 'gangjin'),
    StampInfo(region: '해남', earned: false, emoji: '🧭', cityCode: 'haenam'),
    StampInfo(region: '영암', earned: false, emoji: '🏔️', cityCode: 'yeongam'),
    StampInfo(region: '무안', earned: false, emoji: '🧅', cityCode: 'muan'),
    StampInfo(region: '함평', earned: false, emoji: '🦋', cityCode: 'hampyeong'),
    StampInfo(region: '영광', earned: false, emoji: '🌅', cityCode: 'yeonggwang'),
    StampInfo(region: '장성', earned: false, emoji: '🌲', cityCode: 'jangseong'),
    StampInfo(region: '완도', earned: false, emoji: '🏝️', cityCode: 'wando'),
    StampInfo(region: '진도', earned: false, emoji: '🐕', cityCode: 'jindo'),
    StampInfo(region: '신안', earned: false, emoji: '💜', cityCode: 'sinan'),
  ];

  static const List<UnlockCourseInfo> unlockCourses = [
    UnlockCourseInfo(
      id: 'u1',
      title: '맑은 날 무등산 정상뷰',
      rarity: 'COMMON',
      requiredWeather: '맑음',
      condition: '맑은 날에만 해금돼요',
      image:
          'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800&q=80',
    ),
    UnlockCourseInfo(
      id: 'u2',
      title: '화창한 날 향일암 일출명소',
      rarity: 'UNCOMMON',
      requiredWeather: '맑음',
      condition: '맑은 날에만 해금돼요',
      image:
          'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800&q=80',
    ),
    UnlockCourseInfo(
      id: 'u3',
      title: '안개비 내리는 소쇄원 새벽길',
      rarity: 'LEGENDARY',
      requiredWeather: '비',
      condition: '비 또는 안개 낀 날에만 해금돼요',
      image:
          'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=800&q=80',
    ),
    UnlockCourseInfo(
      id: 'u4',
      title: '설경 백양사 설국',
      rarity: 'RARE',
      requiredWeather: '눈',
      condition: '눈 내리는 날에만 해금돼요',
      image:
          'https://images.unsplash.com/photo-1523920290228-4f321a939b4c?w=800&q=80',
    ),
    UnlockCourseInfo(
      id: 'u5',
      title: '돌풍 부는 병풍바위 전망대',
      rarity: 'UNCOMMON',
      requiredWeather: '바람',
      condition: '바람이 거센 날에만 해금돼요',
      image:
          'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800&q=80',
    ),
    UnlockCourseInfo(
      id: 'u6',
      title: '흐린 날의 남도진 서율',
      rarity: 'RARE',
      requiredWeather: '흐림',
      condition: '흐린 날에만 해금돼요',
      image:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
    ),
  ];
}
