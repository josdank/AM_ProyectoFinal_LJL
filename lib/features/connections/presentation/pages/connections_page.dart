import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/connection_bloc.dart' as conn;
import '../widgets/interest_card_widget.dart';

class ConnectionsPage extends StatelessWidget {
  const ConnectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('No autenticado')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conexiones'),
      ),
      body: BlocBuilder<conn.ConnectionBloc, conn.ConnectionState>(
        builder: (context, state) {
          if (!state.isLoading &&
              state.incoming.isEmpty &&
              state.outgoing.isEmpty &&
              state.matches.isEmpty) {
            // Cargar una vez
            context.read<conn.ConnectionBloc>().add(
                  conn.ConnectionLoadRequested(userId: userId),
                );
          }

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Text(state.error!, textAlign: TextAlign.center),
            );
          }

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Recibidos'),
                    Tab(text: 'Enviados'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _RequestsList(
                        titleEmpty: 'No tienes intereses recibidos.',
                        requests: state.incoming
                            .where((r) => r.status == 'pending')
                            .toList(),
                        isIncoming: true,
                        userId: userId,
                      ),
                      _RequestsList(
                        titleEmpty: 'No tienes intereses enviados.',
                        requests: state.outgoing,
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
      return Center(child: Text(titleEmpty));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final r = requests[index];

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
