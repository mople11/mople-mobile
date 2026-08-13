import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/mock/mock_api.dart';
import 'package:mople_mobile/data/models/models.dart';
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
  @override
  HomeState build() => const HomeState();

  void setLocation({required double lat, required double lng}) {
    state = state.copyWith(
      location: LocationQuery(lat: lat, lng: lng),
    );
  }

  Future<void> loadHome({double? lat, double? lng}) async {
    if (lat != null && lng != null) setLocation(lat: lat, lng: lng);
    state = state.copyWith(home: const AsyncLoading());
    final result = await guardAsync(() => mockApi.fetchHome(state.location));
    state = state.copyWith(home: result);
  }

  Future<void> loadWeather({double? lat, double? lng}) async {
    if (lat != null && lng != null) setLocation(lat: lat, lng: lng);
    state = state.copyWith(weather: const AsyncLoading());
    final result = await guardAsync(
      () => mockApi.fetchCurrentWeather(state.location),
    );
    state = state.copyWith(weather: result);
  }

  Future<void> refreshAll() async {
    await Future.wait([loadHome(), loadWeather()]);
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
