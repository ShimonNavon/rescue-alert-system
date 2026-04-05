import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../l10n/app_localizations.dart';
import '../logic/messages/message_details_cubit.dart';
import '../repositories/message_repository.dart';
import '../services/audio_service.dart';

class MessageDetailsScreen extends StatelessWidget {
  const MessageDetailsScreen({super.key, required this.messageId});

  final String messageId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (_) => MessageDetailsCubit(
        messageRepository: context.read<MessageRepository>(),
        audioService: context.read<AudioService>(),
      )..load(messageId),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.t('messageDetails'))),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<MessageDetailsCubit, MessageDetailsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final message = state.message;
              if (message == null) {
                return Center(
                  child: Text(state.errorMessage ?? 'No message found'),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(message.text),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.play_circle_outline),
                      title: const Text('Play voice message'),
                      onTap: () => context
                          .read<MessageDetailsCubit>()
                          .playMessageAudio(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: () => context
                            .read<MessageDetailsCubit>()
                            .startReplyRecording(),
                        icon: const Icon(Icons.mic),
                        label: Text(l10n.t('record')),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => context
                            .read<MessageDetailsCubit>()
                            .stopReplyRecordingAndSend(),
                        icon: const Icon(Icons.send),
                        label: Text(l10n.t('reply')),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
