import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/security_bloc.dart';
import 'references_page.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _reportedIdCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final _blockIdCtrl = TextEditingController();
  String _verificationType = 'estudiante';

  @override
  void dispose() {
    _reportedIdCtrl.dispose();
    _reasonCtrl.dispose();
    _detailsCtrl.dispose();
    _blockIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('No autenticado')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Verificación y Seguridad')),
      body: BlocBuilder<SecurityBloc, SecurityState>(
        builder: (context, state) {
          if (!state.isLoading && state.verification == null && state.blockedUsers.isEmpty) {
            context.read<SecurityBloc>().add(SecurityLoadRequested(userId: userId));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ===== SECCIÓN DE REFERENCIAS (NUEVO) =====
              _Section(
                title: 'Referencias de Convivencia',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Referencias verificadas: ${state.verifiedCount} de ${state.totalReferences}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Las referencias ayudan a otros usuarios a conocerte mejor y aumentan tu credibilidad.',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<SecurityBloc>(),
                              child: const ReferencesPage(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.people),
                      label: const Text('Gestionar Referencias'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // ===== VERIFICACIÓN DE IDENTIDAD =====
              _Section(
                title: 'Verificación de identidad',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.verification == null
                          ? 'Estado: No enviada'
                          : 'Estado: ${state.verification!.status} · Tipo: ${state.verification!.type}',
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _verificationType,
                      items: const [
                        DropdownMenuItem(value: 'estudiante', child: Text('Estudiante')),
                        DropdownMenuItem(value: 'trabajador', child: Text('Trabajador')),
                      ],
                      onChanged: (v) => setState(() => _verificationType = v ?? 'estudiante'),
                      decoration: const InputDecoration(labelText: 'Tipo de verificación'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: state.isActionLoading
                          ? null
                          : () => context.read<SecurityBloc>().add(
                                SecuritySubmitVerificationRequested(userId: userId, type: _verificationType),
                              ),
                      icon: const Icon(Icons.verified_user),
                      label: const Text('Enviar verificación'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Nota: La aprobación depende del administrador.',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // ===== REPORTAR USUARIO =====
              _Section(
                title: 'Reportar usuario',
                child: Column(
                  children: [
                    TextField(
                      controller: _reportedIdCtrl,
                      decoration: const InputDecoration(labelText: 'ID del usuario a reportar'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _reasonCtrl,
                      decoration: const InputDecoration(labelText: 'Motivo'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _detailsCtrl,
                      decoration: const InputDecoration(labelText: 'Detalles (opcional)'),
                      minLines: 2,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: state.isActionLoading
                          ? null
                          : () {
                              context.read<SecurityBloc>().add(
                                    SecurityReportUserRequested(
                                      reporterId: userId,
                                      reportedId: _reportedIdCtrl.text.trim(),
                                      reason: _reasonCtrl.text.trim(),
                                      details: _detailsCtrl.text.trim().isEmpty ? null : _detailsCtrl.text.trim(),
                                    ),
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Reporte enviado')),
                              );
                            },
                      icon: const Icon(Icons.flag),
                      label: const Text('Enviar reporte'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // ===== BLOQUEAR USUARIO =====
              _Section(
                title: 'Bloquear usuario',
                child: Column(
                  children: [
                    TextField(
                      controller: _blockIdCtrl,
                      decoration: const InputDecoration(labelText: 'ID del usuario a bloquear'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: state.isActionLoading
                          ? null
                          : () => context.read<SecurityBloc>().add(
                                SecurityBlockUserRequested(blockerId: userId, blockedId: _blockIdCtrl.text.trim()),
                              ),
                      icon: const Icon(Icons.block),
                      label: const Text('Bloquear'),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Bloqueados (${state.blockedUsers.length})', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 8),
                    if (state.blockedUsers.isEmpty)
                      const Text('Aún no has bloqueado a nadie.', style: TextStyle(color: Colors.black54))
                    else
                      ...state.blockedUsers.map((b) => ListTile(
                            leading: const Icon(Icons.person_off),
                            title: Text(b.blockedId),
                            subtitle: Text('Desde: ${b.createdAt.toLocal()}'),
                          )),
                  ],
                ),
              ),
              if (state.error != null) ...[
                const SizedBox(height: 16),
                Text(state.error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}