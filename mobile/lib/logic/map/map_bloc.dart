import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user_location.dart';
import '../../repositories/location_repository.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class MapStarted extends MapEvent {}

class MapRefreshRequested extends MapEvent {}

class MapState extends Equatable {
  const MapState({
    this.locations = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<UserLocation> locations;
  final bool isLoading;
  final String? errorMessage;

  MapState copyWith({
    List<UserLocation>? locations,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MapState(
      locations: locations ?? this.locations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [locations, isLoading, errorMessage];
}

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({required LocationRepository locationRepository})
    : _locationRepository = locationRepository,
      super(const MapState()) {
    on<MapStarted>(_onStarted);
    on<MapRefreshRequested>(_onRefreshRequested);
  }

  final LocationRepository _locationRepository;

  Future<void> _onStarted(MapStarted event, Emitter<MapState> emit) async {
    await _refresh(emit);
  }

  Future<void> _onRefreshRequested(
    MapRefreshRequested event,
    Emitter<MapState> emit,
  ) async {
    await _refresh(emit);
  }

  Future<void> _refresh(Emitter<MapState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final locations = await _locationRepository.getAllUserLocations();
      emit(state.copyWith(locations: locations, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
