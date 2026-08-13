import 'package:mople_mobile/data/models/common/json_utils.dart';

/// `GET /users/me` 의 `data.profile`.
class UserProfile {
  const UserProfile({required this.nickname, required this.profileImg});

  final String nickname;
  final String profileImg;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    nickname: asString(json['nickname']),
    profileImg: asString(json['profileImg']),
  );

  UserProfile copyWith({String? nickname, String? profileImg}) => UserProfile(
    nickname: nickname ?? this.nickname,
    profileImg: profileImg ?? this.profileImg,
  );

  static const empty = UserProfile(nickname: '', profileImg: '');
}

/// `GET /users/me` 의 `data.stats`.
class UserStats {
  const UserStats({
    required this.completedCourses,
    required this.stamps,
    required this.reviews,
  });

  final int completedCourses;
  final int stamps;
  final int reviews;

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    completedCourses: asInt(json['completedCourses']),
    stamps: asInt(json['stamps']),
    reviews: asInt(json['reviews']),
  );

  static const empty = UserStats(completedCourses: 0, stamps: 0, reviews: 0);
}

/// `GET /users/me` 의 `data`.
class MyPageSummary {
  const MyPageSummary({required this.profile, required this.stats});

  final UserProfile profile;
  final UserStats stats;

  factory MyPageSummary.fromJson(Map<String, dynamic> json) => MyPageSummary(
    profile: UserProfile.fromJson(asMap(json['profile'])),
    stats: UserStats.fromJson(asMap(json['stats'])),
  );

  MyPageSummary copyWith({UserProfile? profile, UserStats? stats}) =>
      MyPageSummary(
        profile: profile ?? this.profile,
        stats: stats ?? this.stats,
      );
}

/// `PATCH /users/me` 요청 바디. 변경할 필드만 담는다.
class ProfileUpdateRequest {
  const ProfileUpdateRequest({this.nickname, this.profileImg});

  final String? nickname;
  final String? profileImg;

  bool get isEmpty => nickname == null && profileImg == null;

  Map<String, dynamic> toJson() =>
      compactJson({'nickname': nickname, 'profileImg': profileImg});
}
