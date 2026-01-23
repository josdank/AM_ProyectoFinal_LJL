import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/connection_bloc.dart' as conn;
import '../widgets/match_card_widget.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('No autenticado')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
      ),
      body: BlocBuilder<conn.ConnectionBloc, conn.ConnectionState>(
        builder: (context, state) {
          if (!state.isLoading && state.matches.isEmpty) {
            context.read<conn.ConnectionBloc>().add(
                  conn.ConnectionLoadRequested(userId: userId),
                );
          }

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(child: Text(state.error!));
          }

          if (state.matches.isEmpty) {
            return const Center(child: Text('Aún no tienes matches.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) => MatchCardWidget(
              match: state.matches[index],
              myUserId: userId,
            ),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: state.matches.length,
          );
        },
      ),
    );
  }
}
