import 'package:flutter/material.dart';

class HistoryTabScreen extends StatelessWidget {
  const HistoryTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const latelyItems = <({
      IconData icon,
      String title,
      String subtitle,
      String date,
      String time
    })>[
      (
        icon: Icons.warning_amber_rounded,
        title: 'התראת שטח',
        subtitle: 'התקבלה קריאה מאזור צפון',
        date: '28/04/2026',
        time: '09:21',
      ),
      (
        icon: Icons.call,
        title: 'שיחת מוקד',
        subtitle: 'שיחה נכנסת לצוות לוגיסטיקה',
        date: '28/04/2026',
        time: '08:47',
      ),
      (
        icon: Icons.location_on_outlined,
        title: 'עדכון מיקום',
        subtitle: 'צוות אמבולנס עודכן לנקודת מפגש',
        date: '28/04/2026',
        time: '08:12',
      ),
    ];

    const recentItems = <({
      IconData icon,
      String title,
      String subtitle,
      String date,
      String time
    })>[
      (
        icon: Icons.check_circle_outline,
        title: 'אירוע נסגר',
        subtitle: 'אירוע חילוץ הושלם בהצלחה',
        date: '27/04/2026',
        time: '22:05',
      ),
      (
        icon: Icons.groups_2_outlined,
        title: 'שיבוץ צוות',
        subtitle: 'צוות כיבוי שויך למשימה חדשה',
        date: '27/04/2026',
        time: '19:34',
      ),
      (
        icon: Icons.report_problem_outlined,
        title: 'חריגה בתגובה',
        subtitle: 'זמן תגובה חרג מהממוצע',
        date: '27/04/2026',
        time: '17:58',
      ),
    ];

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'לאחרונה'),
              Tab(text: 'יומן אירועים'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _HistoryList(items: latelyItems),
                _HistoryList(items: recentItems),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.items});

  final List<
      ({
        IconData icon,
        String title,
        String subtitle,
        String date,
        String time
      })> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: ListTile(
            leading: Icon(item.icon),
            title: Text(item.title),
            subtitle: Text(item.subtitle),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item.date),
                const SizedBox(height: 2),
                Text(
                  item.time,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
