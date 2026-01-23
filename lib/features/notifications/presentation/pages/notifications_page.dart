import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/notification_bloc.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('No autenticado')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<NotificationBloc>().add(NotificationLoadRequested(userId: userId)),
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (!state.isLoading && state.notifications.isEmpty) {
            context.read<NotificationBloc>().add(NotificationStarted(userId: userId));
          }

          if (state.isLoading) return const Center(child: CircularProgressIndicator());
          if (state.error != null) return Center(child: Text(state.error!));

          if (state.notifications.isEmpty) {
            return const Center(child: Text('No tienes notificaciones.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final n = state.notifications[index];
              return ListTile(
                leading: Icon(n.isRead ? Icons.notifications : Icons.notifications_active),
                title: Text(n.title),
                subtitle: Text(n.body),
                trailing: n.isRead
                    ? null
                    : TextButton(
                        onPressed: () => context.read<NotificationBloc>().add(
                              NotificationMarkReadRequested(userId: userId, notificationId: n.id),
                            ),
                        child: const Text('Marcar leído'),
                      ),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: state.notifications.length,
          );
        },
      ),
    );
  }
}
