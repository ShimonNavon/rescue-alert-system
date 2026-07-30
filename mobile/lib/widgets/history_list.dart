import 'package:flutter/material.dart';
import 'package:rescue_app/models/message.dart';
import 'package:rescue_app/widgets/message_audio.dart';
import 'package:rescue_app/widgets/message_text.dart';

class HistoryList extends StatelessWidget {
  final List<Message> messages;
  const HistoryList({required this.messages, super.key});

  // final List<
  //     ({
  //       IconData icon,
  //       String title,
  //       String subtitle,
  //       String date,
  //       String time
  //     })> items;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 64),
          Icon(
            Icons.history_toggle_off,
            size: 56,
            color: Colors.blueGrey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'אין הודעות להצגה כרגע',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final message = messages[index];
        final hasAudio = (message.voiceUrl?.trim().isNotEmpty ?? false) ||
            (message.voiceFile?.trim().isNotEmpty ?? false);

        return hasAudio
            ? MessageAudio(message: message)
            : MessageText(message: message);
      },
    );
  }
}
