import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/app_message.dart';
import '../../repositories/message_repository.dart';

sealed class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object?> get props => [];
}

class MessagesStarted extends MessagesEvent {}

class MessagesRefreshRequested extends MessagesEvent {}

class _MessagesUpdated extends MessagesEvent {
  const _MessagesUpdated(this.messages);

  final List<AppMessage> messages;

  @override
  List<Object?> get props => [messages];
}

class MessagesState extends Equatable {
  const MessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<AppMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  MessagesState copyWith({
    List<AppMessage>? messages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, errorMessage];
}

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc({required MessageRepository messageRepository})
    : _messageRepository = messageRepository,
      super(const MessagesState()) {
    on<MessagesStarted>(_onStarted);
    on<MessagesRefreshRequested>(_onRefresh);
    on<_MessagesUpdated>(_onMessagesUpdated);
  }

  final MessageRepository _messageRepository;
  StreamSubscription<List<AppMessage>>? _messageSub;

  Future<void> _onStarted(
    MessagesStarted event,
    Emitter<MessagesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    _messageSub?.cancel();
    _messageSub = _messageRepository.messages$.listen(
      (messages) => add(_MessagesUpdated(messages)),
    );
    await _messageRepository.refreshMessages();
  }

  Future<void> _onRefresh(
    MessagesRefreshRequested event,
    Emitter<MessagesState> emit,
  ) async {
    await _messageRepository.refreshMessages();
  }

  void _onMessagesUpdated(_MessagesUpdated event, Emitter<MessagesState> emit) {
    emit(state.copyWith(messages: event.messages, isLoading: false));
  }

  @override
  Future<void> close() async {
    await _messageSub?.cancel();
    return super.close();
  }
}
