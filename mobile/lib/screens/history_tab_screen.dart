import 'package:flutter/material.dart';
import 'package:rescue_app/domain/services/api/rest_api_service.dart';
import 'package:rescue_app/models/message.dart';
import 'package:rescue_app/widgets/history_list.dart';

class HistoryTabScreen extends StatefulWidget {
  const HistoryTabScreen({super.key});

  @override
  State<HistoryTabScreen> createState() => _HistoryTabScreenState();
}

class _HistoryTabScreenState extends State<HistoryTabScreen> {
  final List<Message> messages = [];

  @override
  initState() {
    getMessages();
    super.initState();
  }

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
          // HistoryList(messages: messages),
          Expanded(
            child: TabBarView(
              children: [
                HistoryList(messages: messages),
                HistoryList(messages: messages),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future getMessages() async {
    RestApiService api = RestApiService();
    try {
      final messagesResult = await api.getMessages();
      print('messages: $messages');
      setState(() {
        messages.clear();
        messages.addAll(messagesResult);
      });
    } catch (e) {
      print('error fetching user details: $e');
    }
  }
}
