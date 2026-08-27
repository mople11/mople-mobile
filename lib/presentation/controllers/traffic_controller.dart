import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/data/repositories/repositories.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';

/// 실시간 교통 혼잡 안내(`GET /traffic/congestion`) 상태.
class TrafficState {
  const TrafficState({this.origin, this.destination, this.traffic});

  final GeoPoint? origin;
  final GeoPoint? destination;
  final AsyncValue<TrafficCongestion>? traffic;

  bool get canQuery => origin != null && destination != null;

  int? get etaMin => traffic?.value?.etaMin;

  AltRoute? get altRoute => traffic?.value?.altRoute;

  List<TrafficSegment> get segments => traffic?.value?.segments ?? const [];

  /// 교통 정보가 없는 경우(`TRAFFIC_DATA_UNAVAILABLE`).
  bool get unavailable =>
      traffic?.apiError?.code == ApiErrorCode.trafficDataUnavailable ||
      (traffic?.value?.isEmpty ?? false);

  TrafficState copyWith({
    GeoPoint? origin,
    GeoPoint? destination,
    AsyncValue<TrafficCongestion>? traffic,
  }) => TrafficState(
    origin: origin ?? this.origin,
    destination: destination ?? this.destination,
    traffic: traffic ?? this.traffic,
  );
}

class TrafficNotifier extends Notifier<TrafficState> {
  /// 경로가 바뀔 때마다 증가. 이전 경로의 응답이 반영되지 않게 한다.
  int _generation = 0;

  @override
  TrafficState build() => const TrafficState();

  void setRoute({required GeoPoint from, required GeoPoint to}) {
    _generation++;
    state = state.copyWith(origin: from, destination: to);
  }

  Future<void> load() async {
    if (!state.canQuery) return;
    final query = TrafficQuery(
      origin: state.origin!,
      destination: state.destination!,
    );
    final generation = _generation;
    state = state.copyWith(traffic: const AsyncLoading());
    final result = await guardAsync(() => placeRepository.fetchTraffic(query));
    if (generation != _generation) return;
    state = state.copyWith(traffic: result);
  }
}

final trafficProvider = NotifierProvider<TrafficNotifier, TrafficState>(
  TrafficNotifier.new,
);
