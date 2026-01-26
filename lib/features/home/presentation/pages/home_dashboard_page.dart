import 'package:flutter/material.dart';
import '../../../../core/theme/ljl_theme.dart';

class HomeDashboardPage extends StatelessWidget {
  final String email;
  final bool isProfileComplete;
  final List<String> roles; // NUEVO: Lista de roles del usuario

  final VoidCallback onProfile;
  final VoidCallback onListings;
  final VoidCallback onConnections;
  final VoidCallback onMatches;
  final VoidCallback onSecurity;
  final VoidCallback onNotifications;
  final VoidCallback onMap;
  final VoidCallback onMyProperties;

  const HomeDashboardPage({
    super.key,
    required this.email,
    required this.isProfileComplete,
    required this.roles, // NUEVO
    required this.onProfile,
    required this.onListings,
    required this.onConnections,
    required this.onMatches,
    required this.onSecurity,
    required this.onNotifications,
    required this.onMap,
    required this.onMyProperties,
  });

  // NUEVO: Método para verificar si el usuario es tenant
  bool get isTenant => roles.contains('tenant');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandHero(
            email: email,
            isProfileComplete: isProfileComplete,
            isTenant: isTenant, // NUEVO
          ),
          const SizedBox(height: 14),

          // Fila de botones principales
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onProfile,
                  icon: const Icon(Icons.person),
                  label: Text(
                    isProfileComplete ? 'Ver perfil' : 'Completar perfil',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onListings,
                  icon: const Icon(Icons.home_work_outlined),
                  label: const Text('Habitaciones'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // MODIFICADO: Mostrar botones de Mapa y Propiedades solo si es tenant
          if (isTenant) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onMap,
                    icon: const Icon(Icons.map),
                    label: const Text('Ver Mapa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LjlColors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onMyProperties,
                    icon: const Icon(Icons.home),
                    label: const Text('Mis Propiedades'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LjlColors.gold,
                      foregroundColor: LjlColors.navy,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Si NO es tenant, solo mostrar el botón del mapa (opcional)
            ElevatedButton.icon(
              onPressed: onMap,
              icon: const Icon(Icons.map),
              label: const Text('Ver Mapa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: LjlColors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          ],

          const SizedBox(height: 18),
          Text(
            'Funciones clave',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),

          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.12,
            children: [
              _FeatureCard(
                title: 'Conexiones',
                subtitle: 'Likes e intereses',
                icon: Icons.favorite_rounded,
                accent: LjlColors.gold,
                onTap: onConnections,
              ),
              _FeatureCard(
                title: 'Matches',
                subtitle: 'Mutuos confirmados',
                icon: Icons.handshake_rounded,
                accent: LjlColors.teal,
                onTap: onMatches,
              ),
              _FeatureCard(
                title: 'Seguridad',
                subtitle: 'Verificación / Bloqueo',
                icon: Icons.verified_user_rounded,
                accent: LjlColors.navy,
                onTap: onSecurity,
              ),
              _FeatureCard(
                title: 'Notificaciones',
                subtitle: 'Eventos y alertas',
                icon: Icons.notifications_active_rounded,
                accent: LjlColors.gold,
                onTap: onNotifications,
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (!isProfileComplete)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: LjlColors.gold.withOpacity(.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: LjlColors.gold.withOpacity(.35)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: LjlColors.navy),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Completa tu perfil para aumentar la confianza y mejorar tus matches.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: LjlColors.navy.withOpacity(.92),
                        fontWeight: FontWeight.w800,
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
}

class _BrandHero extends StatelessWidget {
  final String email;
  final bool isProfileComplete;
  final bool isTenant; // NUEVO

  const _BrandHero({
    required this.email,
    required this.isProfileComplete,
    required this.isTenant, // NUEVO
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [LjlColors.navy, LjlColors.navy.withOpacity(.92)],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(.12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: LjlColors.teal.withOpacity(.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -95,
            left: -70,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: LjlColors.gold.withOpacity(.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(.12)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/Logo_app.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LJL – CoLive',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.80),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _StatusPill(isProfileComplete: isProfileComplete),
                          const SizedBox(width: 8),
                          // NUEVO: Mostrar badge de rol tenant
                          if (isTenant) _RolePill(role: 'Arrendatario'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Comparte · Vive · Conecta',
                        style: TextStyle(
                          color: Colors.white.withOpacity(.75),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isProfileComplete;
  const _StatusPill({required this.isProfileComplete});

  @override
  Widget build(BuildContext context) {
    final dot = isProfileComplete ? Colors.greenAccent : Colors.amberAccent;
    final text = isProfileComplete ? 'Perfil completo' : 'Perfil incompleto';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(.92),
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: .1,
            ),
          ),
        ],
      ),
    );
  }
}

// NUEVO: Widget para mostrar el rol del usuario
class _RolePill extends StatelessWidget {
  final String role;
  const _RolePill({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(.20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.blue.withOpacity(.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.home_work_outlined,
            color: Colors.white.withOpacity(.92),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            role,
            style: TextStyle(
              color: Colors.white.withOpacity(.92),
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: .1,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LjlColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: LjlColors.navy.withOpacity(.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withOpacity(.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: LjlColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: LjlColors.navy.withOpacity(.65),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}