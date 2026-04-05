import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../logic/messages/messages_bloc.dart';
import '../models/app_message.dart';
import '../repositories/message_repository.dart';

class MessageQueueScreen extends StatelessWidget {
  const MessageQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MessagesBloc(messageRepository: context.read<MessageRepository>())
            ..add(MessagesStarted()),
      child: BlocBuilder<MessagesBloc, MessagesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<MessagesBloc>().add(MessagesRefreshRequested()),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final message = state.messages[index];
                return _MessageTile(message: message);
              },
            ),
          );
        },
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message});

  final AppMessage message;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.record_voice_over),
      title: Text(message.title),
      subtitle: Text(message.text),
      trailing: Text(
        '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
      ),
      onTap: () => context.push('/messages/${message.id}'),
    );
  }
}
