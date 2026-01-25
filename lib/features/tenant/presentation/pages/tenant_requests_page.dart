import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../cubit/tenant_cubit.dart';

class TenantRequestsPage extends StatelessWidget {
  const TenantRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    return BlocBuilder<TenantCubit, TenantState>(
      builder: (context, state) {
        if (state.loading) return const Center(child: CircularProgressIndicator());
        if (state.error != null) return Center(child: Text(state.error!, textAlign: TextAlign.center));

        if (state.applications.isEmpty) {
          return const Center(child: Text('No has enviado solicitudes todavía.'));
        }

        return RefreshIndicator(
          onRefresh: () async => context.read<TenantCubit>().loadAll(tenantId: userId),
          child: ListView.separated(
            padding: const EdgeInsets.all(14),
            itemBuilder: (context, i) {
              final a = state.applications[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Listing ID: ${a.listingId}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text('Estado: '),
                          _StatusChip(status: a.status),
                        ],
                      ),
                      if (a.message != null && a.message!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text('Mensaje: ${a.message}'),
                      ],
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: a.status == 'pending'
                              ? () => context.read<TenantCubit>().cancelApplication(
                                    tenantId: userId,
                                    applicationId: a.id,
                                  )
                              : null,
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Cancelar'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: state.applications.length,
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'accepted' => ('Aceptada', Colors.green),
      'rejected' => ('Rechazada', Colors.red),
      _ => ('Pendiente', Colors.orange),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
    );
  }
}