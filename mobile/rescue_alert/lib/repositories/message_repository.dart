import 'dart:async';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';

import '../models/app_message.dart';
import '../services/api_client.dart';

class MessageRepository {
  MessageRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;
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
