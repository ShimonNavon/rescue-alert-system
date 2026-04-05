import '../models/user_group.dart';
import '../services/api_client.dart';

class GroupRepository {
  GroupRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

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
