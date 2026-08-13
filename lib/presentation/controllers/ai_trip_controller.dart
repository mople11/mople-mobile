import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';

enum AiTripStep { input, loading, result }

class AiTripState {
  const AiTripState({
    this.step = AiTripStep.input,
    required this.moods,
    this.companion = '연인',
    this.hours = 6.0,
  });

  final AiTripStep step;
  final List<String> moods;
  final String companion;
  final double hours;

  String get moodLabel => EodiganamData.moods
      .firstWhere(
        (m) => m.value == (moods.isEmpty ? '' : moods.first),
        orElse: () => EodiganamData.moods.first,
      )
      .label;

  AiTripState copyWith({
    AiTripStep? step,
    List<String>? moods,
    String? companion,
    double? hours,
  }) => AiTripState(
    step: step ?? this.step,
    moods: moods ?? this.moods,
    companion: companion ?? this.companion,
    hours: hours ?? this.hours,
  );
}

class AiTripNotifier extends Notifier<AiTripState> {
  AiTripNotifier(this.initialMood);

  final String? initialMood;

  @override
  AiTripState build() => AiTripState(moods: [initialMood ?? 'heal']);

  void setMood(String value) => state = state.copyWith(moods: [value]);

  void setCompanion(String value) => state = state.copyWith(companion: value);

  void setHours(double value) => state = state.copyWith(hours: value);

  void backToInput() => state = state.copyWith(step: AiTripStep.input);

  Future<void> generate() async {
    state = state.copyWith(step: AiTripStep.loading);
    await Future.delayed(const Duration(milliseconds: 1400));
    state = state.copyWith(step: AiTripStep.result);
  }
}

final aiTripProvider = NotifierProvider.autoDispose
    .family<AiTripNotifier, AiTripState, String?>(AiTripNotifier.new);
