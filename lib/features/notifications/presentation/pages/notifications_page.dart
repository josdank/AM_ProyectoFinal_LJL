import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/notification_bloc.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _hasLoaded = false;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('No autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              _hasLoaded = false;
              context.read<NotificationBloc>().add(
                NotificationLoadRequested(userId: userId),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          print('🔄 NotificationsPage - Estado: ${state.runtimeType}');
          print('📊 NotificationsPage - isLoading: ${state.isLoading}');
          print('📊 NotificationsPage - error: ${state.error}');
          print('📊 NotificationsPage - notificaciones: ${state.notifications.length}');

          // Cargar solo una vez, después de que el frame se haya renderizado
          if (!_hasLoaded && !state.isLoading) {
            _hasLoaded = true;
            print('🚀 NotificationsPage - Disparando carga inicial...');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<NotificationBloc>().add(
                NotificationStarted(userId: userId),
              );
            });
          }

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Error: ${state.error!}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      _hasLoaded = false;
                      context.read<NotificationBloc>().add(
                        NotificationStarted(userId: userId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state.notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_none_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No tienes notificaciones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aquí aparecerán tus notificaciones importantes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _hasLoaded = false;
              context.read<NotificationBloc>().add(
                NotificationLoadRequested(userId: userId),
              );
              // Esperar un momento para que se carguen los datos
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final n = state.notifications[index];
                print('📱 NotificationsPage - Mostrando notificación: ${n.id}');
                
                final iconColor = n.isRead ? Colors.grey : Colors.blue;
                final icon = n.isRead 
                    ? Icons.notifications_outlined 
                    : Icons.notifications_active_outlined;

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(icon, color: iconColor),
                    ),
                    title: Text(
                      n.title,
                      style: TextStyle(
                        fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          n.body,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(n.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    trailing: !n.isRead
                        ? OutlinedButton(
                            onPressed: () => context.read<NotificationBloc>().add(
                              NotificationMarkReadRequested(
                                userId: userId,
                                notificationId: n.id,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(100, 36),
                            ),
                            child: const Text('Marcar leído'),
                          )
                        : null,
                    onTap: !n.isRead
                        ? () => context.read<NotificationBloc>().add(
                              NotificationMarkReadRequested(
                                userId: userId,
                                notificationId: n.id,
                              ),
                            )
                        : null,
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: state.notifications.length,
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Ahora mismo';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}