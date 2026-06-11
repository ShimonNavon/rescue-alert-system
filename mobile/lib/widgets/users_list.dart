import 'package:flutter/material.dart';

class UsersList extends StatelessWidget {
  const UsersList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const users = <({String name, String role, bool available})>[
      (name: 'ארי דין', role: 'מוקדן', available: true),
      (name: 'מאיה צ׳ן', role: 'פרמדיקית', available: true),
      (name: 'יונס ריד', role: 'מוביל חילוץ', available: false),
      (name: 'לילה נור', role: 'צוות כיבוי', available: true),
    ];

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
        for (final user in users)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(user.name.substring(0, 1)),
              ),
              title: Text(user.name),
              subtitle: Text(user.role),
              trailing: Chip(
                label: Text(user.available ? 'זמין' : 'עסוק'),
                backgroundColor: user.available
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
              ),
            ),
          ),
      ],
    );
  }
}
