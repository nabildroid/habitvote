import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:habitvote/features/user/data/utils/map_cities.dart';
import 'package:latlong2/latlong.dart';

class PresenceState extends Equatable {
  final int liveUsers;
  final List<LatLng> coordinates;

  const PresenceState({
    this.liveUsers = 0,
    this.coordinates = const [],
  });

  PresenceState copyWith({
    int? liveUsers,
    List<LatLng>? coordinates,
  }) {
    return PresenceState(
      liveUsers: liveUsers ?? this.liveUsers,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  @override
  List<Object?> get props => [liveUsers, coordinates];
}

class PresenceCubit extends Cubit<PresenceState> {
  Timer? _timer;

  PresenceCubit() : super(const PresenceState()) {
    _startUserUpdates();
  }

  void _startUserUpdates() {
    _updateLiveUsers();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateLiveUsers();
    });
  }

  void _updateLiveUsers() {
    final random = Random();
    final newLiveUsers =
        random.nextInt(150) + 50; // Random number between 0 and 999

    final allCities = List<LatLng>.from(mapCities);
    allCities.shuffle();

    emit(state.copyWith(
      liveUsers: newLiveUsers,
      coordinates: allCities.take(newLiveUsers).toList(),
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
