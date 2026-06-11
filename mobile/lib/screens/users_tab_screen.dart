import 'package:flutter/material.dart';
import 'package:rescue_app/domain/services/api/rest_api_service.dart';
import 'package:rescue_app/widgets/groups_list.dart';
import 'package:rescue_app/widgets/users_list.dart';

class UsersTabScreen extends StatefulWidget {
  const UsersTabScreen({super.key});

  @override
  State<UsersTabScreen> createState() => _UsersTabScreenState();
}

class _UsersTabScreenState extends State<UsersTabScreen> {


  @override
  void initState() {
    getUserGroups();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person_outline), text: 'משתמשים'),
              Tab(icon: Icon(Icons.groups_2_outlined), text: 'קבוצות'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                const UsersList(),
                const GroupsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getUserGroups() async {
    final groups = await RestApiService().getUserGroups();
    print('Fetched groups: $groups');
  }
}
