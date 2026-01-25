import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/auth_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  /// Roles soportados:
  /// - tenant (Arrendatario)
  /// - owner (Propietario)  [opcional / futuro]
  String _role = 'tenant';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              fullName: _nameController.text.trim().isEmpty
                  ? null
                  : _nameController.text.trim(),
              role: _role,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthRegistrationSuccess) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('¡Cuenta Creada!'),
                content: Text(
                  state.requiresEmailConfirmation
                      ? 'Hemos enviado un email de confirmación a ${state.email}. Por favor verifica tu email antes de iniciar sesión.'
                      : 'Tu cuenta ha sido creada exitosamente.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar diálogo
                      Navigator.of(context).pop(); // Volver a login
                    },
                    child: const Text('Entendido'),
                  ),
                ],
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.person_add_outlined,
                        size: 80,
                        color: cs.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Crear Cuenta',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completa los datos para registrarte',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // ==========================
                      // Selector de Rol (Actividad 1)
                      // ==========================
                      _RoleSelector(
                        value: _role,
                        enabled: !isLoading,
                        onChanged: (newRole) {
                          setState(() => _role = newRole);
                        },
                      ),

                      const SizedBox(height: 24),

                      AuthTextField(
                        controller: _nameController,
                        label: 'Nombre Completo',
                        hintText: 'Juan Pérez (Opcional)',
                        prefixIcon: Icons.person_outline,
                        keyboardType: TextInputType.name,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 16),

                      AuthTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'ejemplo@correo.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 16),

                      AuthTextField(
                        controller: _passwordController,
                        label: 'Contraseña',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: Validators.validatePassword,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 16),

                      AuthTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirmar Contraseña',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: _validateConfirmPassword,
                        enabled: !isLoading,
                        onFieldSubmitted: (_) => _handleRegister(),
                      ),
                      const SizedBox(height: 28),

                      AuthButton(
                        text: _role == 'tenant'
                            ? 'Crear cuenta como Arrendatario'
                            : 'Crear cuenta como Propietario',
                        onPressed: _handleRegister,
                        isLoading: isLoading,
                        icon: Icons.person_add,
                      ),

                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.primary.withOpacity(0.25)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: cs.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _role == 'tenant'
                                    ? 'Arrendatario: busca, filtra y guarda viviendas. Envía solicitudes y favoritos.'
                                    : 'Propietario: publica viviendas y gestiona interesados (puedes activarlo después).',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const _RoleSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget chip({
      required String role,
      required String title,
      required String subtitle,
      required IconData icon,
    }) {
      final selected = value == role;

      return InkWell(
        onTap: enabled ? () => onChanged(role) : null,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: selected ? cs.primary.withOpacity(0.12) : Colors.white,
            border: Border.all(
              color: selected ? cs.primary : Colors.black12,
              width: selected ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: selected ? cs.primary : Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : Colors.black54,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: selected
                    ? Icon(Icons.check_circle, key: ValueKey(role), color: cs.primary)
                    : const Icon(Icons.circle_outlined, color: Colors.black26),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Selecciona tu rol',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        chip(
          role: 'tenant',
          title: 'Arrendatario',
          subtitle: 'Buscar, filtrar y guardar viviendas',
          icon: Icons.search,
        ),
        const SizedBox(height: 12),
        chip(
          role: 'owner',
          title: 'Propietario',
          subtitle: 'Publicar viviendas y gestionar interesados',
          icon: Icons.home_work_outlined,
        ),
      ],
    );
  }
}
