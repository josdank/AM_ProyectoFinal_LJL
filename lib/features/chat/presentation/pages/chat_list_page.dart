import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/chat_room.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/chat_room_card_widget.dart';
import 'chat_room_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: Text('No autenticado')),
          );
        }

        return BlocProvider(
          create: (_) => sl<ChatBloc>()
            ..add(ChatRoomsLoadRequested(userId: authState.user.id)),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Mensajes'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<ChatBloc>().add(
                          ChatRoomsLoadRequested(userId: authState.user.id),
                        );
                  },
                ),
              ],
            ),
            body: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatRoomsLoading) {
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
                                  ChatRoomsLoadRequested(
                                      userId: authState.user.id),
                                );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ChatRoomsLoaded) {
                  if (state.chatRooms.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 100, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes conversaciones',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Haz match con otros usuarios para empezar a chatear',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ChatBloc>().add(
                            ChatRoomsLoadRequested(userId: authState.user.id),
                          );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: state.chatRooms.length,
                      itemBuilder: (context, index) {
                        final chatRoom = state.chatRooms[index];
                        return ChatRoomCardWidget(
                          chatRoom: chatRoom,
                          currentUserId: authState.user.id,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatRoomPage(
                                  chatRoom: chatRoom,
                                  currentUserId: authState.user.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }

                return const Center(child: Text('Estado desconocido'));
              },
            ),
          ),
        );
      },
    );
  }
}