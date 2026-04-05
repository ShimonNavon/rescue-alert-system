import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/app_message.dart';
import '../../repositories/message_repository.dart';
import '../../services/audio_service.dart';

class MessageDetailsState {
  const MessageDetailsState({
    this.message,
    this.isLoading = false,
    this.errorMessage,
    this.replyPath,
  });

  final AppMessage? message;
  final bool isLoading;
  final String? errorMessage;
  final String? replyPath;

  MessageDetailsState copyWith({
    AppMessage? message,
    bool? isLoading,
    String? errorMessage,
    String? replyPath,
  }) {
    return MessageDetailsState(
      message: message ?? this.message,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      replyPath: replyPath ?? this.replyPath,
    );
  }
}

class MessageDetailsCubit extends Cubit<MessageDetailsState> {
  MessageDetailsCubit({
    required MessageRepository messageRepository,
    required AudioService audioService,
  }) : _messageRepository = messageRepository,
       _audioService = audioService,
       super(const MessageDetailsState());

  final MessageRepository _messageRepository;
  final AudioService _audioService;

  Future<void> load(String messageId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final message = await _messageRepository.getMessageDetails(messageId);
      emit(state.copyWith(message: message, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> playMessageAudio() async {
    final url = state.message?.audioUrl;
    if (url == null || url.isEmpty) {
      return;
    }
    await _audioService.playFromUrl(url);
  }

  Future<void> startReplyRecording() async {
    final path = await _audioService.startRecording();
    emit(state.copyWith(replyPath: path));
  }

  Future<void> stopReplyRecordingAndSend() async {
    final path = await _audioService.stopRecording();
    final bytes = await _audioService.readRecording(path);
    final message = state.message;
    if (message == null) {
      return;
    }
    await _messageRepository.postMessage(
      title: 'RE: ${message.title}',
      text: 'Voice reply',
      voicePayload: bytes,
    );
    emit(state.copyWith(replyPath: path));
  }
}
