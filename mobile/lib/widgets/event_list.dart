import 'package:flutter/material.dart';
import 'package:rescue_app/models/alert_message.dart';

class EventsList extends StatelessWidget {
  const EventsList({
    required this.events,
    super.key,
  });

  final List<AlertMessage> events;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('עדכוני אירועים',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'צפייה ומעקב אחר אירועים פעילים במקום אחד.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        if (events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy_outlined,
                  size: 56,
                  color: Colors.blueGrey.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  'אין אירועים להצגה כרגע',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          for (final event in events)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded),
                title: Text(event.title),
                subtitle: Text(event.location),
                trailing: Chip(label: Text(event.status)),
              ),
            ),
      ],
    );
  }
}
