import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';

/// 목적지 상세 화면의 파생 데이터. 별도로 바뀌는 상태가 없어 [Notifier] 대신
/// 순수 계산 값을 돌려주는 일반 [Provider] 로 둔다.
class DetailData {
  DetailData(this.destinationId);

  final String destinationId;

  Destination get destination => EodiganamData.destinations.firstWhere(
    (d) => d.id == destinationId,
    orElse: () => EodiganamData.destinations.first,
  );

  List<Destination> get similar => EodiganamData.destinations
      .where((d) => d.id != destination.id)
      .take(3)
      .toList();
}

final detailProvider = Provider.autoDispose.family<DetailData, String>(
  (ref, destinationId) => DetailData(destinationId),
);
