import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/app_message.dart';
import '../models/user_group.dart';
import '../models/user_location.dart';

class ApiClient {
  ApiClient({required String baseUrl})
    : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  final Dio _dio;

  void dispose() => _dio.close();

  Future<void> setAuthToken(String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> postCurrentLocation({
    required double latitude,
    required double longitude,
  }) async {
    await _dio.post(
      '/locations/current',
      data: {'latitude': latitude, 'longitude': longitude},
    );
  }

  Future<List<UserLocation>> getAllUsersLocation() async {
    final response = await _dio.get('/locations');
    final list = (response.data as List<dynamic>? ?? const [])
        .map((item) => UserLocation.fromJson(item as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<List<AppMessage>> getMessages() async {
    final response = await _dio.get('/messages');
    final list = (response.data as List<dynamic>? ?? const [])
        .map((item) => AppMessage.fromJson(item as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<List<UserGroup>> getUserGroups() async {
    final response = await _dio.get('/groups');
    return (response.data as List<dynamic>? ?? const [])
        .map((item) => UserGroup.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getUsersInGroup(String groupId) async {
    final response = await _dio.get('/groups/$groupId/users');
    return (response.data as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
  }

  Future<void> addUserToGroup({
    required String groupId,
    required String userId,
  }) async {
    await _dio.post('/groups/$groupId/users', data: {'userId': userId});
  }

  Future<void> removeUserFromGroup({
    required String groupId,
    required String userId,
  }) async {
    await _dio.delete('/groups/$groupId/users/$userId');
  }

  Future<AppMessage> getMessageById(String id) async {
    final response = await _dio.get('/messages/$id');
    return AppMessage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> postMessage({
    required String title,
    required String text,
    Uint8List? voicePayload,
  }) async {
    final data = FormData.fromMap({
      'title': title,
      'text': text,
      if (voicePayload != null)
        'voice': MultipartFile.fromBytes(
          voicePayload,
          filename: 'voice_note.m4a',
        ),
    });
    await _dio.post('/messages', data: data);
  }

  Future<void> registerPushToken(String token) async {
    await _dio.post('/notifications/token', data: {'token': token});
  }
}
