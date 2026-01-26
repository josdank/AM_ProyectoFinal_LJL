import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_dashboard_page.dart';
import '../../features/tenant/presentation/pages/tenant_home_page.dart';
import '../../features/listings/presentation/pages/listings_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final _router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authBloc = context.read<AuthBloc>();
      final isAuthenticated = authBloc.state is AuthAuthenticated;
      final location = state.uri.toString(); // AQUI ESTA EL CAMBIO

      if (!isAuthenticated) {
        // Redirigir a login si no está autenticado
        if (location != '/login' && location != '/register') {
          return '/login';
        }
      } else {
        // Si está autenticado, redirigir según rol
        final authState = authBloc.state as AuthAuthenticated;
        final user = authState.user;

        if (location == '/login' || location == '/register') {
          return user.isTenant() ? '/tenant' : '/home';
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/login'),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state as AuthAuthenticated;
          final user = authState.user;

          return HomeDashboardPage(
            email: user.email,
            isProfileComplete: user.isProfileComplete,
            roles: user
                .roles, // Asegúrate de que 'user' tiene la propiedad 'roles'
            onProfile: () => context.go('/profile'),
            onListings: () => context.go('/listings'),
            onConnections: () {
              // luego puedes poner ruta real
              debugPrint('Connections');
            },
            onMatches: () {
              debugPrint('Matches');
            },
            onSecurity: () {
              context.go('/security'); // si tienes esta ruta
            },
            onNotifications: () {
              debugPrint('Notifications');
            },
            onMap: () {
              context.go('/map'); // si tienes mapa
            },
            onMyProperties: () {
              // Acción para "Mis propiedades"
              debugPrint('My Properties');
            },
          );
        },
      ),

      GoRoute(
        path: '/tenant',
        builder: (context, state) => const TenantHomePage(),
      ),
      GoRoute(
        path: '/listings',
        builder: (context, state) => const ListingsPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}
