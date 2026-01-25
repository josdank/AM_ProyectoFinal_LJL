import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'core/config/supabase_config.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/ljl_theme.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';

import 'features/geolocation/presentation/pages/map_view_page.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/pages/profile_page.dart';

import 'features/listings/presentation/bloc/listing_bloc.dart';
import 'features/listings/presentation/pages/listings_page.dart';

import 'features/connections/presentation/bloc/connection_bloc.dart';
import 'features/connections/presentation/pages/connections_page.dart';
import 'features/connections/presentation/pages/matches_page.dart';

import 'features/security/presentation/bloc/security_bloc.dart';
import 'features/security/presentation/pages/security_page.dart';

import 'features/chat/presentation/pages/chat_list_page.dart';
import 'features/visits/presentation/pages/my_visits_page.dart';

import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/notifications/presentation/pages/notifications_page.dart';

import 'features/home/presentation/pages/home_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool envLoaded = false;
  bool supabaseInitialized = false;

  try {
    await dotenv.load(fileName: '.env');
    envLoaded = true;
    SupabaseConfig.validate();
  } catch (e) {
    envLoaded = false;
  }

  if (envLoaded) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      supabaseInitialized = true;
    } catch (e) {
      supabaseInitialized = false;
    }
  }

  await di.initDependencies();

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
        debugShowCheckedModeBanner: false,
        theme: buildLjlTheme(),
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Error de configuración.\n\nRevisa tu archivo .env y la conexión a Supabase.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildLjlTheme(),
        home: const RootGate(),
      ),
    );
  }
}

class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          return _HomeShell(
            userId: authState.user.id,
            email: authState.user.email ?? '',
          );
        }

        if (authState is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return const LoginPage();
      },
    );
  }
}

class _HomeShell extends StatelessWidget {
  final String userId;
  final String email;

  const _HomeShell({
    required this.userId,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
          create: (_) =>
              di.sl<ProfileBloc>()..add(ProfileLoadRequested(userId: userId)),
        ),
        BlocProvider<ConnectionBloc>(
          create: (_) => di.sl<ConnectionBloc>()
            ..add(ConnectionLoadRequested(userId: userId)),
        ),
        BlocProvider<SecurityBloc>(
          create: (_) =>
              di.sl<SecurityBloc>()..add(SecurityLoadRequested(userId: userId)),
        ),
        BlocProvider<NotificationBloc>(
          create: (_) => di.sl<NotificationBloc>()
            ..add(NotificationStarted(userId: userId)),
        ),
      ],
      child: _HomePageContent(email: email, userId: userId),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  final String email;
  final String userId;

  const _HomePageContent({
    required this.email,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Busca Compañero'),
        actions: [
          // ✅ NUEVO: Botón de Mapa
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Mapa de Viviendas',
            onPressed: () => _navigateToMap(context),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Mensajes',
            onPressed: () => _navigateToChat(context),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Mis Visitas',
            onPressed: () => _navigateToVisits(context),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () => _navigateToProfile(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          if (profileState is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileState is ProfileError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      profileState.message,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<ProfileBloc>()
                          .add(ProfileLoadRequested(userId: userId)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (profileState is ProfileLoaded) {
            return HomeDashboardPage(
              email: email,
              isProfileComplete: profileState.profile.isProfileComplete,
              onProfile: () => _navigateToProfile(context),
              onListings: () => _navigateToListings(context),
              onConnections: () => _navigateToConnections(context),
              onMatches: () => _navigateToMatches(context),
              onSecurity: () => _navigateToSecurity(context),
              onNotifications: () => _navigateToNotifications(context),
              onMap: () => _navigateToMap(context), // NUEVO
            );
          }

          return const Center(child: Text('Estado desconocido'));
        },
      ),
    );
  }

  // ✅ NUEVO MÉTODO
  void _navigateToMap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MapViewPage(),
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

  void _navigateToListings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              di.sl<ListingBloc>()..add(const ListingsLoadRequested()),
          child: const ListingsPage(),
        ),
      ),
    );
  }

  void _navigateToConnections(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ConnectionBloc>(),
          child: const ConnectionsPage(),
        ),
      ),
    );
  }

  void _navigateToMatches(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ConnectionBloc>(),
          child: const MatchesPage(),
        ),
      ),
    );
  }

  void _navigateToSecurity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SecurityBloc>(),
          child: const SecurityPage(),
        ),
      ),
    );
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<NotificationBloc>(),
          child: const NotificationsPage(),
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChatListPage(),
      ),
    );
  }

  void _navigateToVisits(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyVisitsPage(),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content:
            const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<AuthBloc>()
                  .add(const AuthLogoutRequested());
            },
            style:
                TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
