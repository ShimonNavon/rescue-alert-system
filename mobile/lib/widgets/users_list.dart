import 'package:flutter/material.dart';
import 'package:rescue_app/domain/services/api/rest_api_service.dart';
import 'package:rescue_app/models/user_details.dart';

class UsersList extends StatefulWidget {
  const UsersList({
    super.key,
  });

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  final users = <UserDetails>[];

  @override
  initState() {
    getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // const users = <({String name, String role, bool available})>[
    //   (name: 'ארי דין', role: 'מוקדן', available: true),
    //   (name: 'מאיה צ׳ן', role: 'פרמדיקית', available: true),
    //   (name: 'יונס ריד', role: 'מוביל חילוץ', available: false),
    //   (name: 'לילה נור', role: 'צוות כיבוי', available: true),
    // ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'צוות תגובה פעיל',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'מעקב אחר זמינות אנשי צוות לפני שיוך אירועים.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        if (users.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Icon(
                  Icons.group_off_outlined,
                  size: 56,
                  color: Colors.blueGrey.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  'אין אנשי צוות להצגה כרגע',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          for (final user in users)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(user.username.substring(0, 1)),
                ),
                title: Text(user.username),
                subtitle: Text(user.role),
                // trailing: Chip(
                //   label: Text(user.available ? 'זמין' : 'עסוק'),
                //   backgroundColor: user.available
                //       ? Colors.green.shade100
                //       : Colors.orange.shade100,
                // ),
              ),
            ),
      ],
    );
  }

  Future<void> getUsers() async {
    final usersResult = await RestApiService().getAllUsers();
    setState(() {
      users.clear();
      users.addAll(usersResult);
    });
  }
}
