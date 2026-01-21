import 'package:flutter/material.dart';

/// Widget para botones de login social (Google, Facebook, etc.)
/// NOTA: Requiere configuración adicional en Supabase
class SocialLoginButtons extends StatelessWidget {
  final bool isLoading;

  const SocialLoginButtons({
    super.key,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider con texto
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'O continúa con',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),

        // Botones sociales
        Row(
          children: [
            // Google
            Expanded(
              child: _SocialButton(
                icon: Icons.g_mobiledata, // Usa un icono de paquete real
                label: 'Google',
                onPressed: isLoading ? null : () => _loginWithGoogle(context),
              ),
            ),
            const SizedBox(width: 12),

            // Facebook (opcional)
            Expanded(
              child: _SocialButton(
                icon: Icons.facebook,
                label: 'Facebook',
                color: const Color(0xFF1877F2),
                onPressed: isLoading ? null : () => _loginWithFacebook(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _loginWithGoogle(BuildContext context) {
    // TODO: Implementar login con Google
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login con Google próximamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _loginWithFacebook(BuildContext context) {
    // TODO: Implementar login con Facebook
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login con Facebook próximamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const _SocialButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

