import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import 'auth_text_field.dart';
import 'auth_button.dart';

/// Widget reutilizable para el formulario de login
/// Útil si quieres usar el mismo formulario en múltiples lugares
class LoginFormWidget extends StatefulWidget {
  final VoidCallback? onRegisterPressed;
  final VoidCallback? onForgotPasswordPressed;

  const LoginFormWidget({
    super.key,
    this.onRegisterPressed,
    this.onForgotPasswordPressed,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email
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

              // Contraseña
              AuthTextField(
                controller: _passwordController,
                label: 'Contraseña',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                validator: Validators.validatePassword,
                enabled: !isLoading,
                onFieldSubmitted: (_) => _handleLogin(),
              ),

              // ¿Olvidaste tu contraseña?
              if (widget.onForgotPasswordPressed != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading ? null : widget.onForgotPasswordPressed,
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Botón Login
              AuthButton(
                text: 'Iniciar Sesión',
                onPressed: _handleLogin,
                isLoading: isLoading,
                icon: Icons.login,
              ),

              // Link a Registro
              if (widget.onRegisterPressed != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes cuenta? '),
                    TextButton(
                      onPressed: isLoading ? null : widget.onRegisterPressed,
                      child: const Text('Regístrate'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}