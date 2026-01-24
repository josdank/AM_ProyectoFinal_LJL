import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/connection_bloc.dart' as conn;
import '../widgets/match_card_widget.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
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
        title: const Text('Matches'),
      ),
      body: BlocBuilder<conn.ConnectionBloc, conn.ConnectionState>(
        builder: (context, state) {
          print('🔄 MatchesPage - Estado: ${state.runtimeType}');
          print('📊 MatchesPage - isLoading: ${state.isLoading}');
          print('📊 MatchesPage - error: ${state.error}');
          print('📊 MatchesPage - matches: ${state.matches.length}');

          // Cargar solo una vez, después de que el frame se haya renderizado
          if (!_hasLoaded && !state.isLoading) {
            _hasLoaded = true;
            print('🚀 MatchesPage - Disparando carga inicial...');
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

          if (state.matches.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.handshake_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aún no tienes matches',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cuando alguien también muestre interés en ti, aparecerá aquí.',
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
              context.read<conn.ConnectionBloc>().add(
                conn.ConnectionLoadRequested(userId: userId),
              );
              // Esperar un momento para que se carguen los datos
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final match = state.matches[index];
                print('📱 MatchesPage - Mostrando match: ${match.id}');
                
                return MatchCardWidget(
                  match: match,
                  myUserId: userId,
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: state.matches.length,
            ),
          );
        },
      ),
    );
  }
}