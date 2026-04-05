import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/location_repository.dart';
import '../../services/audio_service.dart';
import '../../services/permission_service.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardRecordingStarted extends DashboardEvent {}

class DashboardRecordingStopped extends DashboardEvent {}

class DashboardUploadLocationRequested extends DashboardEvent {}

class _DashboardProgressTicked extends DashboardEvent {
  const _DashboardProgressTicked(this.progress);

  final double progress;

  @override
  List<Object?> get props => [progress];
}

class DashboardState extends Equatable {
  const DashboardState({
    this.isRecording = false,
    this.recordingProgress = 0,
    this.lastRecordedPath,
    this.status,
  });

  final bool isRecording;
  final double recordingProgress;
  final String? lastRecordedPath;
  final String? status;

  DashboardState copyWith({
    bool? isRecording,
    double? recordingProgress,
    String? lastRecordedPath,
    String? status,
  }) {
    return DashboardState(
      isRecording: isRecording ?? this.isRecording,
      recordingProgress: recordingProgress ?? this.recordingProgress,
      lastRecordedPath: lastRecordedPath ?? this.lastRecordedPath,
      status: status,
    );
  }

  @override
  List<Object?> get props => [
    isRecording,
    recordingProgress,
    lastRecordedPath,
    status,
  ];
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required AudioService audioService,
    required PermissionService permissionService,
    required LocationRepository locationRepository,
  }) : _audioService = audioService,
       _permissionService = permissionService,
       _locationRepository = locationRepository,
       super(const DashboardState()) {
    on<DashboardRecordingStarted>(_onRecordingStarted);
    on<DashboardRecordingStopped>(_onRecordingStopped);
    on<DashboardUploadLocationRequested>(_onUploadLocationRequested);
    on<_DashboardProgressTicked>(_onProgressTicked);
  }

  final AudioService _audioService;
  final PermissionService _permissionService;
  final LocationRepository _locationRepository;
  StreamSubscription<double>? _progressSub;

  Future<void> _onRecordingStarted(
    DashboardRecordingStarted event,
    Emitter<DashboardState> emit,
  ) async {
    final hasMic = await _permissionService.hasMicrophone();
    if (!hasMic) {
      emit(state.copyWith(status: 'Microphone permission missing'));
      return;
    }

    final path = await _audioService.startRecording();
    if (path == null) {
      emit(state.copyWith(status: 'Unable to start recording'));
      return;
    }

    await _progressSub?.cancel();
    _progressSub =
        Stream.periodic(const Duration(milliseconds: 500), (tick) => tick)
            .map((tick) => (tick % 20) / 20)
            .listen((progress) => add(_DashboardProgressTicked(progress)));

    emit(
      state.copyWith(
        isRecording: true,
        recordingProgress: 0,
        lastRecordedPath: path,
        status: 'Recording started',
      ),
    );
  }

  Future<void> _onRecordingStopped(
    DashboardRecordingStopped event,
    Emitter<DashboardState> emit,
  ) async {
    final path = await _audioService.stopRecording();
    await _progressSub?.cancel();
    emit(
      state.copyWith(
        isRecording: false,
        recordingProgress: 1,
        lastRecordedPath: path ?? state.lastRecordedPath,
        status: 'Recording saved',
      ),
    );
  }

  Future<void> _onUploadLocationRequested(
    DashboardUploadLocationRequested event,
    Emitter<DashboardState> emit,
  ) async {
    await _locationRepository.publishCurrentLocation();
    emit(state.copyWith(status: 'Location uploaded'));
  }

  void _onProgressTicked(
    _DashboardProgressTicked event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(recordingProgress: event.progress));
  }

  @override
  Future<void> close() async {
    await _progressSub?.cancel();
    return super.close();
  }
}
