import 'package:flutter/material.dart';
import 'package:rescue_app/domain/services/api/rest_api_service.dart';
import 'package:rescue_app/models/alert_message.dart';
import 'package:rescue_app/widgets/event_list.dart';

class EventTabScreen extends StatefulWidget {
  const EventTabScreen({super.key});

  @override
  State<EventTabScreen> createState() => _EventTabScreenState();
}

class _EventTabScreenState extends State<EventTabScreen> {
  final openEvents = <AlertMessage>[];
  final closedEvents = <AlertMessage>[];

  // final openEvents = <AlertMessage>[
  //   AlertMessage(
  //     id: 0,
  //     title: 'התנגשות בצד הדרך',
  //     status: 'קריטי',
  //     location: 'כביש A12 צפון',
  //     latitude: 0.0,
  //     longitude: 0.0,
  //     priority: 'heigh',
  //     description: 'התנגשות בין שני רכבים בצד הדרך, ישנם פצועים במקום',
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //   ),
  //   AlertMessage(
  //     id: 0,
  //     title: 'אזעקת מחסן',
  //     status: 'גבוה',
  //     location: 'אזור הנמל, סקטור 4',
  //     latitude: 0.0,
  //     longitude: 0.0,
  //     priority: 'medium',
  //     description:
  //         'אזעקת מחסן באזור הנמל, סקטור 4, יש לבדוק את המצב ולפעול בהתאם.',
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //   ),
  //   AlertMessage(
  //     id: 0,
  //     title: 'העברה רפואית',
  //     status: 'בינוני',
  //     location: 'מרפאת סנט אן',
  //     latitude: 0.0,
  //     longitude: 0.0,
  //     priority: 'medium',
  //     description: 'העברה רפואית של מטופל עם בעיות נשימה',
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //   ),
  // ];

  // final closedEvents = <AlertMessage>[
  //   AlertMessage(
  //     id: 0,
  //     title: 'שריפת בניין',
  //     status: 'קריטי',
  //     location: 'קניון בעיר',
  //     description: 'שריפת בניין בקניון בעיר, צוותי כיבוי פועלים במקום',
  //     latitude: 0.0,
  //     longitude: 0.0,
  //     priority: 'high',
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //   ),
  //   AlertMessage(
  //     id: 0,
  //     title: 'תאונת עבודה',
  //     status: 'גבוה',
  //     location: 'מפעל בתעשיה',
  //     description: 'תאונת עבודה במפעל בתעשיה, פועל נפגע ונזקק לטיפול רפואי',
  //     latitude: 0.0,
  //     longitude: 0.0,
  //     priority: 'high',
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //   ),
  // ];

  @override
  void initState() {
    getAlerts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'open event (${openEvents.length})'),
              Tab(text: 'closed events (${closedEvents.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                EventsList(
                  events: openEvents,
                  // key: UniqueKey(),
                ),
                EventsList(
                  events: closedEvents,
                  // key: UniqueKey(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future getAlerts() async {
    final List<AlertMessage> alertsResult =
        await RestApiService().getAllAlerts();
    setState(() {
      openEvents.clear();
      closedEvents.clear();
      for (final alert in alertsResult) {
        if (alert.status.toLowerCase() == 'closed') {
          closedEvents.add(alert);
        } else if (alert.status.toLowerCase() == 'open') {
          openEvents.add(alert);
        }
      }
    });
    print('Fetched open events: $openEvents');
    print('Fetched closed events: $closedEvents');
  }
}
