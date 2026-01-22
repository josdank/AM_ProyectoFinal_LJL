import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'core/di/injection_container.dart' as di;
import 'core/config/supabase_config.dart';
import 'core/di/injection_container.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool envLoaded = false;
  bool supabaseInitialized = false;

  // 1. Cargar variables de entorno
  try {
    await dotenv.load(fileName: '.env');
    envLoaded = true;
    print('✅ Variables de entorno cargadas');

    // Validar configuración
    SupabaseConfig.validate();
    print('✅ Configuración validada');
  } catch (e) {
    print('⚠️ Error cargando .env o validando configuración: $e');
    print('📝 Crea un archivo .env con SUPABASE_URL y SUPABASE_ANON_KEY');
  }

  // 2. Inicializar Supabase
  if (envLoaded) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      supabaseInitialized = true;
      print('✅ Supabase inicializado');

      // ✅ CORRECCIÓN: Test de conexión (API actualizada)
      try {
        final response = await Supabase.instance.client
            .from('profiles')
            .select()
            .count(CountOption.exact);

        print('✅ Conexión exitosa - Perfiles en DB: ${response.count}');
      } catch (e) {
        print('⚠️ No se pudo verificar la conexión a la tabla profiles: $e');
        print('   (Esto es normal si la tabla aún no existe)');
      }
    } catch (e) {
      print('❌ Error inicializando Supabase: $e');
    }
  }

  // 3. Inicializar dependencias
  await di.initDependencies();
  print('✅ Dependencias inicializadas');

  runApp(
    MyApp(
      envLoaded: envLoaded,
      supabaseInitialized: supabaseInitialized,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool envLoaded;
  final bool supabaseInitialized;

  const MyApp({
    super.key,
    required this.envLoaded,
    required this.supabaseInitialized,
  });

  @override
  Widget build(BuildContext context) {
    if (!envLoaded || !supabaseInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Error de configuración.\n\nRevisa tu archivo .env y la conexión a Supabase.',
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => di.sl<AuthBloc>()..add(const AuthCheckRequested()),
      child: MaterialApp(
        title: 'Busca Compañero',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF667EEA),
            brightness: Brightness.light,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Maneja navegación según autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // ✅ MEJORA: Mostrar mensajes de error si hay problemas
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        // Verificando sesión
        if (state is AuthLoading && state.message == 'Verificando sesión...') {
          return const SplashScreen();
        }

        // Autenticado → HomePage
        if (state is AuthAuthenticated) {
          return const HomePage();
        }

        // No autenticado → LoginPage
        return const LoginPage();
      },
    );
  }
}

/// Splash inicial
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Busca Compañero',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

/// HomePage - Pantalla principal después del login
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ CORRECCIÓN: Crear ProfileBloc UNA SOLA VEZ y cargarlo automáticamente
    return BlocProvider(
      create: (context) {
        final authState = context.read<AuthBloc>().state;
        final bloc = sl<ProfileBloc>();

        // Cargar perfil automáticamente
        if (authState is AuthAuthenticated) {
          bloc.add(ProfileLoadRequested(userId: authState.user.id));
        }

        return bloc;
      },
      child: const _HomePageContent(),
    );
  }
}

/// Contenido de HomePage separado para tener acceso a ProfileBloc
class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Busca Compañero'),
        actions: [
          // ✅ Icono de perfil con badge si perfil incompleto
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              final hasIncompleteProfile = profileState is ProfileLoaded &&
                  !profileState.profile.isProfileComplete;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () => _navigateToProfile(context),
                  ),
                  if (hasIncompleteProfile)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Botón de logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              // Mientras carga el perfil
              if (profileState is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Error al cargar perfil
              if (profileState is ProfileError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        profileState.message,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<ProfileBloc>().add(
                                ProfileLoadRequested(userId: authState.user.id),
                              );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              // Perfil cargado correctamente
              if (profileState is ProfileLoaded) {
                return _buildWelcomeScreen(
                  context,
                  authState.user.email,
                  profileState.profile.isProfileComplete,
                );
              }

              // Estado desconocido
              return const Center(
                child: Text('Estado desconocido'),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWelcomeScreen(
    BuildContext context,
    String email,
    bool isProfileComplete,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isProfileComplete
                  ? Icons.check_circle_outline
                  : Icons.account_circle_outlined,
              size: 100,
              color: isProfileComplete ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              '¡Bienvenido!',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // ✅ Botón principal
            ElevatedButton.icon(
              onPressed: () => _navigateToProfile(context),
              icon: const Icon(Icons.person),
              label: Text(
                isProfileComplete ? 'Ver Mi Perfil' : 'Completar Perfil',
              ),
            ),

            // ✅ Mensaje si perfil incompleto
            if (!isProfileComplete) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Completa tu perfil para mejorar tu experiencia',
                        style: TextStyle(color: Colors.orange),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileBloc>(),
          child: const ProfilePage(),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}