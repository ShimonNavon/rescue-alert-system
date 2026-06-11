import 'package:flutter/material.dart';

class GroupsList extends StatelessWidget {
  const GroupsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const groups = <({String name, String focus, int members})>[
      (name: 'מוקד אלפא', focus: 'תיאום', members: 6),
      (name: 'רפואה בראבו', focus: 'אמבולנס', members: 8),
      (name: 'כיבוי צ׳רלי', focus: 'דיכוי אש', members: 5),
      (name: 'לוגיסטיקה דלתא', focus: 'אספקה', members: 4),
    ];

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
        for (final group in groups)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.groups_2_outlined),
              title: Text(group.name),
              subtitle: Text(group.focus),
              trailing: Text('${group.members} חברים'),
            ),
          ),
      ],
    );
  }
}
