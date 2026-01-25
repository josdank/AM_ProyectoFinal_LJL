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
          body: SafeArea(
            child: Center(
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
        theme: buildLjlTheme().copyWith(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
            centerTitle: true,
            toolbarHeight: 60, // Altura consistente para AppBar
          ),
        ),
        home: const SafeAreaWrapper(), // Usar el wrapper con SafeArea
      ),
    );
  }
}

// ✅ NUEVO: Wrapper principal con SafeArea
class SafeAreaWrapper extends StatelessWidget {
  const SafeAreaWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      left: true,
      right: true,
      minimum: const EdgeInsets.only(top: 4), // Margen mínimo superior
      child: RootGate(),
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
        centerTitle: true,
        toolbarHeight: 60, // Altura fija para mejor manejo táctil
        actions: [
          // Botones con mejor área táctil
          _buildAppBarIconButton(
            icon: Icons.map,
            tooltip: 'Mapa de Viviendas',
            onPressed: () => _navigateToMap(context),
          ),
          _buildAppBarIconButton(
            icon: Icons.chat_bubble_outline,
            tooltip: 'Mensajes',
            onPressed: () => _navigateToChat(context),
          ),
          _buildAppBarIconButton(
            icon: Icons.calendar_today,
            tooltip: 'Mis Visitas',
            onPressed: () => _navigateToVisits(context),
          ),
          _buildAppBarIconButton(
            icon: Icons.person,
            tooltip: 'Perfil',
            onPressed: () => _navigateToProfile(context),
          ),
          _buildAppBarIconButton(
            icon: Icons.logout,
            tooltip: 'Cerrar Sesión',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        top: false, // Ya estamos dentro de un SafeAreaWrapper
        bottom: true,
        left: true,
        right: true,
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (profileState is ProfileError) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          profileState.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => context
                            .read<ProfileBloc>()
                            .add(ProfileLoadRequested(userId: userId)),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
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
                onMap: () => _navigateToMap(context),
              );
            }

            return const Center(child: Text('Estado desconocido'));
          },
        ),
      ),
    );
  }

  // ✅ NUEVO: Método para crear IconButtons con mejor área táctil
  Widget _buildAppBarIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: 44, // Ancho mínimo para mejor táctil
        height: 44, // Alto mínimo para mejor táctil
        child: IconButton(
          icon: Icon(icon),
          tooltip: tooltip,
          onPressed: onPressed,
          padding: EdgeInsets.zero, // Padding interno cero, controlado por SizedBox
          iconSize: 22,
        ),
      ),
    );
  }

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
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '¿Estás seguro que deseas cerrar sesión?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context
                            .read<AuthBloc>()
                            .add(const AuthLogoutRequested());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cerrar Sesión'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}