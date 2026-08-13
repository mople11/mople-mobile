import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';

/// 목적지/코스 찜(♡) 상태를 앱 전역에서 공유하는 상태.
///
/// 코스/경로 화면은 목업 데이터상 [EodiganamData.route] 단일 인스턴스만 존재하므로
/// 고정 키 [FavoritesNotifier.routeKey] 하나로 CoursePage/RoutePage의 저장 상태를 동기화한다.
class FavoritesState {
  const FavoritesState({this.ids = const <String>{}});

  final Set<String> ids;

  bool isFav(String id) => ids.contains(id);

  List<Destination> get favoriteDestinations =>
      EodiganamData.destinations.where((d) => ids.contains(d.id)).toList();
}

class FavoritesNotifier extends Notifier<FavoritesState> {
  static const routeKey = 'route-main';

  @override
  FavoritesState build() => const FavoritesState();

  void toggle(String id) {
    final ids = {...state.ids};
    if (!ids.add(id)) ids.remove(id);
    state = FavoritesState(ids: ids);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, FavoritesState>(
  FavoritesNotifier.new,
);
