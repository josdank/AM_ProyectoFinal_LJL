import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';

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
      // Determinar roles basados en la selección
      final roles = _role == 'tenant' 
          ? ['user', 'tenant'] // Usuario con rol de arrendatario
          : ['user', 'owner']; // Usuario con rol de propietario
      
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim(),
          roles: roles, // ENVIAR LISTA DE ROLES
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
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.requiresEmailConfirmation
                          ? 'Hemos enviado un email de confirmación a ${state.email}. Por favor verifica tu email antes de iniciar sesión.'
                          : 'Tu cuenta ha sido creada exitosamente.',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _role == 'tenant'
                            ? Colors.blue.shade50
                            : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _role == 'tenant'
                              ? Colors.blue.shade200
                              : Colors.amber.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _role == 'tenant'
                                ? Icons.search
                                : Icons.home_work_outlined,
                            color: _role == 'tenant'
                                ? Colors.blue
                                : Colors.amber.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _role == 'tenant'
                                  ? 'Tu cuenta es de tipo: Arrendatario'
                                  : 'Tu cuenta es de tipo: Propietario',
                              style: TextStyle(
                                color: _role == 'tenant'
                                    ? Colors.blue.shade800
                                    : Colors.amber.shade900,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                        _role == 'tenant' ? Icons.search : Icons.home_work_outlined,
                        size: 80,
                        color: _role == 'tenant' ? Colors.blue : Colors.amber,
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

                      Container(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _role == 'tenant' 
                                ? Colors.blue.shade600 
                                : Colors.amber.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _role == 'tenant' 
                                          ? Icons.search 
                                          : Icons.home_work_outlined,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _role == 'tenant'
                                          ? 'Crear Cuenta de Arrendatario'
                                          : 'Crear Cuenta de Propietario',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _role == 'tenant'
                              ? Colors.blue.withOpacity(0.08)
                              : Colors.amber.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _role == 'tenant'
                                ? Colors.blue.withOpacity(0.25)
                                : Colors.amber.withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: _role == 'tenant' ? Colors.blue : Colors.amber,
                            ),
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
            color: selected 
                ? (role == 'tenant' 
                    ? Colors.blue.withOpacity(0.12) 
                    : Colors.amber.withOpacity(0.12))
                : Colors.white,
            border: Border.all(
              color: selected 
                  ? (role == 'tenant' ? Colors.blue : Colors.amber)
                  : Colors.black12,
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
                  color: selected 
                      ? (role == 'tenant' ? Colors.blue : Colors.amber)
                      : Colors.black12,
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
                    ? Icon(
                        Icons.check_circle, 
                        key: ValueKey(role), 
                        color: role == 'tenant' ? Colors.blue : Colors.amber,
                      )
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