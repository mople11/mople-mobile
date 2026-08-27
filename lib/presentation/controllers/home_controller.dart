import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/data/repositories/repositories.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';

/// Home 범위(`GET /home`, `GET /weather/current`) 상태.
class HomeState {
  const HomeState({this.location, this.home, this.weather});

  /// 마지막으로 조회에 사용한 좌표. 날씨/홈 새로고침에 재사용한다.
  final LocationQuery? location;

  final AsyncValue<HomeData>? home;
  final AsyncValue<CurrentWeather>? weather;

  /// 홈 응답에 날씨가 함께 오므로, 별도 조회 전에는 홈의 날씨를 쓴다.
  CurrentWeather? get currentWeather => weather?.value ?? home?.value?.weather;

  List<CourseSummary> get recommendedCourses =>
      home?.value?.recommendedCourses ?? const [];

  bool get unlockAvailable => home?.value?.unlockBanner?.available ?? false;

  HomeState copyWith({
    LocationQuery? location,
    AsyncValue<HomeData>? home,
    AsyncValue<CurrentWeather>? weather,
  }) => HomeState(
    location: location ?? this.location,
    home: home ?? this.home,
    weather: weather ?? this.weather,
  );
}

class HomeNotifier extends Notifier<HomeState> {
  /// 위치가 바뀔 때마다 증가하는 세대 번호.
  ///
  /// 위치 A 로 보낸 요청의 응답이 위치 B 로 바꾼 뒤 도착하면, 화면의 좌표는 B 인데
  /// 표시되는 날씨·코스는 A 가 되어 어긋난다. 응답을 반영하기 전에 세대를 확인한다.
  int _generation = 0;

  @override
  HomeState build() => const HomeState();

  void setLocation({required double lat, required double lng}) {
    _generation++;
    state = state.copyWith(
      location: LocationQuery(lat: lat, lng: lng),
    );
  }

  Future<void> loadHome({double? lat, double? lng}) async {
    if (lat != null && lng != null) setLocation(lat: lat, lng: lng);
    final generation = _generation;
    state = state.copyWith(home: const AsyncLoading());
    final result = await guardAsync(
      () => homeRepository.fetchHome(state.location),
    );
    if (generation != _generation) return;
    state = state.copyWith(home: result);
  }

  Future<void> loadWeather({double? lat, double? lng}) async {
    if (lat != null && lng != null) setLocation(lat: lat, lng: lng);
    final generation = _generation;
    state = state.copyWith(weather: const AsyncLoading());
    final result = await guardAsync(
      () => homeRepository.fetchCurrentWeather(state.location),
    );
    if (generation != _generation) return;
    state = state.copyWith(weather: result);
  }

  Future<void> refreshAll() async {
    await Future.wait([loadHome(), loadWeather()]);
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
