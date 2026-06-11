import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rescue_app/constants/app_env.dart';
import 'package:rescue_app/managers/storage_manager.dart';
import 'package:rescue_app/models/app_message.dart';
import 'package:rescue_app/models/user_group.dart';
import 'package:rescue_app/models/user_location.dart';

import 'rest_api_models.dart';

class RestApiService {
  static final String baseUrl = AppEnv.apiBaseUrl;

  static final RestApiService _instance = RestApiService._internal();
  factory RestApiService() => _instance;

  RestApiService._internal()
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            sendTimeout: const Duration(seconds: 20),
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final String? storedAuthorization =
              await StorageManager.instance.authorization();

          if (storedAuthorization != null && storedAuthorization.isNotEmpty) {
            options.headers['Authorization'] = storedAuthorization;
          } else if (_accessToken != null && _accessToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }

          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  void dispose() => _dio.close();

  Future<void> setAuthToken(
      {required String access, required String refresh}) async {
    _accessToken = access;
    _refreshToken = refresh;
    _dio.options.headers['Authorization'] = 'Bearer $_accessToken';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<void> setAccessAuthToken({required String access}) async {
    _accessToken = access;
    _dio.options.headers['Authorization'] = 'Bearer $_accessToken';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  bool hasDioHeaders() {
    return _dio.options.headers.containsKey('Authorization') &&
        _dio.options.headers['Authorization'] != null;
  }

  Future<bool> checkDioHeaders() async {
    if (hasDioHeaders()) {
      return true;
    } else {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final String? token = await currentUser.getIdToken();
        if (token != null && token.isNotEmpty) {
          await setAccessAuthToken(access: token);
          return true;
        }
      }
      return false;
    }
  }

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
    _dio.options.headers.remove('Authorization');
  }

  Future<void> postCurrentLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      if (!await checkDioHeaders()) {
        return;
      }

      await _dio.post(
        '/api/user/location/',
        data: {'latitude': latitude, 'longitude': longitude},
      );
    } on DioException catch (e) {
      debugPrint('postCurrentLocation error: ${e.message}');
      return;
    } catch (e) {
      debugPrint('postCurrentLocation error: $e');
      return;
    }
  }

  Future<List<UserLocation>> getAllUsersLocation() async {
    try {
      if (!await checkDioHeaders()) {
        return [];
      }

      final response = await _dio.get('/api/user/all/');
      final list = (response.data as List<dynamic>? ?? const [])
          .map((item) => UserLocation.fromJson(item as Map<String, dynamic>))
          .toList();
      return list;
    } on DioException catch (e) {
      debugPrint('getAllUsersLocation error: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('getAllUsersLocation error: $e');
      return [];
    }
  }

  Future<List<AppMessage>> getMessages() async {
    try {
      if (!await checkDioHeaders()) {
        return [];
      }

      final response = await _dio.get('/api/message/');
      final list = (response.data as List<dynamic>? ?? const [])
          .map((item) => AppMessage.fromJson(item as Map<String, dynamic>))
          .toList();
      return list;
    } on DioException catch (e) {
      debugPrint('getMessages error: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('getMessages error: $e');
      return [];
    }
  }

  Future<List<UserGroup>> getUserGroups() async {
    try {
      if (!await checkDioHeaders()) {
        return [];
      }

      final response = await _dio.get('/api/group/');
      return (response.data as List<dynamic>? ?? const [])
          .map((item) => UserGroup.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('getUserGroups error: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('getUserGroups error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUsersInGroup(String groupId) async {
    try {
      if (!await checkDioHeaders()) {
        return [];
      }

      final response = await _dio.get('/api/group/$groupId/');
      return (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      debugPrint('getUsersInGroup error: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('getUsersInGroup error: $e');
      return [];
    }
  }

  Future<void> addUserToGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      if (!await checkDioHeaders()) {
        return;
      }

      await _dio.post('/api/group/$groupId/add_user/', data: {'user_id': userId});
    } on DioException catch (e) {
      debugPrint('addUserToGroup error: ${e.message}');
      return;
    } catch (e) {
      debugPrint('addUserToGroup error: $e');
      return;
    }
  }

  Future<void> removeUserFromGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      if (!await checkDioHeaders()) {
        return;
      }

      await _dio.delete('/api/group/$groupId/remove_user/', data: {'user_id': userId});
    } on DioException catch (e) {
      debugPrint('removeUserFromGroup error: ${e.message}');
      return;
    } catch (e) {
      debugPrint('removeUserFromGroup error: $e');
      return;
    }
  }

  Future<AppMessage> getMessageById(String id) async {
    try {
      if (!await checkDioHeaders()) {
        return _emptyAppMessage();
      }

      final response = await _dio.get('/messages/$id');
      return AppMessage.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('getMessageById error: ${e.message}');
      return _emptyAppMessage();
    } catch (e) {
      debugPrint('getMessageById error: $e');
      return _emptyAppMessage();
    }
  }

  Future<void> postMessage({
    required String title,
    required String text,
    Uint8List? voicePayload,
  }) async {
    try {
      if (!await checkDioHeaders()) {
        return;
      }

      final data = FormData.fromMap({
        'title': title,
        'text': text,
        if (voicePayload != null)
          'voice_file': MultipartFile.fromBytes(
            voicePayload,
            filename: 'voice_note.m4a',
          ),
      });
      await _dio.post('/api/message/', data: data);
    } on DioException catch (e) {
      debugPrint('postMessage error: ${e.message}');
      return;
    } catch (e) {
      debugPrint('postMessage error: $e');
      return;
    }
  }

  Future<void> registerDevice({
    required String fcmToken,
    required String deviceId,
    required String platform,
    required String deviceModel,
  }) async {
    try {
      if (!await checkDioHeaders()) {
        return;
      }

      await _dio.post('/api/notifications/token', data: {
        'fcm_token': fcmToken,
        'device_id': deviceId,
        'platform': platform,
        'device_model': deviceModel,
      });
    } on DioException catch (e) {
      debugPrint('registerDevice error: ${e.message}');
      return;
    } catch (e) {
      debugPrint('registerDevice error: $e');
      return;
    }
  }

  Future<JwtTokens> obtainToken({
    required String username,
    required String password,
  }) async {
    final response = await _safePost(
      '/api/token/',
      data: <String, dynamic>{
        'username': username,
        'password': password,
      },
    );

    final tokens = JwtTokens.fromJson(_asMap(response.data));
    setAuthToken(access: tokens.access, refresh: tokens.refresh);
    return tokens;
  }

  Future<String> refreshAccessToken({String? refreshToken}) async {
    final token = refreshToken ?? _refreshToken;
    if (token == null || token.isEmpty) {
      throw StateError('No refresh token set. Call obtainToken first.');
    }

    final response = await _safePost(
      '/api/token/refresh/',
      data: <String, dynamic>{'refresh': token},
    );

    final data = _asMap(response.data);
    final access = data['access'] as String;
    _accessToken = access;
    return access;
  }

  Future<List<dynamic>> listUsers() async {
    final response = await _safeGet('/api/user/');
    return _asList(response.data);
  }

  Future<Map<String, dynamic>> createUserProfile({
    required String role,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _safePost(
      '/api/user/',
      data: <String, dynamic>{
        'role': role,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getUserProfile(int id) async {
    final response = await _safeGet('/api/user/$id/');
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> updateUserProfile({
    required int id,
    required String role,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _safePut(
      '/api/user/$id/',
      data: <String, dynamic>{
        'role': role,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> patchUserProfile({
    required int id,
    String? role,
    double? latitude,
    double? longitude,
  }) async {
    final data = <String, dynamic>{};
    if (role != null) data['role'] = role;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;

    final response = await _safePatch('/api/user/$id/', data: data);
    return _asMap(response.data);
  }

  Future<void> deleteUserProfile(int id) async {
    await _safeDelete('/api/user/$id/');
  }

  Future<Map<String, dynamic>> updateCurrentUserLocation({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _safePost(
      '/api/user/location/',
      data: <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return _asMap(response.data);
  }

  Future<List<dynamic>> listUsersWithCoordinates() async {
    final response = await _safeGet('/api/user/all/');
    return _asList(response.data);
  }

  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    final response = await _safeGet('/api/user/profile/');
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> updateCurrentUserProfile(
    Map<String, dynamic> fields,
  ) async {
    final response = await _safePut(
      '/api/user/update_profile/',
      data: fields,
    );
    return _asMap(response.data);
  }

  Future<List<dynamic>> listGroups() async {
    final response = await _safeGet('/api/group/');
    return _asList(response.data);
  }

  Future<Map<String, dynamic>> createGroup({
    required String name,
    required List<int> members,
  }) async {
    final response = await _safePost(
      '/api/group/',
      data: <String, dynamic>{
        'name': name,
        'members': members,
      },
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getGroup(int id) async {
    final response = await _safeGet('/api/group/$id/');
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> updateGroup({
    required int id,
    required String name,
    required List<int> members,
  }) async {
    final response = await _safePut(
      '/api/group/$id/',
      data: <String, dynamic>{
        'name': name,
        'members': members,
      },
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> patchGroup({
    required int id,
    String? name,
    List<int>? members,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (members != null) data['members'] = members;

    final response = await _safePatch('/api/group/$id/', data: data);
    return _asMap(response.data);
  }

  Future<void> deleteGroup(int id) async {
    await _safeDelete('/api/group/$id/');
  }

  // Future<Map<String, dynamic>> addUserToGroup({
  //   required int groupId,
  //   required int userId,
  // }) async {
  //   final response = await _safePost(
  //     '/api/group/$groupId/add_user/',
  //     data: <String, dynamic>{'user_id': userId},
  //   );
  //   return _asMap(response.data);
  // }

  // Future<Map<String, dynamic>> removeUserFromGroup({
  //   required int groupId,
  //   required int userId,
  // }) async {
  //   final response = await _safeDelete(
  //     '/api/group/$groupId/remove_user/',
  //     data: <String, dynamic>{'user_id': userId},
  //   );
  //   return _asMap(response.data);
  // }

  Future<List<dynamic>> listMessages() async {
    final response = await _safeGet('/api/message/');
    return _asList(response.data);
  }

  Future<Map<String, dynamic>> createMessage({
    required String title,
    required String text,
    dynamic voiceFile,
    double? latitude,
    double? longitude,
  }) async {
    final payload = await _buildMessagePayload(
      title: title,
      text: text,
      voiceFile: voiceFile,
      latitude: latitude,
      longitude: longitude,
    );

    final response = await _safePost('/api/message/', data: payload);
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getMessage(int id) async {
    final response = await _safeGet('/api/message/$id/');
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> updateMessage({
    required int id,
    required String title,
    required String text,
    dynamic voiceFile,
    double? latitude,
    double? longitude,
  }) async {
    final payload = await _buildMessagePayload(
      title: title,
      text: text,
      voiceFile: voiceFile,
      latitude: latitude,
      longitude: longitude,
    );

    final response = await _safePut('/api/message/$id/', data: payload);
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> patchMessage({
    required int id,
    String? title,
    String? text,
    dynamic voiceFile,
    double? latitude,
    double? longitude,
  }) async {
    final payload = await _buildMessagePayload(
      title: title,
      text: text,
      voiceFile: voiceFile,
      latitude: latitude,
      longitude: longitude,
      skipNulls: true,
    );

    final response = await _safePatch(
      '/api/message/$id/',
      data: payload,
    );
    return _asMap(response.data);
  }

  Future<void> deleteMessage(int id) async {
    await _safeDelete('/api/message/$id/');
  }

  Future<List<dynamic>> listMessagesNewestFirst() async {
    final response = await _safeGet('/api/message/list_messages/');
    return _asList(response.data);
  }

  Future<List<dynamic>> listNotifications() async {
    final response = await _safeGet('/api/notification/');
    return _asList(response.data);
  }

  Future<Map<String, dynamic>> createNotification(
      {required String token}) async {
    final response = await _safePost(
      '/api/notification/',
      data: <String, dynamic>{'token': token},
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getNotification(int id) async {
    final response = await _safeGet('/api/notification/$id/');
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> updateNotification({
    required int id,
    required String token,
  }) async {
    final response = await _safePut(
      '/api/notification/$id/',
      data: <String, dynamic>{'token': token},
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> patchNotification({
    required int id,
    required String token,
  }) async {
    final response = await _safePatch(
      '/api/notification/$id/',
      data: <String, dynamic>{'token': token},
    );
    return _asMap(response.data);
  }

  Future<void> deleteNotification(int id) async {
    await _safeDelete('/api/notification/$id/');
  }

  Future<List<dynamic>> listAlerts() async {
    final response = await _safeGet('/api/alerts/');
    return _asList(response.data);
  }

  Future<Map<String, dynamic>> createAlert({
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required String status,
    required String priority,
  }) async {
    final response = await _safePost(
      '/api/alerts/',
      data: <String, dynamic>{
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
        'priority': priority,
      },
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getAlert(int id) async {
    final response = await _safeGet('/api/alerts/$id/');
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> updateAlert({
    required int id,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required String status,
    required String priority,
  }) async {
    final response = await _safePut(
      '/api/alerts/$id/',
      data: <String, dynamic>{
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
        'priority': priority,
      },
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> patchAlert({
    required int id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? status,
    String? priority,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (status != null) data['status'] = status;
    if (priority != null) data['priority'] = priority;

    final response = await _safePatch('/api/alerts/$id/', data: data);
    return _asMap(response.data);
  }

  Future<void> deleteAlert(int id) async {
    await _safeDelete('/api/alerts/$id/');
  }

  Future<List<dynamic>> listNearbyAlerts({
    required double lat,
    required double lon,
    required int radius,
  }) async {
    final response = await _safeGet(
      '/api/alerts/nearby/',
      queryParameters: <String, dynamic>{
        'lat': lat,
        'lon': lon,
        'radius': radius,
      },
    );
    return _asList(response.data);
  }

  Future<dynamic> _buildMessagePayload({
    String? title,
    String? text,
    dynamic voiceFile,
    double? latitude,
    double? longitude,
    bool skipNulls = false,
  }) async {
    final hasFile = voiceFile != null;

    if (!hasFile) {
      final data = <String, dynamic>{
        'title': title,
        'text': text,
        'latitude': latitude,
        'longitude': longitude,
      };
      if (skipNulls) {
        data.removeWhere((key, value) => value == null);
      }
      return data;
    }

    MultipartFile filePart;
    if (voiceFile is MultipartFile) {
      filePart = voiceFile;
    } else if (voiceFile is String) {
      filePart = await MultipartFile.fromFile(voiceFile);
    } else {
      throw ArgumentError(
        'voiceFile must be either a file path String or MultipartFile.',
      );
    }

    final formMap = <String, dynamic>{
      'title': title,
      'text': text,
      'voice_file': filePart,
      'latitude': latitude,
      'longitude': longitude,
    };

    if (skipNulls) {
      formMap.removeWhere((key, value) => value == null);
    }

    return FormData.fromMap(formMap);
  }

  Future<Response<dynamic>> _safeGet(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      if (!await checkDioHeaders()) {
        return _toErrorResponse(
          path: path,
          error: StateError('Missing authorization headers'),
        );
      }

      return await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
    } on DioException catch (error) {
      return _toErrorResponse(
        path: path,
        dioException: error,
      );
    } catch (error) {
      return _toErrorResponse(
        path: path,
        error: error,
      );
    }
  }

  Future<Response<dynamic>> _safePost(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      if (!await checkDioHeaders()) {
        return _toErrorResponse(
          path: path,
          error: StateError('Missing authorization headers'),
        );
      }

      return await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (error) {
      return _toErrorResponse(
        path: path,
        dioException: error,
      );
    } catch (error) {
      return _toErrorResponse(
        path: path,
        error: error,
      );
    }
  }

  Future<Response<dynamic>> _safePut(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      if (!await checkDioHeaders()) {
        return _toErrorResponse(
          path: path,
          error: StateError('Missing authorization headers'),
        );
      }

      return await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (error) {
      return _toErrorResponse(
        path: path,
        dioException: error,
      );
    } catch (error) {
      return _toErrorResponse(
        path: path,
        error: error,
      );
    }
  }

  Future<Response<dynamic>> _safePatch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      if (!await checkDioHeaders()) {
        return _toErrorResponse(
          path: path,
          error: StateError('Missing authorization headers'),
        );
      }

      return await _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (error) {
      return _toErrorResponse(
        path: path,
        dioException: error,
      );
    } catch (error) {
      return _toErrorResponse(
        path: path,
        error: error,
      );
    }
  }

  Future<Response<dynamic>> _safeDelete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      if (!await checkDioHeaders()) {
        return _toErrorResponse(
          path: path,
          error: StateError('Missing authorization headers'),
        );
      }

      return await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (error) {
      return _toErrorResponse(
        path: path,
        dioException: error,
      );
    } catch (error) {
      return _toErrorResponse(
        path: path,
        error: error,
      );
    }
  }

  Response<dynamic> _toErrorResponse({
    required String path,
    DioException? dioException,
    Object? error,
  }) {
    if (dioException?.response != null) {
      return dioException!.response!;
    }

    final String message =
        dioException?.message ?? error?.toString() ?? 'Unknown API error';

    return Response<dynamic>(
      requestOptions:
          dioException?.requestOptions ?? RequestOptions(path: path),
      statusCode: -1,
      statusMessage: message,
      data: <String, dynamic>{
        'error': message,
      },
    );
  }

  AppMessage _emptyAppMessage() {
    return AppMessage(
      id: '',
      title: '',
      text: '',
      audioUrl: null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      userMetadata: const <String, dynamic>{},
      latitude: null,
      longitude: null,
    );
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw StateError('Expected JSON object but received: ${data.runtimeType}');
  }

  List<dynamic> _asList(dynamic data) {
    if (data is List) {
      return data;
    }
    if (data is Map<String, dynamic> && data['results'] is List) {
      return data['results'] as List<dynamic>;
    }
    throw StateError('Expected JSON list but received: ${data.runtimeType}');
  }
}
