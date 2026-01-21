import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

// Dependency Injection
import 'core/di/injection_container.dart' as di;

// Auth
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool envLoaded = false;
  bool supabaseInitialized = false;

  // 1. Cargar variables de entorno
  try {
    await dotenv.load(fileName: '.env');
    envLoaded = true;
    print('✅ Variables de entorno cargadas');
  } catch (e) {
    print('⚠️ Error cargando .env: $e');
    print('📝 Crea un archivo .env con SUPABASE_URL y SUPABASE_ANON_KEY');
  }

  // 2. Inicializar Supabase
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
    supabaseInitialized = true;
    print('✅ Supabase inicializado');
  } catch (e) {
    print('❌ Error inicializando Supabase: $e');
  }
// Test de conexión
try {
  final response = await Supabase.instance.client
      .from('profiles')
      .select('count')
      .count(CountOption.exact);
  
    print('✅ Conexión a Supabase exitosa');
    print('📊 Perfiles en DB: ${response.count}');
  } catch (e) {
    print('❌ Error de conexión: $e');
  }

  // 3. Inicializar dependencias
  await di.initDependencies();
  print('✅ Dependencias inicializadas');

  runApp(MyApp(envLoaded: envLoaded, supabaseInitialized: supabaseInitialized));
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
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Error de configuración. Revisa tu archivo .env y la conexión a Supabase.',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => di.sl<AuthBloc>()..add(const AuthCheckRequested()),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Widget que maneja la navegación basada en el estado de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Aquí puedes manejar efectos secundarios si es necesario
      },
      builder: (context, state) {
        // Mientras verifica la sesión
        if (state is AuthLoading && state.message == 'Verificando sesión...') {
          return const SplashScreen();
        }

        // Si está autenticado
        if (state is AuthAuthenticated) {
          return const HomePage();
        }

        // Si no está autenticado
        return const LoginPage();
      },
    );
  }
}

/// Pantalla de carga inicial
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
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

/// Home Page temporal (reemplazar con tu diseño)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.read<AuthBloc>().add(
                          const AuthLogoutRequested(),
                        );
                      },
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 100,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '¡Bienvenido!',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.user.email,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    if (state.user.fullName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.user.fullName!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                    const SizedBox(height: 48),
                    const Text(
                      '🎉 Sistema de autenticación funcionando correctamente',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
