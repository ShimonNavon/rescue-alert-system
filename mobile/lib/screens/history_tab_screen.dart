import 'package:flutter/material.dart';
import 'package:rescue_app/widgets/history_list.dart';

class HistoryTabScreen extends StatelessWidget {
  const HistoryTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // const latelyItems = <({
    //   IconData icon,
    //   String title,
    //   String subtitle,
    //   String date,
    //   String time
    // })>[
    //   (
    //     icon: Icons.warning_amber_rounded,
    //     title: 'התראת שטח',
    //     subtitle: 'התקבלה קריאה מאזור צפון',
    //     date: '28/04/2026',
    //     time: '09:21',
    //   ),
    //   (
    //     icon: Icons.call,
    //     title: 'שיחת מוקד',
    //     subtitle: 'שיחה נכנסת לצוות לוגיסטיקה',
    //     date: '28/04/2026',
    //     time: '08:47',
    //   ),
    //   (
    //     icon: Icons.location_on_outlined,
    //     title: 'עדכון מיקום',
    //     subtitle: 'צוות אמבולנס עודכן לנקודת מפגש',
    //     date: '28/04/2026',
    //     time: '08:12',
    //   ),
    // ];

    // const recentItems = <({
    //   IconData icon,
    //   String title,
    //   String subtitle,
    //   String date,
    //   String time
    // })>[
    //   (
    //     icon: Icons.check_circle_outline,
    //     title: 'אירוע נסגר',
    //     subtitle: 'אירוע חילוץ הושלם בהצלחה',
    //     date: '27/04/2026',
    //     time: '22:05',
    //   ),
    //   (
    //     icon: Icons.groups_2_outlined,
    //     title: 'שיבוץ צוות',
    //     subtitle: 'צוות כיבוי שויך למשימה חדשה',
    //     date: '27/04/2026',
    //     time: '19:34',
    //   ),
    //   (
    //     icon: Icons.report_problem_outlined,
    //     title: 'חריגה בתגובה',
    //     subtitle: 'זמן תגובה חרג מהממוצע',
    //     date: '27/04/2026',
    //     time: '17:58',
    //   ),
    // ];

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
                HistoryList(items: latelyItems),
                HistoryList(items: recentItems),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
