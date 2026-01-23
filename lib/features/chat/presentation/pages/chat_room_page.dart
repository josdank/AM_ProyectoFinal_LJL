import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/chat_room.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/message_bubble_widget.dart';
import '../widgets/chat_input_widget.dart';

class ChatRoomPage extends StatefulWidget {
  final ChatRoom chatRoom;
  final String currentUserId;

  const ChatRoomPage({
    super.key,
    required this.chatRoom,
    required this.currentUserId,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final otherUserId = widget.chatRoom.getOtherUserId(widget.currentUserId);

    return BlocProvider(
      create: (_) => sl<ChatBloc>()
        ..add(ChatMessagesLoadRequested(chatRoomId: widget.chatRoom.id))
        ..add(ChatMessagesListenStarted(chatRoomId: widget.chatRoom.id))
        ..add(ChatMarkAsReadRequested(
          chatRoomId: widget.chatRoom.id,
          userId: widget.currentUserId,
        )),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.person),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuario $otherUserId',
                      style: const TextStyle(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'En línea',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                // TODO: Mostrar información del usuario
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Información próximamente')),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatMessagesLoaded) {
              _scrollToBottom();
            }
          },
          builder: (context, state) {
            if (state is ChatMessagesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ChatError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<ChatBloc>().add(
                              ChatMessagesLoadRequested(
                                  chatRoomId: widget.chatRoom.id),
                            );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is ChatMessagesLoaded) {
              return Column(
                children: [
                  // Lista de mensajes
                  Expanded(
                    child: state.messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_outlined,
                                    size: 80, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay mensajes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Envía un mensaje para empezar',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              final message = state.messages[index];
                              final isMe =
                                  message.senderId == widget.currentUserId;

                              return MessageBubbleWidget(
                                message: message,
                                isMe: isMe,
                              );
                            },
                          ),
                  ),

                  // Input de mensaje
                  ChatInputWidget(
                    onSend: (content) {
                      if (content.trim().isNotEmpty) {
                        context.read<ChatBloc>().add(
                              ChatMessageSendRequested(
                                chatRoomId: widget.chatRoom.id,
                                senderId: widget.currentUserId,
                                content: content.trim(),
                              ),
                            );
                      }
                    },
                    isSending: state.isSending,
                  ),
                ],
              );
            }

            return const Center(child: Text('Estado desconocido'));
          },
        ),
      ),
    );
  }
}