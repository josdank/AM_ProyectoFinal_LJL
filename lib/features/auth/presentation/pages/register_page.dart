import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

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
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Crear Cuenta',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completa los datos para registrarte',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      
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
                      const SizedBox(height: 32),
                      
                      AuthButton(
                        text: 'Crear Cuenta',
                        onPressed: _handleRegister,
                        isLoading: isLoading,
                        icon: Icons.person_add,
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