import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/ljl_theme.dart'; // Asegúrate de importar tu tema
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

  // Variables para el tipo de cuenta
  String _accountType = 'normal'; // 'normal' o 'tenant'
  bool _showTenantInfo = false;

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
      // Determinar roles basado en la selección
      final roles = _accountType == 'tenant' 
          ? ['user', 'tenant'] // Usuario con rol de arrendatario
          : ['user']; // Usuario normal
      
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
                        color: _accountType == 'tenant'
                            ? Colors.blue.shade50
                            : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _accountType == 'tenant'
                              ? Colors.blue.shade200
                              : Colors.amber.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _accountType == 'tenant'
                                ? Icons.home_work_outlined
                                : Icons.person_outline,
                            color: _accountType == 'tenant'
                                ? Colors.blue
                                : Colors.amber.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _accountType == 'tenant'
                                  ? 'Tu cuenta es de tipo: Arrendatario'
                                  : 'Tu cuenta es de tipo: Normal',
                              style: TextStyle(
                                color: _accountType == 'tenant'
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
                      // Icono animado según tipo de cuenta
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: _accountType == 'tenant'
                              ? Colors.blue.shade100
                              : Colors.amber.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _accountType == 'tenant'
                                ? Colors.blue
                                : Colors.amber,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _accountType == 'tenant'
                              ? Icons.home_work_outlined
                              : Icons.person_outline,
                          size: 50,
                          color: _accountType == 'tenant'
                              ? Colors.blue
                              : Colors.amber.shade800,
                        ),
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
                        'Selecciona el tipo de cuenta que deseas crear',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),

                      // =============== SELECTOR DE TIPO DE CUENTA ===============
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título de la sección
                            Row(
                              children: [
                                Icon(
                                  Icons.account_circle_outlined,
                                  color: Colors.blueGrey.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tipo de Cuenta',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blueGrey.shade800,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Opción 1: Cuenta Normal
                            _buildAccountOption(
                              title: 'Cuenta Normal',
                              description: 'Para explorar la aplicación y conocer sus funciones básicas',
                              icon: Icons.person_outline,
                              iconColor: Colors.amber,
                              isSelected: _accountType == 'normal',
                              onTap: !isLoading
                                  ? () {
                                      setState(() {
                                        _accountType = 'normal';
                                        _showTenantInfo = false;
                                      });
                                    }
                                  : null,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Opción 2: Arrendatario
                            _buildAccountOption(
                              title: 'Arrendatario',
                              description: 'Para buscar habitaciones y encontrar compañeros de piso',
                              icon: Icons.home_work_outlined,
                              iconColor: Colors.blue,
                              isSelected: _accountType == 'tenant',
                              onTap: !isLoading
                                  ? () {
                                      setState(() {
                                        _accountType = 'tenant';
                                        _showTenantInfo = true;
                                      });
                                    }
                                  : null,
                            ),
                            
                            // Información adicional para arrendatario
                            if (_showTenantInfo)
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: _buildTenantInfoCard(),
                              ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),

                      // =============== FORMULARIO DE REGISTRO ===============
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

                      // =============== BOTÓN DE REGISTRO ===============
                      Container(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accountType == 'tenant'
                                ? Colors.blue.shade600
                                : Colors.amber.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                            shadowColor: _accountType == 'tenant'
                                ? Colors.blue.shade200
                                : Colors.amber.shade200,
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
                                      _accountType == 'tenant'
                                          ? Icons.home_work_outlined
                                          : Icons.person_add,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _accountType == 'tenant'
                                          ? 'Crear Cuenta de Arrendatario'
                                          : 'Crear Cuenta Normal',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // =============== TÉRMINOS Y CONDICIONES ===============
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.security_outlined,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Al registrarte, aceptas nuestros ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navegar a términos y condiciones
                            },
                            child: Text(
                              'Términos',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Text(
                            ' y ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navegar a política de privacidad
                            },
                            child: Text(
                              'Privacidad',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
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

  // =============== MÉTODO PARA CONSTRUIR OPCIÓN DE CUENTA ===============
  Widget _buildAccountOption({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? iconColor.withOpacity(0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? iconColor.withOpacity(0.5)
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: iconColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Icono circular
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? iconColor.withOpacity(0.15)
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? iconColor : Colors.grey.shade600,
                size: 26,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Contenido textual
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isSelected
                                ? Colors.blueGrey.shade900
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      
                      // Indicador de selección
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: iconColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: iconColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Seleccionado',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: iconColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============== TARJETA DE INFORMACIÓN PARA ARRENDATARIO ===============
  Widget _buildTenantInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.lightBlue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rocket_launch_outlined,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Ventajas de ser Arrendatario',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Lista de beneficios
          _buildBenefitItem(
            icon: Icons.search_outlined,
            text: 'Buscar habitaciones disponibles',
          ),
          
          const SizedBox(height: 8),
          
          _buildBenefitItem(
            icon: Icons.chat_outlined,
            text: 'Contactar directamente con arrendadores',
          ),
          
          const SizedBox(height: 8),
          
          _buildBenefitItem(
            icon: Icons.calendar_today_outlined,
            text: 'Programar visitas a propiedades',
          ),
          
          const SizedBox(height: 8),
          
          _buildBenefitItem(
            icon: Icons.favorite_outline,
            text: 'Guardar propiedades favoritas',
          ),
          
          const SizedBox(height: 8),
          
          _buildBenefitItem(
            icon: Icons.notifications_active_outlined,
            text: 'Recibir notificaciones de nuevas propiedades',
          ),
          
          const SizedBox(height: 12),
          
          // Nota adicional
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.shade100,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Puedes cambiar tu tipo de cuenta más tarde en la configuración',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============== ITEM DE BENEFICIO ===============
  Widget _buildBenefitItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.blue.shade600,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.blueGrey.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}