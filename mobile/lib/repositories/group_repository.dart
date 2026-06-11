import 'package:rescue_app/domain/services/api/rest_api_service.dart';
import '../models/user_group.dart';

class GroupRepository {
  GroupRepository({required RestApiService apiClient}) : _apiClient = apiClient;

  final RestApiService _apiClient;

  Future<List<UserGroup>> getGroups() => _apiClient.getUserGroups();

  Future<List<Map<String, dynamic>>> getGroupUsers(String groupId) =>
      _apiClient.getUsersInGroup(groupId);

  Future<void> addUserToGroup({
    required String groupId,
    required String userId,
  }) {
    return _apiClient.addUserToGroup(groupId: groupId, userId: userId);
  }

  Future<void> removeUserFromGroup({
    required String groupId,
    required String userId,
  }) {
    return _apiClient.removeUserFromGroup(groupId: groupId, userId: userId);
  }
}
