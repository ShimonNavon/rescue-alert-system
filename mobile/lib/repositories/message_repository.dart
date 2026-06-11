import 'dart:async';
import 'dart:typed_data';
import 'package:rescue_app/domain/services/api/rest_api_service.dart';
import 'package:rxdart/rxdart.dart';
import '../models/app_message.dart';

class MessageRepository {
  MessageRepository({required RestApiService apiClient})
      : _apiClient = apiClient;

  final RestApiService _apiClient;
  final BehaviorSubject<List<AppMessage>> _messageStream =
      BehaviorSubject.seeded(const []);

  Stream<List<AppMessage>> get messages$ => _messageStream.stream;

  Future<void> refreshMessages() async {
    final messages = await _apiClient.getMessages();
    _messageStream.add(messages);
  }

  Future<AppMessage> getMessageDetails(String id) =>
      _apiClient.getMessageById(id);

  Future<void> postMessage({
    required String title,
    required String text,
    Uint8List? voicePayload,
  }) async {
    await _apiClient.postMessage(
      title: title,
      text: text,
      voicePayload: voicePayload,
    );
    await refreshMessages();
  }

  Future<void> dispose() async {
    await _messageStream.close();
  }
}
