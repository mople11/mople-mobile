import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';

/// 로그인 사용자 표시 정보. 세션 동안 프로필 편집 결과를 유지한다(백엔드 없음).
class UserState {
  const UserState({required this.name, required this.email});

  final String name;
  final String email;

  UserState copyWith({String? name, String? email}) =>
      UserState(name: name ?? this.name, email: email ?? this.email);
}

class UserNotifier extends Notifier<UserState> {
  @override
  UserState build() =>
      UserState(name: EodiganamData.user.name, email: EodiganamData.user.email);

  void updateProfile({required String name, required String email}) {
    state = state.copyWith(name: name, email: email);
  }
}

final userProvider = NotifierProvider<UserNotifier, UserState>(
  UserNotifier.new,
);
