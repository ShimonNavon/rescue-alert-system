import 'package:flutter/material.dart';
import 'package:rescue_app/domain/services/api/rest_api_service.dart';
import 'package:rescue_app/models/user_group.dart';

class GroupsList extends StatefulWidget {
  const GroupsList({
    super.key,
  });

  @override
  State<GroupsList> createState() => _GroupsListState();
}

class _GroupsListState extends State<GroupsList> {
  // final groups = <({String name, String focus, int members})>[];
  final groups = <UserGroup>[];

  @override
  initState() {
    getUserGroups();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // const groups = <({String name, String focus, int members})>[
    //   (name: 'מוקד אלפא', focus: 'תיאום', members: 6),
    //   (name: 'רפואה בראבו', focus: 'אמבולנס', members: 8),
    //   (name: 'כיבוי צ׳רלי', focus: 'דיכוי אש', members: 5),
    //   (name: 'לוגיסטיקה דלתא', focus: 'אספקה', members: 4),
    // ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'קבוצות תגובה',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'ניהול הקבוצות המבצעיות ורמות האיוש הנוכחיות שלהן.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Icon(
                  Icons.groups_2_outlined,
                  size: 56,
                  color: Colors.blueGrey.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  'אין קבוצות להצגה כרגע',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          for (final group in groups)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.groups_2_outlined),
                title: Text(group.name),
                subtitle: Text(group.description),
                trailing: Text('${group.memberCount} חברים'),
              ),
            ),
      ],
    );
  }

  Future<void> getUserGroups() async {
    final groupsResult = await RestApiService().getUserGroups();
    setState(() {
      groups.clear();
      groups.addAll(groupsResult);
    });
    print('Fetched groups: $groupsResult');
  }
}
