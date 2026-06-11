// import 'package:flutter/material.dart';

// class EventsTabScreen extends StatelessWidget {
//   const EventsTabScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     const events = <({String title, String priority, String location})>[
//       (
//         title: 'תאונת כביש מהיר',
//         priority: 'קריטי',
//         location: 'כביש A12 צפון',
//       ),
//       (
//         title: 'אזעקת שריפה במחסן',
//         priority: 'גבוה',
//         location: 'אזור הנמל, סקטור 4',
//       ),
//       (
//         title: 'בקשת העברה רפואית',
//         priority: 'בינוני',
//         location: 'מרפאת סנט אן',
//       ),
//     ];

//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         Text(
//           'אירועים חיים',
//           style: Theme.of(context).textTheme.headlineSmall,
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'מעקב אחר מצב האירוע ושליחת הקבוצה המתאימה במהירות.',
//           style: Theme.of(context).textTheme.bodyMedium,
//         ),
//         const SizedBox(height: 16),
//         for (final event in events)
//           Card(
//             margin: const EdgeInsets.only(bottom: 12),
//             child: ListTile(
//               leading: const Icon(Icons.warning_amber_rounded),
//               title: Text(event.title),
//               subtitle: Text(event.location),
//               trailing: Chip(label: Text(event.priority)),
//             ),
//           ),
//       ],
//     );
//   }
// }
