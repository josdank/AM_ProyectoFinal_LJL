import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/security_bloc.dart';
import '../widgets/reference_card_widget.dart';
import '../../domain/entities/reference.dart';

class ReferencesPage extends StatefulWidget {
  const ReferencesPage({super.key});

  @override
  State<ReferencesPage> createState() => _ReferencesPageState();
}

class _ReferencesPageState extends State<ReferencesPage> {
  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('No autenticado')));
    }

    return BlocConsumer<SecurityBloc, SecurityState>(
      listener: (context, state) {
        if (state.error != null && state.error!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state.verificationCodeSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código de verificación enviado'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        return _ReferencesContent(userId: userId, state: state);
      },
    );
  }
}

class _ReferencesContent extends StatefulWidget {
  final String userId;
  final SecurityState state;

  const _ReferencesContent({
    required this.userId,
    required this.state,
  });

  @override
  State<_ReferencesContent> createState() => _ReferencesContentState();
}

class _ReferencesContentState extends State<_ReferencesContent> {
  @override
  void initState() {
    super.initState();
    // Cargar referencias si no se han cargado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.state.references.isEmpty) {
        context.read<SecurityBloc>().add(
          SecurityLoadRequested(userId: widget.userId),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    if (state.isLoading && state.references.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Referencias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
            tooltip: 'Ayuda',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<SecurityBloc>().add(
            SecurityLoadRequested(userId: widget.userId),
          );
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildStatsSection(context, state)),

            if (state.references.isEmpty)
              SliverFillRemaining(child: _buildEmptyState(context))
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final reference = state.references[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ReferenceCardWidget(
                        reference: reference,
                        userId: widget.userId,
                        onEdit: () => _editReference(context, reference),
                        onDelete: () => _deleteReference(context, reference),
                        onVerify: () => _verifyReference(context, reference),
                        onSendCode: () => _sendVerificationCode(context, reference),
                      ),
                    );
                  }, childCount: state.references.length),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addReference(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Agregar Referencia'),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, SecurityState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Tus Referencias',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                'Total',
                state.totalReferences.toString(),
                Icons.people_outline,
              ),
              _buildStatItem(
                context,
                'Verificadas',
                state.verifiedCount.toString(),
                Icons.verified_user,
              ),
              _buildStatItem(
                context,
                'Pendientes',
                (state.totalReferences - state.verifiedCount).toString(),
                Icons.pending_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No tienes referencias aún',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Las referencias ayudan a otros usuarios a conocerte mejor',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _addReference(context),
              icon: const Icon(Icons.add),
              label: const Text('Agregar primera referencia'),
            ),
          ],
        ),
      ),
    );
  }

  void _addReference(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        // Obtener el SecurityBloc del contexto principal
        final securityBloc = context.read<SecurityBloc>();
        
        return BlocProvider.value(
          value: securityBloc,
          child: _ReferenceFormSheet(
            onSubmit: (data) {
              // Usar el bloc del contexto principal
              securityBloc.add(
                SecurityAddReferenceRequested(
                  userId: widget.userId,
                  refereeName: data['name']!,
                  refereeEmail: data['email']!,
                  refereePhone: data['phone']!,
                  relationship: data['relationship']!,
                  comments: data['comments'],
                  rating: data['rating'] != null
                      ? int.tryParse(data['rating']!)
                      : null,
                ),
              );
              Navigator.pop(modalContext);
            },
          ),
        );
      },
    );
  }

  void _editReference(BuildContext context, Reference reference) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        // Obtener el SecurityBloc del contexto principal
        final securityBloc = context.read<SecurityBloc>();
        
        return BlocProvider.value(
          value: securityBloc,
          child: _ReferenceFormSheet(
            reference: reference,
            onSubmit: (data) {
              final updatedReference = Reference(
                id: reference.id,
                userId: reference.userId,
                refereeName: data['name']!,
                refereeEmail: data['email']!,
                refereePhone: data['phone']!,
                relationship: data['relationship']!,
                comment: data['comment'],
                rating: data['rating'] != null
                    ? int.tryParse(data['rating']!)
                    : null,
                verified: reference.verified,
                verificationCode: reference.verificationCode,
                codeExpiresAt: reference.codeExpiresAt,
                createdAt: reference.createdAt,
                updatedAt: DateTime.now(),
              );

              securityBloc.add(
                SecurityUpdateReferenceRequested(
                  userId: widget.userId,
                  reference: updatedReference,
                ),
              );
              Navigator.pop(modalContext);
            },
          ),
        );
      },
    );
  }

  void _deleteReference(BuildContext context, Reference reference) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar referencia'),
        content: Text(
          '¿Estás seguro de eliminar la referencia de ${reference.refereeName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<SecurityBloc>().add(
                SecurityDeleteReferenceRequested(
                  userId: widget.userId,
                  referenceId: reference.id,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _sendVerificationCode(BuildContext context, Reference reference) {
    context.read<SecurityBloc>().add(
      SecuritySendVerificationCodeRequested(
        referenceId: reference.id,
        refereeEmail: reference.refereeEmail,
      ),
    );
  }

  void _verifyReference(BuildContext context, Reference reference) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Verificar referencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ingresa el código que ${reference.refereeName} recibió por email',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Código de verificación',
                  hintText: '123456',
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final code = codeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  context.read<SecurityBloc>().add(
                    SecurityVerifyReferenceRequested(
                      userId: widget.userId,
                      referenceId: reference.id,
                      code: code,
                    ),
                  );
                }
              },
              child: const Text('Verificar'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cómo funcionan las referencias?'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Agregar referencias',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Personas que puedan hablar sobre tu experiencia como compañero de cuarto.',
              ),
              SizedBox(height: 12),
              Text(
                '2. Envía código de verificación',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Tu referencia recibirá un código por email.'),
              SizedBox(height: 12),
              Text(
                '3. Verifica la referencia',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Ingresa el código para marcar la referencia como verificada.',
              ),
              SizedBox(height: 12),
              Text(
                '4. Incrementa tu confianza',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Las referencias verificadas aumentan la confianza de otros usuarios.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

class _ReferenceFormSheet extends StatefulWidget {
  final Reference? reference;
  final Function(Map<String, String?>) onSubmit;

  const _ReferenceFormSheet({
    this.reference,
    required this.onSubmit,
  });

  @override
  State<_ReferenceFormSheet> createState() => _ReferenceFormSheetState();
}

class _ReferenceFormSheetState extends State<_ReferenceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _commentsController = TextEditingController();
  String _relationship = 'roommate';
  int? _rating;

  @override
  void initState() {
    super.initState();
    if (widget.reference != null) {
      _nameController.text = widget.reference!.refereeName;
      _emailController.text = widget.reference!.refereeEmail;
      _phoneController.text = widget.reference!.refereePhone;
      _relationship = widget.reference!.relationship;
      _commentsController.text = widget.reference!.comment ?? '';
      _rating = widget.reference!.rating;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.reference == null
                    ? 'Agregar Referencia'
                    : 'Editar Referencia',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo requerido';
                  if (!value!.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono *',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _relationship,
                decoration: const InputDecoration(
                  labelText: 'Relación *',
                  prefixIcon: Icon(Icons.people),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'roommate',
                    child: Text('Compañero de cuarto'),
                  ),
                  DropdownMenuItem(
                    value: 'landlord',
                    child: Text('Propietario anterior'),
                  ),
                  DropdownMenuItem(value: 'family', child: Text('Familiar')),
                  DropdownMenuItem(value: 'friend', child: Text('Amigo')),
                ],
                onChanged: (value) => setState(() => _relationship = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _commentsController,
                decoration: const InputDecoration(
                  labelText: 'Comentarios (opcional)',
                  prefixIcon: Icon(Icons.comment),
                  hintText: 'Ej: Vivimos juntos por 2 años',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Rating (opcional)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  return IconButton(
                    icon: Icon(
                      starValue <= (_rating ?? 0)
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => setState(() => _rating = starValue),
                  );
                }),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSubmit({
                      'name': _nameController.text.trim(),
                      'email': _emailController.text.trim(),
                      'phone': _phoneController.text.trim(),
                      'relationship': _relationship,
                      'comments': _commentsController.text.trim().isEmpty
                          ? null
                          : _commentsController.text.trim(),
                      'rating': _rating?.toString(),
                    });
                  }
                },
                child: Text(
                  widget.reference == null ? 'Agregar' : 'Actualizar',
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}