import 'package:mople_mobile/data/models/common/json_utils.dart';

/// `GET /courses/unlocked` 의 코스 희귀도.
enum CourseRarity {
  legendary('LEGENDARY'),
  rare('RARE'),
  uncommon('UNCOMMON'),
  common('COMMON');

  const CourseRarity(this.value);

  final String value;

  static CourseRarity? fromValue(String? value) {
    for (final item in values) {
      if (item.value == value) return item;
    }
    return null;
  }
}

/// `GET /stamps` 의 `data`.
class StampBook {
  const StampBook({
    required this.collected,
    required this.totalCount,
    required this.progress,
  });

  /// 획득한 시군 코드 목록.
  final List<String> collected;

  /// 전체 스탬프 수(명세 기본값 22).
  final int totalCount;

  /// 달성률. 서버가 0~1 또는 0~100 중 무엇을 내려줄지 명세에 없어 원본 그대로 보관한다.
  final double progress;

  factory StampBook.fromJson(Map<String, dynamic> json) => StampBook(
    collected: asStringList(json['collected']),
    totalCount: asInt(json['totalCount']),
    progress: asDouble(json['progress']),
  );

  static const empty = StampBook(
    collected: <String>[],
    totalCount: 0,
    progress: 0,
  );
}

/// `POST /stamps/checkin` 요청 바디.
class StampCheckInRequest {
  const StampCheckInRequest({required this.lat, required this.lng});

  final double lat;
  final double lng;

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

/// `POST /stamps/checkin` 의 `data`.
///
/// 이미 획득한 스탬프면 `ALREADY_ACQUIRED` 와 함께 `stampAcquired: false` 가 온다.
class StampCheckInResult {
  const StampCheckInResult({
    required this.stampAcquired,
    required this.cityCode,
  });

  final bool stampAcquired;
  final String cityCode;

  factory StampCheckInResult.fromJson(Map<String, dynamic> json) =>
      StampCheckInResult(
        stampAcquired: asBool(json['stampAcquired']),
        cityCode: asString(json['cityCode']),
      );
}

/// `POST /cards/completion` 요청 바디.
///
/// 서버 스키마상 `userPhoto` 는 **필수**이며 `format: uri`, `minLength: 1` 이다.
/// 사진 없이 카드만 만드는 호출은 서버가 받지 않는다.
class CompletionCardCreateRequest {
  const CompletionCardCreateRequest({
    required this.courseId,
    required this.userPhoto,
  });

  final String courseId;
  final String userPhoto;

  bool get isValid => userPhoto.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
    // 서버는 courseId 를 integer 로 받는다.
    'courseId': int.tryParse(courseId) ?? courseId,
    'userPhoto': userPhoto,
  };
}

/// `POST /cards/completion` 의 `data`.
class CompletionCardCreateResult {
  const CompletionCardCreateResult({
    required this.cardId,
    required this.cardImageUrl,
  });

  final String cardId;
  final String cardImageUrl;

  factory CompletionCardCreateResult.fromJson(Map<String, dynamic> json) =>
      CompletionCardCreateResult(
        cardId: asString(json['cardId']),
        cardImageUrl: asString(json['cardImageUrl']),
      );
}

/// `GET /cards` 의 `data.cards[]`.
class CompletionCard {
  const CompletionCard({
    required this.cardId,
    required this.courseName,
    required this.date,
    required this.imageUrl,
  });

  final String cardId;
  final String courseName;
  final String date;
  final String imageUrl;

  factory CompletionCard.fromJson(Map<String, dynamic> json) => CompletionCard(
    cardId: asString(json['cardId']),
    courseName: asString(json['courseName']),
    date: asString(json['date']),
    imageUrl: asString(json['imageUrl']),
  );
}

/// `GET /courses/unlocked` 의 `data.unlockedCourses[]`.
class UnlockedCourse {
  const UnlockedCourse({required this.courseId, required this.rarity});

  final String courseId;
  final CourseRarity? rarity;

  factory UnlockedCourse.fromJson(Map<String, dynamic> json) => UnlockedCourse(
    courseId: asString(json['courseId']),
    rarity: CourseRarity.fromValue(asStringOrNull(json['rarity'])),
  );
}

/// `GET /courses/unlocked` 의 `data.lockedCourses[]`.
class LockedCourse {
  const LockedCourse({required this.courseId, required this.unlockCondition});

  final String courseId;
  final String unlockCondition;

  factory LockedCourse.fromJson(Map<String, dynamic> json) => LockedCourse(
    courseId: asString(json['courseId']),
    unlockCondition: asString(json['unlockCondition']),
  );
}

/// `GET /courses/unlocked` 의 `data`.
class UnlockStatus {
  const UnlockStatus({
    required this.unlockedCourses,
    required this.lockedCourses,
  });

  final List<UnlockedCourse> unlockedCourses;
  final List<LockedCourse> lockedCourses;

  factory UnlockStatus.fromJson(Map<String, dynamic> json) => UnlockStatus(
    unlockedCourses: asModelList(
      json['unlockedCourses'],
      UnlockedCourse.fromJson,
    ),
    lockedCourses: asModelList(json['lockedCourses'], LockedCourse.fromJson),
  );

  static const empty = UnlockStatus(
    unlockedCourses: <UnlockedCourse>[],
    lockedCourses: <LockedCourse>[],
  );
}
