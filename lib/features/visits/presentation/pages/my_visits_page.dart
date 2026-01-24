import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/visit.dart';
import '../bloc/visit_bloc.dart';
import '../widgets/visit_card_widget.dart';

class MyVisitsPage extends StatefulWidget {
  const MyVisitsPage({super.key});

  @override
  State<MyVisitsPage> createState() => _MyVisitsPageState();
}

class _MyVisitsPageState extends State<MyVisitsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          create: (_) => sl<VisitBloc>()
            ..add(VisitsLoadRequested(userId: authState.user.id)),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Mis Visitas'),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Mis Visitas', icon: Icon(Icons.person)),
                  Tab(text: 'A Mis Propiedades', icon: Icon(Icons.home)),
                ],
              ),
            ),
            body: BlocConsumer<VisitBloc, VisitState>(
              listener: (context, state) {
                if (state is VisitConfirmed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Visita confirmada')),
                  );
                  context.read<VisitBloc>().add(
                        VisitsLoadRequested(userId: authState.user.id),
                      );
                } else if (state is VisitCancelled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Visita cancelada')),
                  );
                  context.read<VisitBloc>().add(
                        VisitsLoadRequested(userId: authState.user.id),
                      );
                } else if (state is VisitError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is VisitsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is VisitError) {
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
                            context.read<VisitBloc>().add(
                                  VisitsLoadRequested(
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

                if (state is VisitsLoaded) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVisitsList(
                        context,
                        state.visits,
                        isOwner: false,
                        userId: authState.user.id,
                      ),
                      _buildVisitsList(
                        context,
                        state.visits,
                        isOwner: true,
                        userId: authState.user.id,
                      ),
                    ],
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

  Widget _buildVisitsList(
    BuildContext context,
    List<Visit> visits, {
    required bool isOwner,
    required String userId,
  }) {
    if (visits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 100, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isOwner
                  ? 'No hay visitas a tus propiedades'
                  : 'No tienes visitas agendadas',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Separar visitas por estado
    final upcoming = visits.where((v) => !v.isPast && !v.isCancelled).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    final past = visits.where((v) => v.isPast || v.isCancelled).toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    return RefreshIndicator(
      onRefresh: () async {
        context.read<VisitBloc>().add(
              VisitsLoadRequested(userId: userId, asOwner: isOwner),
            );
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (upcoming.isNotEmpty) ...[
            Text(
              'Próximas Visitas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...upcoming.map((visit) => VisitCardWidget(
                  visit: visit,
                  isOwner: isOwner,
                  onConfirm: isOwner
                      ? () {
                          context.read<VisitBloc>().add(
                                VisitConfirmRequested(visitId: visit.id),
                              );
                        }
                      : null,
                  onCancel: () {
                    _showCancelDialog(context, visit.id);
                  },
                )),
            const SizedBox(height: 24),
          ],
          if (past.isNotEmpty) ...[
            Text(
              'Visitas Pasadas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 12),
            ...past.map((visit) => VisitCardWidget(
                  visit: visit,
                  isOwner: isOwner,
                )),
          ],
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String visitId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Visita'),
        content: const Text('¿Estás seguro de cancelar esta visita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<VisitBloc>().add(
                    VisitCancelRequested(visitId: visitId),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }
}