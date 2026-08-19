import 'package:mople_mobile/data/api/api_client.dart';
import 'package:mople_mobile/data/api/api_endpoints.dart';
import 'package:mople_mobile/data/models/models.dart';

/// `GET /home`, `GET /weather/current` 연동.
class HomeRepository {
  HomeRepository._();

  static final HomeRepository instance = HomeRepository._();

  /// `lat`/`lng` 는 서버 필수값이라 위치를 모를 때도 [LocationQuery.fallback] 을 보낸다.
  Future<HomeData> fetchHome(LocationQuery? query) => apiClient.requestObject(
    'GET',
    ApiEndpoints.home,
    query: (query ?? LocationQuery.fallback).toJson(),
    parse: HomeData.fromJson,
  );

  Future<CurrentWeather> fetchCurrentWeather(LocationQuery? query) =>
      apiClient.requestObject(
        'GET',
        ApiEndpoints.currentWeather,
        query: (query ?? LocationQuery.fallback).toJson(),
        parse: CurrentWeather.fromJson,
      );
}

HomeRepository get homeRepository => HomeRepository.instance;
