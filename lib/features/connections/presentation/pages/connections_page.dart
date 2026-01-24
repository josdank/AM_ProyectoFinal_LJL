import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/connection_bloc.dart' as conn;
import '../widgets/interest_card_widget.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key});

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
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
        title: const Text('Conexiones'),
      ),
      body: BlocBuilder<conn.ConnectionBloc, conn.ConnectionState>(
        builder: (context, state) {
          print('🔄 ConnectionsPage - Estado: ${state.runtimeType}');
          print('📊 ConnectionsPage - isLoading: ${state.isLoading}');
          print('📊 ConnectionsPage - error: ${state.error}');
          print('📊 ConnectionsPage - incoming: ${state.incoming.length}');
          print('📊 ConnectionsPage - outgoing: ${state.outgoing.length}');
          print('📊 ConnectionsPage - matches: ${state.matches.length}');

          // Cargar solo una vez, después de que el frame se haya renderizado
          if (!_hasLoaded && !state.isLoading) {
            _hasLoaded = true;
            print('🚀 ConnectionsPage - Disparando carga inicial...');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<conn.ConnectionBloc>().add(
                conn.ConnectionLoadRequested(userId: userId),
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
                      context.read<conn.ConnectionBloc>().add(
                        conn.ConnectionLoadRequested(userId: userId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Preparar pestañas
          final incomingPending = state.incoming
              .where((r) => r.status == 'pending')
              .toList();
          final outgoingPending = state.outgoing
              .where((r) => r.status == 'pending')
              .toList();

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Material(
                  color: Theme.of(context).colorScheme.primary,
                  child: TabBar(
                    indicatorColor: Theme.of(context).colorScheme.onPrimary,
                    labelColor: Theme.of(context).colorScheme.onPrimary,
                    unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                    tabs: const [
                      Tab(text: 'Recibidos'),
                      Tab(text: 'Enviados'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _RequestsList(
                        titleEmpty: 'No tienes intereses recibidos.',
                        requests: incomingPending,
                        isIncoming: true,
                        userId: userId,
                      ),
                      _RequestsList(
                        titleEmpty: 'No tienes intereses enviados.',
                        requests: outgoingPending,
                        isIncoming: false,
                        userId: userId,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RequestsList extends StatelessWidget {
  final String titleEmpty;
  final List requests;
  final bool isIncoming;
  final String userId;

  const _RequestsList({
    required this.titleEmpty,
    required this.requests,
    required this.isIncoming,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isIncoming ? Icons.inbox_outlined : Icons.send_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                titleEmpty,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final r = requests[index];
        print('📱 ConnectionsPage - Mostrando request: ${r.id}');

        return InterestCardWidget(
          request: r,
          isIncoming: isIncoming,
          onAccept: isIncoming
              ? () => context.read<conn.ConnectionBloc>().add(
                    conn.ConnectionAcceptRequested(
                      userId: userId,
                      requestId: r.id,
                    ),
                  )
              : null,
          onReject: isIncoming
              ? () => context.read<conn.ConnectionBloc>().add(
                    conn.ConnectionRejectRequested(
                      userId: userId,
                      requestId: r.id,
                    ),
                  )
              : null,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: requests.length,
    );
  }
}