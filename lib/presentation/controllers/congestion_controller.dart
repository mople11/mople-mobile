import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';

class CongestionState {
  const CongestionState({required this.destinationId, this.alertOn = false});

  final String destinationId;
  final bool alertOn;

  Destination get destination => EodiganamData.destinations.firstWhere(
    (d) => d.id == destinationId,
    orElse: () => EodiganamData.destinations.first,
  );

  List<Destination> get alternatives => EodiganamData.destinations
      .where((x) => x.id != destinationId && x.congestion?.level != '혼잡')
      .take(2)
      .toList();

  CongestionState copyWith({bool? alertOn}) => CongestionState(
    destinationId: destinationId,
    alertOn: alertOn ?? this.alertOn,
  );
}

class CongestionNotifier extends Notifier<CongestionState> {
  CongestionNotifier(this.destinationId);

  final String destinationId;

  @override
  CongestionState build() => CongestionState(destinationId: destinationId);

  void toggleAlert(bool value) => state = state.copyWith(alertOn: value);
}

final congestionProvider = NotifierProvider.autoDispose
    .family<CongestionNotifier, CongestionState, String>(
      CongestionNotifier.new,
    );
